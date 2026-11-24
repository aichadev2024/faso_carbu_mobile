import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/session.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';

class _Page {
  const _Page(this.icon, this.tone, this.title, this.text);
  final IconData icon;
  final Tone tone;
  final String title;
  final String text;
}

const _pages = [
  _Page(Icons.confirmation_number_rounded, Tone.brand, 'Vos tickets carburant',
      'Chauffeurs : retrouvez vos tickets validés et présentez leur QR code en station.'),
  _Page(Icons.qr_code_scanner_rounded, Tone.success, 'Validation en un scan',
      'Agents de station : scannez le QR code, vérifiez et validez le plein en quelques secondes.'),
  _Page(Icons.local_gas_station_rounded, Tone.info, 'Votre station sous contrôle',
      'Admins de station : gérez vos agents et le prix de vos carburants.'),
];

/// Présentation affichée au premier lancement uniquement.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Session.isLoggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _finish, child: const Text('Passer')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(color: p.tone.softBg(context), shape: BoxShape.circle),
                          child: Icon(p.icon, size: 52, color: p.tone.fg),
                        ),
                        const SizedBox(height: 40),
                        Text(p.title, style: t.headlineMedium, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.md),
                        Text(p.text, style: t.bodyLarge?.copyWith(color: t.bodyMedium?.color), textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: last ? 'Commencer' : 'Suivant',
                expand: true,
                onPressed: last
                    ? _finish
                    : () => _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
