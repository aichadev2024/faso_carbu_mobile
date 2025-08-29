import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:faso_carbu_mobile/screens/change_password_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String userEmail;
  final String userRole;
  final String token;
  final String nom;
  final String prenom;
  final VoidCallback onLogout;

  const ProfilScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.token,
    required this.nom,
    required this.prenom,
    required this.onLogout,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
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
      appBar: AppBar(
        title: const Text('Mon Profil 👤'),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            // 🔹 Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.red.shade100,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                ),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔹 Infos utilisateur
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person, "Nom", widget.nom),
                    const Divider(),
                    _buildInfoRow(Icons.badge, "Prénom", widget.prenom),
                    const Divider(),
                    _buildInfoRow(Icons.email, "Email", widget.userEmail),
                    const Divider(),
                    _buildInfoRow(
                      Icons.verified_user,
                      "Rôle",
                      _formatRole(widget.userRole),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🔹 Boutons
            _buildButton(
              label: "Changer le mot de passe",
              icon: Icons.lock_reset,
              color: Colors.red.shade700,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(token: widget.token),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildButton(
              label: "Se déconnecter",
              icon: Icons.logout,
              color: Colors.grey.shade800,
              onPressed: widget.onLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.red.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "$label : $value",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
