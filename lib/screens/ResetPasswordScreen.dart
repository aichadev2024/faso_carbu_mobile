import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Api.post(
        '/auth/reset-password',
        {'email': widget.email, 'code': _code.text.trim(), 'nouveauMotDePasse': _password.text},
        false,
      );
      if (!mounted) return;
      showAppSnack(context, 'Mot de passe réinitialisé. Connectez-vous.', tone: Tone.success);
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 400 ? 'Code invalide ou expiré.' : e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nouveau mot de passe', style: t.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Saisissez le code reçu à ${widget.email}.', style: t.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
                if (_error != null) ...[InlineAlert(message: _error!), const SizedBox(height: AppSpacing.lg)],
                AppTextField(
                  label: 'Code de vérification',
                  controller: _code,
                  required: true,
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Nouveau mot de passe',
                  controller: _password,
                  required: true,
                  icon: Icons.lock_outline_rounded,
                  obscureText: !_show,
                  suffix: IconButton(
                    icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _show = !_show),
                  ),
                  validator: (v) => (v == null || v.length < 8) ? '8 caractères minimum' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Confirmation',
                  controller: _confirm,
                  required: true,
                  icon: Icons.lock_outline_rounded,
                  obscureText: !_show,
                  validator: (v) => v != _password.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Réinitialiser', onPressed: _submit, loading: _loading, expand: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
