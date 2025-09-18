import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:faso_carbu_mobile/models/user_model.dart';
import 'package:faso_carbu_mobile/services/api_service.dart';
import 'package:faso_carbu_mobile/services/notification_service.dart';
import 'package:logger/logger.dart';

var logger = Logger();

const String baseUrl = 'https://faso-carbu-backend-2.onrender.com/api';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
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

    logger.i('➡️ POST vers : $baseUrl/auth/login');
    logger.i(
      '📦 Payload : ${jsonEncode({'email': email, 'motDePasse': password})}',
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'motDePasse': password}),
      );

      logger.i('Réponse brute : ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final token = data['token'];
        final role = data['role'];
        final nom = data['nom'] ?? '';
        final prenom = data['prenom'] ?? '';
        final userId = data['id']?.toString() ?? '';

        logger.i("🆔 ID utilisateur reçu: $userId");

        // 🔹 Envoi du token FCM
        final notificationService = NotificationService();
        await notificationService.updateFcmToken(
          userId: userId,
          jwtToken: token,
        );

        // 🔹 Sauvegarde du token
        await ApiService.saveToken(token);

        // 🔹 Sauvegarde SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('role', role);
        await prefs.setString('nom', nom);
        await prefs.setString('prenom', prenom);
        await prefs.setString('userId', userId);

        // 🔹 Sauvegarde locale (SQLite)
        final user = UserModel(
          email: email,
          motDePasse: password,
          role: role,
          nom: nom,
          prenom: prenom,
          isSynced: 1,
        );
        await DatabaseHelper.instance.saveUser(user);

        if (!mounted) return;

        // 🔹 Navigation vers MainScreen
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'userEmail': email,
            'userRole': role,
            'token': token,
            'nom': nom,
            'prenom': prenom,
            'userId': userId, // ✅ ajouté pour cohérence
          },
        );
      } else {
        logger.e("Échec de connexion — Code: ${response.statusCode}");
        throw Exception("Connexion échouée");
      }
    } catch (e) {
      logger.e("❌ Exception lors du login : $e");

      // 🔹 Tentative de connexion hors ligne
      final localUser = await DatabaseHelper.instance.getUserByEmailAndPassword(
        email,
        password,
      );

      if (localUser != null) {
        logger.w("⚠️ Mode hors ligne activé — utilisateur trouvé en local");
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
            'userId': '', // hors-ligne pas d’ID dispo
          },
        );
      } else {
        setState(
          () => _error =
              "Connexion impossible : vérifiez internet ou vos identifiants.",
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(163, 160, 160, 1),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Logo circulaire
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'FasoCarbu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Carte login
                  Card(
                    color: Colors.grey.shade900,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_gas_station,
                            size: 64,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.redAccent,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.redAccent,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_error != null)
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 16),
                          _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.redAccent,
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _login(context),
                                    icon: const Icon(Icons.login),
                                    label: const Text("Se connecter"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
