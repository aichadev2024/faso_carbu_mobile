import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreerAgentScreen extends StatefulWidget {
  final String token;
  final String adminStationId; // ✅ correction ici

  const CreerAgentScreen({
    super.key,
    required this.token,
    required this.adminStationId,
  });

  @override
  State<CreerAgentScreen> createState() => _CreerAgentScreenState();
}

class _CreerAgentScreenState extends State<CreerAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telController = TextEditingController();

  bool isLoading = false;

  Future<void> creerAgent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse(
        "https://faso-carbu-backend-2.onrender.com/api/admin-stations/${widget.adminStationId}/agents",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: jsonEncode({
        "nom": nomController.text,
        "prenom": prenomController.text,
        "email": emailController.text,
        "motDePasse": passwordController.text,
        "telephone": telController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Agent créé avec succès")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Erreur : ${response.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Créer un Agent"),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nouvel Agent 👤",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Remplissez les informations ci-dessous pour ajouter un nouvel agent.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // 🔹 Card contenant le formulaire
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: nomController,
                        label: "Nom",
                        icon: Icons.person,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: prenomController,
                        label: "Prénom",
                        icon: Icons.badge,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: passwordController,
                        label: "Mot de passe",
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: telController,
                        label: "Téléphone",
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Bouton stylé
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : creerAgent,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Créer Agent",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Méthode pour éviter la répétition des TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.red.shade700),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
