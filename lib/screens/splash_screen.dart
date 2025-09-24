import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

// Import tes pages
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Étape 1 : Réveiller ton backend Render
    await wakeUpBackend();

    // Étape 2 : Attendre un peu pour l'animation
    await Future.delayed(const Duration(seconds: 2));

    // Étape 3 : Aller vers Onboarding toujours (comme décidé)
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  /// Fonction pour réveiller Render
  Future<void> wakeUpBackend() async {
    const String url = "https://faso-carbu-backend-2.onrender.com/";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        debugPrint("✅ Backend réveillé : ${response.body}");
      } else {
        debugPrint("⚠️ Backend a répondu code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Erreur réveil backend : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_gas_station, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "FasoCarbu",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
