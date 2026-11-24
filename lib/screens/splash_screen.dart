import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/widgets/mobile_widgets.dart';

/// Démarrage : réveille le backend (hébergement en veille) puis oriente vers
/// l'onboarding (premier lancement), l'accueil (session) ou la connexion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Le ping est best-effort : on n'attend pas plus de quelques secondes.
    await Future.any([
      Api.get('/auth/ping').catchError((_) => null),
      Future.delayed(const Duration(seconds: 4)),
    ]);
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    final route = !seen ? '/onboarding' : (Session.isLoggedIn ? '/home' : '/login');
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 52, showName: false),
            const SizedBox(height: 20),
            Text('FasoCarbu', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
          ],
        ),
      ),
    );
  }
}
