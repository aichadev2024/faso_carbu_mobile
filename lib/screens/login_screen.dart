import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:faso_carbu_mobile/models/user_model.dart';
import 'package:faso_carbu_mobile/services/api_service.dart';

const String baseUrl = 'https://faso-carbu-backend-2.onrender.com/api';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
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
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'motDePasse': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'];
        final nom = data['nom'] ?? '';
        final prenom = data['prenom'] ?? '';
        final userId = data['id'] ?? '';
        await ApiService.saveToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('role', role);
        await prefs.setString('nom', nom);
        await prefs.setString('prenom', prenom);
        await prefs.setString('userId', userId);

        final user = UserModel(
          email: email,
          motDePasse: password,
          role: role,
          nom: nom,
          prenom: prenom,
          isSynced: 1,
        );

        await DatabaseHelper.instance.insertUser(user);

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'userEmail': email,
            'userRole': role,
            'token': token,
            'nom': nom,
            'prenom': prenom,
          },
        );
      } else {
        throw Exception("Connexion échouée");
      }
    } catch (e) {
      final localUser = await DatabaseHelper.instance
          .getUserByEmailAndPassword(email, password);

      if (localUser != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'userEmail': localUser.email,
            'userRole': localUser.role,
            'token': '',
            'nom': localUser.nom,
            'prenom': localUser.prenom,
          },
        );
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
      backgroundColor: const Color(0xFFE8F5E9),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_gas_station,
                          size: 64, color: Color.fromARGB(255, 76, 150, 175)),
                      const SizedBox(height: 16),
                      const Text(
                        'FasoCarbu - Connexion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 103, 196, 214),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(_error!,
                            style:
                                const TextStyle(color: Colors.red, fontSize: 14)),
                      const SizedBox(height: 16),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _login(context),
                                icon: const Icon(Icons.login),
                                label: const Text("Se connecter"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 20),
                                  backgroundColor:
                                      const Color.fromARGB(255, 132, 244, 181),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text("Créer un compte"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
