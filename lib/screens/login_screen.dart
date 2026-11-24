import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';
import '../services/notification_service.dart';
import 'ForgotPasswordScreen.dart';

/// Rôles qui utilisent l'appli mobile. Les gestionnaires et demandeurs
/// travaillent sur le tableau de bord web.
const _mobileRoles = {'CHAUFFEUR', 'AGENT_STATION', 'ADMIN_STATION'};

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fcm = await NotificationService.fcmToken();
      final data = await Api.post(
        '/auth/login',
        {'email': _email.text.trim(), 'motDePasse': _password.text, if (fcm != null) 'fcmToken': fcm},
        false,
      ) as Map<String, dynamic>;

      final role = (data['role'] ?? '').toString().toUpperCase().replaceFirst('ROLE_', '');
      if (!_mobileRoles.contains(role)) {
        setState(() => _error = 'L\'appli mobile est réservée aux chauffeurs et au personnel de station. '
            'Les gestionnaires utilisent le tableau de bord web.');
        return;
      }

      await Session.save(
        token: (data['token'] ?? '').toString(),
        userId: (data['id'] ?? '').toString(),
        email: (data['email'] ?? _email.text.trim()).toString(),
        nom: (data['nom'] ?? '').toString(),
        prenom: (data['prenom'] ?? '').toString(),
        role: (data['role'] ?? '').toString(),
      );
      NotificationService.registerDevice();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (e) {
      setState(() => _error = (e.statusCode == 401 || e.statusCode == 403)
          ? 'Email ou mot de passe incorrect.'
          : e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(alignment: Alignment.centerLeft, child: BrandMark(size: 40)),
                      const SizedBox(height: 48),
                      Text('Bon retour 👋', style: t.headlineMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Connectez-vous pour accéder à vos tickets et à votre station.', style: t.bodyMedium),
                      const SizedBox(height: AppSpacing.xxl),
                      if (_error != null) ...[InlineAlert(message: _error!), const SizedBox(height: AppSpacing.lg)],
                      AppTextField(
                        label: 'Adresse email',
                        controller: _email,
                        hint: 'nom@entreprise.bf',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Mot de passe',
                        controller: _password,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        validator: (v) => (v == null || v.isEmpty) ? 'Saisissez votre mot de passe' : null,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryButton(label: 'Se connecter', onPressed: _login, loading: _loading, expand: true),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Pas encore de compte ? Demandez-le à votre gestionnaire ou à l\'administrateur de votre station.',
                        style: t.bodySmall,
                        textAlign: TextAlign.center,
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
