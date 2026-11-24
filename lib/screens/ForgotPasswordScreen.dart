import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import 'ResetPasswordScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _email.text.trim();
    try {
      await Api.post('/auth/forgot-password', {'email': email}, false);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)));
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 404 ? 'Aucun compte ne correspond à cet email.' : e.message);
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
                Text('Mot de passe oublié', style: t.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Saisissez votre email : nous vous enverrons un code de réinitialisation.', style: t.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
                if (_error != null) ...[InlineAlert(message: _error!), const SizedBox(height: AppSpacing.lg)],
                AppTextField(
                  label: 'Adresse email',
                  controller: _email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Envoyer le code', onPressed: _submit, loading: _loading, expand: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
