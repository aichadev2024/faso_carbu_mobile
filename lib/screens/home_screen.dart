import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ticket_screen.dart';
import 'ticket_history_screen.dart';
import 'scan_qr_screen.dart';
import 'ticket_list_agent_screen.dart';
import 'agents_list_screen.dart';
import 'carburants_list_screen.dart';

const Color primaryRed = Color(0xFFD32F2F);

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;
  final String token;
  final String nom;
  final String prenom;
  final String userId;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.token,
    required this.nom,
    required this.prenom,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _profileImage = File(path));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _profileImage = File(picked.path));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', picked.path);
  }

  String roleLabel(String role) {
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

  void navigate(BuildContext context, String route) {
    final routes = {
      '/ticket': TicketScreen(token: widget.token),
      '/ticket-list': TicketHistoryScreen(token: widget.token),
      '/scan-qr': ScanQrScreen(token: widget.token, userId: widget.userId),
      '/ticket-list-agent': TicketListAgentScreen(
        token: widget.token,
        agentId: widget.userId,
      ),
      '/agents-list': AgentsListScreen(
        token: widget.token,
        adminStationId: widget.userId,
      ),
      '/carburants-list': CarburantsListScreen(
        token: widget.token,
        adminStationId: widget.userId,
      ),
    };

    Navigator.push(context, MaterialPageRoute(builder: (_) => routes[route]!));
  }

  List<Map<String, String>> getTiles() {
    if (widget.userRole == 'ROLE_ADMIN_STATION') {
      return [
        {
          'image': 'assets/images/agents.jpg',
          'label': 'Agents',
          'route': '/agents-list',
        },
        {
          'image': 'assets/images/carburants.jpg',
          'label': 'Carburants',
          'route': '/carburants-list',
        },
      ];
    }

    if (widget.userRole == 'ROLE_CHAUFFEUR') {
      return [
        {
          'image': 'assets/images/tickets.jpg',
          'label': 'Tickets',
          'route': '/ticket',
        },
        {
          'image': 'assets/images/history.jpg',
          'label': 'Historique',
          'route': '/ticket-list',
        },
      ];
    }

    return [
      {
        'image': 'assets/images/scan.jpg',
        'label': 'Scanner QR',
        'route': '/scan-qr',
      },
      {
        'image': 'assets/images/history.jpg',
        'label': 'Historique',
        'route': '/ticket-list-agent',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tiles = getTiles();

    // Détection mode sombre / clair
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Color(0xFF0F1115) : Colors.grey.shade100;
    final cardColor = isDark ? Color(0xFF1A1D24) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // HEADER AVEC FLOU ET AVATAR FLOTTANT
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/header_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: bgColor,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
              Positioned(
                left: 20,
                bottom: -35,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              color: primaryRed,
                              size: 50,
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 100,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour ${widget.prenom}",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      roleLabel(widget.userRole),
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),

          // CARTES
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (_, i) {
                  final t = tiles[i];
                  return GestureDetector(
                    onTap: () => navigate(context, t['route']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.asset(
                              t['image']!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              t['label']!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
