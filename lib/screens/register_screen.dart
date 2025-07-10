import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'chauffeur';
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (nom.isEmpty ||
        prenom.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _error = "Veuillez remplir tous les champs";
        _loading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = "Les mots de passe ne correspondent pas";
        _loading = false;
      });
      return;
    }

    try {
      final existing = await DatabaseHelper.instance.getUser(email);
      if (existing != null) {
        setState(() {
          _error = "Cet utilisateur existe déjà";
          _loading = false;
        });
        return;
      }

      // ✅ Corrigé : ajoute le préfixe "ROLE_" pour cohérence
      final role = 'ROLE_${_selectedRole.toUpperCase()}';

      await DatabaseHelper.instance.saveUser({
        'email': email,
        'motDePasse': password,
        'role': role,
        'nom': nom,
        'prenom': prenom,
        'token': 'offline-token',
      });

    if (context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('✅ Inscription réussie ! Vous pouvez vous connecter.'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ),
  );

  // Attendre un peu avant de rediriger pour que l'utilisateur voie le message
  await Future.delayed(const Duration(seconds: 2));

  Navigator.pushReplacementNamed(context, '/login');
}

    } catch (e) {
      setState(() {
        _error = "Erreur lors de l'enregistrement";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Inscription FasoCarbu'),
        backgroundColor: const Color.fromARGB(255, 39, 197, 237),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) => value!.isEmpty ? 'Prénom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Email requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  validator: (value) =>
                      value!.isEmpty ? 'Mot de passe requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirmer le mot de passe'),
                  validator: (value) =>
                      value!.isEmpty ? 'Confirmez le mot de passe' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  items: const [
                    DropdownMenuItem(
                        value: 'chauffeur', child: Text('Chauffeur')),
                    DropdownMenuItem(
                        value: 'gestionnaire', child: Text('Gestionnaire')),
                    DropdownMenuItem(
                        value: 'agent_station', child: Text('Agent de station')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.app_registration),
                        label: const Text("S'inscrire"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 103, 221, 234),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
