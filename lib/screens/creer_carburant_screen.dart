import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';

class CreerCarburantScreen extends StatefulWidget {
  const CreerCarburantScreen({super.key, required this.token, required this.adminStationId});
  final String token;
  final String adminStationId;

  @override
  State<CreerCarburantScreen> createState() => _CreerCarburantScreenState();
}

class _CreerCarburantScreenState extends State<CreerCarburantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prix = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _suggestions = ['Super 91', 'Gasoil', 'Pétrole'];

  @override
  void dispose() {
    _nom.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Api.post('/admin-stations/carburants', {
        'nom': _nom.text.trim(),
        'prix': double.parse(_prix.text.replaceAll(',', '.')),
      });
      if (!mounted) return;
      showAppSnack(context, 'Carburant ajouté.', tone: Tone.success);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau carburant')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[InlineAlert(message: _error!), const SizedBox(height: AppSpacing.lg)],
                AppTextField(label: 'Nom', controller: _nom, required: true, icon: Icons.local_gas_station_outlined),
                const SizedBox(height: AppSpacing.sm),
                Wrap(spacing: AppSpacing.sm, children: [
                  for (final s in _suggestions)
                    ActionChip(label: Text(s), onPressed: () => setState(() => _nom.text = s)),
                ]),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Prix au litre (FCFA)',
                  controller: _prix,
                  icon: Icons.payments_outlined,
                  hint: 'Ex. 850',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final p = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return (p == null || p <= 0) ? 'Prix invalide' : null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Ajouter le carburant', onPressed: _submit, loading: _loading, expand: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
