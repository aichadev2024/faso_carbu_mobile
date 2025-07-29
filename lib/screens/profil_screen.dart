import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/screens/change_password_screen.dart';

class ProfilScreen extends StatelessWidget {
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

  String _formatRole(String role) {
    switch (role) {
      case 'ROLE_CHAUFFEUR':
        return 'Chauffeur';
      case 'ROLE_GESTIONNAIRE':
        return 'Gestionnaire';
      case 'ROLE_AGENT_STATION':
        return 'Agent de station';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
        backgroundColor: const Color.fromARGB(255, 76, 175, 165),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.person, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text("👤 Nom : $nom", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("👤 Prénom : $prenom", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("📧 Email : $userEmail", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("🛡 Rôle : ${_formatRole(userRole)}", style: const TextStyle(fontSize: 18)),
            const Spacer(),

            // 🔒 Bouton changer mot de passe
            Center(
              child: ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(token: token),
      ),
    );
  },
  icon: const Icon(Icons.lock_reset),
  label: const Text("Changer le mot de passe"),
),

            ),
            const SizedBox(height: 12),

            // 🚪 Bouton de déconnexion
            Center(
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text("Se déconnecter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 216, 118, 72),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}