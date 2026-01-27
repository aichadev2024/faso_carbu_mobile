import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final firstTime = prefs.getBool('first_time') ?? true;
    final token = prefs.getString('auth_token');

    if (!mounted) return; // ✅ IMPORTANT

    if (firstTime) {
      await prefs.setBool('first_time', false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (token != null && token.isNotEmpty) {
      final email = prefs.getString('email') ?? '';
      final role = prefs.getString('role') ?? '';
      final nom = prefs.getString('nom') ?? '';
      final prenom = prefs.getString('prenom') ?? '';
      final userId = prefs.getString('userId') ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            email: email,
            role: role,
            token: token,
            nom: nom,
            prenom: prenom,
            userId: userId,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
