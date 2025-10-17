import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:faso_carbu_mobile/screens/change_password_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;
  final String token;
  final String nom;
  final String prenom;
  final String userId;
  final VoidCallback onLogout;

  const ProfilScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.token,
    required this.nom,
    required this.prenom,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  File? _profileImage;
  String? _photoUrl;
  bool _isUploading = false;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserPhoto();
  }

  Future<void> _fetchUserPhoto() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/utilisateurs/${widget.userId}",
        ),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        setState(() {
          _photoUrl = data['photoUrl'];
          _isLoading = false;
        });
      } else {
        throw Exception("Erreur récupération profil: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Erreur fetch photo: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _isUploading = true;
      });
      await _uploadPhoto(File(pickedFile.path));
    }
  }

  Future<void> _uploadPhoto(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/utilisateurs/${widget.userId}/upload-photo",
        ),
      );
      request.headers['Authorization'] = "Bearer ${widget.token}";
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResp = json.decode(respStr);
        setState(() {
          _photoUrl = jsonResp['photoUrl'];
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Photo uploadée avec succès !")),
        );
      } else {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Erreur upload photo : $e")));
    }
  }

  String _formatRole(String role) {
    switch (role) {
      case 'ROLE_CHAUFFEUR':
        return 'Chauffeur';
      case 'ROLE_GESTIONNAIRE':
        return 'Gestionnaire';
      case 'ROLE_AGENT_STATION':
        return 'Agent de station';
      case 'ROLE_ADMIN_STATION':
        return 'Admin de station';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ======= HEADER =======
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _isUploading ? null : _pickImage,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (_photoUrl != null
                                              ? NetworkImage(_photoUrl!)
                                              : const AssetImage(
                                                  'assets/images/default_avatar.png',
                                                ))
                                          as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${widget.nom} ${widget.prenom}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatRole(widget.userRole),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ======= INFOS UTILISATEUR =======
                  _buildInfoTile(
                    Icons.person,
                    "${widget.nom} ${widget.prenom}",
                  ),
                  _buildInfoTile(Icons.email, widget.userEmail),
                  _buildInfoTile(Icons.badge, _formatRole(widget.userRole)),
                  _buildInfoTile(
                    Icons.lock,
                    "Changer le mot de passe",
                    trailing: Icons.arrow_forward_ios,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChangePasswordScreen(token: widget.token),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  // ======= BOUTON DÉCONNEXION =======
                  TextButton.icon(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Se déconnecter",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String text, {
    IconData? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          if (trailing != null)
            IconButton(
              icon: Icon(trailing, color: Colors.grey.shade600),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}
