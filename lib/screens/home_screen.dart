import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

var logger = Logger();

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;
  final String token;
  final String nom;
  final String prenom;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.token,
    required this.nom,
    required this.prenom,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userId;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    loadUserId();
    ApiService.syncCarburants();
    _loadProfileImage();
    envoyerTokenFCMAuBackend();
  }

  Future<void> envoyerTokenFCMAuBackend() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        final response = await http.post(
          Uri.parse(
            'https://faso-carbu-backend-2.onrender.com/api/utilisateurs/update-token',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({'fcmToken': fcmToken}),
        );
        if (response.statusCode == 200) {
          logger.i("✅ Token FCM envoyé au backend !");
        } else {
          logger.e("❌ Erreur en envoyant le token FCM : ${response.body}");
        }
      }
    } catch (e) {
      logger.e("❌ Exception pendant l’envoi du token FCM : $e");
    }
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageTemp = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile.jpg';
      final savedImage = await imageTemp.copy('${appDir.path}/$fileName');

      setState(() {
        _profileImage = savedImage;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profile_image_path', savedImage.path);
    }
  }

  String formatRole(String role) {
    switch (role) {
      case 'ROLE_ADMIN_STATION':
        return 'Admin Station';
      case 'ROLE_CHAUFFEUR':
        return 'Chauffeur';
      case 'ROLE_AGENT_STATION':
        return 'Agent Station';
      default:
        return role;
    }
  }

  void navigate(BuildContext context, String routeName) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: {
        'userEmail': widget.userEmail,
        'userRole': widget.userRole,
        'token': widget.token,
        'nom': widget.nom,
        'prenom': widget.prenom,
        'userId': userId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("FasoCarbu"),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Remplacé l’image par une icône
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.local_gas_station,
                size: 80,
                color: Colors.red.shade700,
              ),
            ),

            // 🔹 Bienvenue + profil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      backgroundColor: Colors.red.shade700,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenue ${widget.nom} 👋",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatRole(widget.userRole),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Fonctionnalités en grille
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _buildTilesForRole(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTilesForRole(BuildContext context) {
    final List<Map<String, dynamic>> tiles = [];

    if (widget.userRole == 'ROLE_ADMIN_STATION') {
      tiles.addAll([
        {
          'icon': Icons.people,
          'label': 'Gérer Agents',
          'route': '/agents-list',
        },
        {
          'icon': Icons.local_gas_station,
          'label': 'Gérer Carburants',
          'route': '/carburants-list',
        },
      ]);
    }

    if (widget.userRole == 'ROLE_CHAUFFEUR') {
      tiles.addAll([
        {
          'icon': Icons.confirmation_num,
          'label': 'Tickets Station',
          'route': '/ticket',
        },
        {
          'icon': Icons.history_edu,
          'label': 'Historique Tickets',
          'route': '/ticket-list',
        },
      ]);
    }

    if (widget.userRole == 'ROLE_AGENT_STATION') {
      tiles.addAll([
        {'icon': Icons.qr_code, 'label': 'Scanner QR', 'route': '/scan-qr'},
        {
          'icon': Icons.history_edu,
          'label': 'Historique Tickets',
          'route': '/ticket-list',
        },
      ]);
    }

    return tiles
        .map(
          (tile) => GestureDetector(
            onTap: () => navigate(context, tile['route']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade700,
                    radius: 28,
                    child: Icon(tile['icon'], color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tile['label'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
