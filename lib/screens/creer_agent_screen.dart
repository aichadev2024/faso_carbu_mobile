import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';

class CreerAgentScreen extends StatefulWidget {
  const CreerAgentScreen({super.key, required this.token, required this.adminStationId});
  final String token;
  final String adminStationId;

  @override
  State<CreerAgentScreen> createState() => _CreerAgentScreenState();
}

class _CreerAgentScreenState extends State<CreerAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _email = TextEditingController();
  final _telephone = TextEditingController();
  final _password = TextEditingController();
  bool _show = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _email, _telephone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Api.post('/admin-stations/${widget.adminStationId}/agents', {
        'nom': _nom.text.trim(),
        'prenom': _prenom.text.trim(),
        'email': _email.text.trim(),
        'motDePasse': _password.text,
        'telephone': _telephone.text.trim(),
      });
      if (!mounted) return;
      showAppSnack(context, 'Agent créé.', tone: Tone.success);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel agent')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('L\'agent se connectera à l\'appli avec cet email et ce mot de passe.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null) ...[InlineAlert(message: _error!), gap],
                AppTextField(label: 'Prénom', controller: _prenom, required: true, icon: Icons.person_outline_rounded),
                gap,
                AppTextField(label: 'Nom', controller: _nom, required: true, icon: Icons.person_outline_rounded),
                gap,
                AppTextField(
                  label: 'Téléphone',
                  controller: _telephone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: '+226 70 00 00 00',
                ),
                gap,
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  required: true,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                gap,
                AppTextField(
                  label: 'Mot de passe',
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
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Créer l\'agent', onPressed: _submit, loading: _loading, expand: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
