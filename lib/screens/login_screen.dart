import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';

const String baseUrl = 'http://192.168.1.2:8080'; // à adapter si besoin

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Veuillez remplir tous les champs");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'motDePasse': password}),
      );

      print("🔄 Réponse status: ${response.statusCode}");
      print("🔄 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'];
        final nom = data['nom'] ?? '';
        final prenom = data['prenom'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('nom', nom);
        await prefs.setString('prenom', prenom);

        // ✅ Sauvegarde locale
        await DatabaseHelper.instance.saveUser({
          'email': email,
          'motDePasse': password,
          'role': role,
          'token': token,
          'nom': nom,
          'prenom': prenom,
        });

        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'userEmail': email,
          'userRole': role,
          'token': token,
          'nom': nom,
          'prenom': prenom,
        });
        return; // ✅ très important
      } else {
        throw Exception("Connexion échouée");
      }
    } catch (e) {
      print("⚠ Erreur de connexion HTTP, tentative offline...");

      final localUser = await DatabaseHelper.instance
          .getUserByEmailAndPassword(email, password);

      if (localUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('token', localUser['token']);
        await prefs.setString('role', localUser['role']);
        await prefs.setString('nom', localUser['nom']);
        await prefs.setString('prenom', localUser['prenom']);

        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'userEmail': email,
          'userRole': localUser['role'],
          'token': localUser['token'],
          'nom': localUser['nom'],
          'prenom': localUser['prenom'],
        });
      } else {
        setState(() => _error =
            "Connexion impossible : vérifiez internet ou vos identifiants.");
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Connexion FasoCarbu'),
        backgroundColor: const Color.fromARGB(255, 35, 187, 238),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.lock_open,
                  size: 80, color: Color.fromARGB(255, 114, 194, 117)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text("Se connecter"),
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 112, 193, 115),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(color: Color.fromARGB(255, 113, 197, 103)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}