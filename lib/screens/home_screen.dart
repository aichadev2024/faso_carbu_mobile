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
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _initHome();
  }

  Future<void> _initHome() async {
    logger.i("🔹 Initialisation HomeScreen...");

    await ApiService.syncCarburants();
    logger.i("🔹 Carburants synchronisés.");

    await _loadProfileImage();
    logger.i("🔹 Image de profil chargée: ${_profileImage?.path}");

    // Envoi du token FCM
    await envoyerTokenFCMAuBackend();
  }

  Future<void> envoyerTokenFCMAuBackend() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();
      logger.i("🔹 Token FCM récupéré: $fcmToken");

      if (fcmToken == null) {
        logger.w("⚠️ Token FCM est null, rien à envoyer.");
        return;
      }

      final payload = jsonEncode({'fcmToken': fcmToken});
      logger.i("🔹 Payload envoyé au backend: $payload");

      final response = await http.post(
        Uri.parse(
          'https://faso-carbu-backend-2.onrender.com/api/utilisateurs/update-token',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: payload,
      );

      logger.i("🔹 Status code du backend: ${response.statusCode}");
      logger.i("🔹 Body du backend: ${response.body}");

      if (response.statusCode == 200) {
        logger.i("✅ Token FCM envoyé au backend !");
      } else {
        logger.e("❌ Erreur en envoyant le token FCM : ${response.body}");
      }
    } catch (e, s) {
      logger.e("❌ Exception pendant l’envoi du token FCM : $e");
      logger.e("Stacktrace : $s");
    }
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImage.path);
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

  void navigate(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? extraArgs,
  }) {
    final Map<String, dynamic> args = {
      'userEmail': widget.userEmail,
      'userRole': widget.userRole,
      'token': widget.token,
      'nom': widget.nom,
      'prenom': widget.prenom,
      ...?extraArgs,
    };

    logger.i("➡️ Navigation vers $routeName avec args: $args");

    Navigator.pushNamed(context, routeName, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade700, Colors.red.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "FasoCarbu",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Carte profil
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 35,
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
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenue ${widget.nom} 👋",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatRole(widget.userRole),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Grille
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: _buildTilesForRole(context),
                  ),
                ),
              ],
            ),
          ),
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
          'extraArgs': {
            'adminStationId': widget.nom,
          }, // à remplacer par l’ID réel
        },
        {
          'icon': Icons.local_gas_station,
          'label': 'Gérer Carburants',
          'route': '/carburants-list',
          'extraArgs': {
            'adminStationId': widget.nom,
          }, // à remplacer par l’ID réel
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
          'route': '/ticket-list-agent',
          'extraArgs': {'userId': widget.userEmail}, // important !
        },
      ]);
    }

    return tiles.map((tile) {
      return GestureDetector(
        onTap: () => navigate(
          context,
          tile['route'],
          extraArgs: tile['extraArgs'] as Map<String, dynamic>?,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade100,
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade700,
                radius: 30,
                child: Icon(tile['icon'], color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                tile['label'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
