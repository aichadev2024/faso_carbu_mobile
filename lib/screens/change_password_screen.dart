import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ancien = TextEditingController();
  final _nouveau = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ancien.dispose();
    _nouveau.dispose();
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
      await Api.put('/auth/changer-mot-de-passe', {
        'email': Session.email,
        'ancienMotDePasse': _ancien.text,
        'nouveauMotDePasse': _nouveau.text,
      });
      if (!mounted) return;
      showAppSnack(context, 'Mot de passe modifié.', tone: Tone.success);
      Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 400 ? 'Mot de passe actuel incorrect.' : e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FormIntro(
                  icon: Icons.lock_reset_rounded,
                  title: 'Nouveau mot de passe',
                  text: 'Au moins 8 caractères, avec des lettres et des chiffres.',
                ),
                if (_error != null) ...[InlineAlert(message: _error!), const SizedBox(height: AppSpacing.lg)],
                AppTextField(
                  label: 'Mot de passe actuel',
                  controller: _ancien,
                  required: true,
                  icon: Icons.lock_outline_rounded,
                  obscureText: !_show,
                  suffix: IconButton(
                    icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _show = !_show),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Nouveau mot de passe',
                  controller: _nouveau,
                  required: true,
                  icon: Icons.key_outlined,
                  obscureText: !_show,
                  validator: (v) {
                    if (v == null || v.length < 8) return '8 caractères minimum';
                    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) return 'Mélangez lettres et chiffres';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Confirmation',
                  controller: _confirm,
                  required: true,
                  icon: Icons.key_outlined,
                  obscureText: !_show,
                  validator: (v) => v != _nouveau.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Mettre à jour', onPressed: _submit, loading: _loading, expand: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
