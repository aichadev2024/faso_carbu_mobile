import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: inkGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.brand.withValues(alpha: 0.45), AppColors.brand.withValues(alpha: 0)]),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), boxShadow: AppShadows.brand()),
                  child: const LogoMark(size: 96),
                ),
                const SizedBox(height: 24),
                const Logo(size: 40, onDark: true, showName: true),
                const SizedBox(height: 8),
                Text(
                  'Le carburant de votre flotte, sous contrôle',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                ),
              ],
            ),
            const Positioned(
              bottom: 56,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
