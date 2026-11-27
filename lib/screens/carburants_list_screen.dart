import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';

/// Admin de station : carburants proposés et leurs prix.
class CarburantsListScreen extends StatefulWidget {
  const CarburantsListScreen({super.key, required this.token, required this.adminStationId});
  final String token;
  final String adminStationId;

  @override
  State<CarburantsListScreen> createState() => _CarburantsListScreenState();
}

class _CarburantsListScreenState extends State<CarburantsListScreen> {
  List<Map<String, dynamic>> _carburants = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _carburants = Api.asList(await Api.get('/admin-stations/${widget.adminStationId}/carburants'));
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit(Map<String, dynamic> c) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditSheet(carburant: c, adminStationId: widget.adminStationId),
    );
    if (saved == true && mounted) {
      showAppSnack(context, 'Prix mis à jour.', tone: Tone.success);
      _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> c) async {
    final ok = await confirmDialog(
      context,
      title: 'Supprimer « ${c['nom']} » ?',
      message: 'Ce carburant ne sera plus proposé dans les demandes.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!ok) return;
    try {
      await Api.delete('/admin-stations/carburants/${c['id']}');
      if (!mounted) return;
      showAppSnack(context, 'Carburant supprimé.', tone: Tone.success);
      _load();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Carburants et prix')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/creer-carburant').then((_) => _load()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
      body: _loading && _carburants.isEmpty
          ? const LoadingView()
          : RefreshableList(
              onRefresh: _load,
              children: [
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load)
                else if (_carburants.isEmpty)
                  const EmptyState(
                    icon: Icons.local_gas_station_outlined,
                    title: 'Aucun carburant',
                    message: 'Ajoutez les carburants vendus dans votre station et leur prix au litre.',
                  )
                else
                  for (final c in _carburants) ...[
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _edit(c),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: brandGradient,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                boxShadow: AppShadows.brand(),
                              ),
                              child: const Icon(Icons.water_drop_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${c['nom']}', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  Text('Modifier le prix', style: t.bodySmall),
                                ],
                              ),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(
                                formatNumber(double.tryParse('${c['prix'] ?? 0}')),
                                style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                              ),
                              Text('FCFA / litre', style: t.bodySmall),
                            ]),
                            PopupMenuButton<String>(
                              onSelected: (v) => v == 'edit' ? _edit(c) : _delete(c),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('Modifier le prix')),
                                PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Tone.danger.fg))),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
    );
  }
}

class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.carburant, required this.adminStationId});
  final Map<String, dynamic> carburant;
  final String adminStationId;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final _nom = TextEditingController(text: '${widget.carburant['nom'] ?? ''}');
  late final _prix = TextEditingController(text: '${widget.carburant['prix'] ?? ''}'.replaceAll(RegExp(r'\.0$'), ''));
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nom.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Api.put('/admin-stations/${widget.adminStationId}/carburants/${widget.carburant['id']}', {
        'nom': _nom.text.trim(),
        'prix': double.parse(_prix.text.replaceAll(',', '.')),
      });
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.xl, 0, AppSpacing.xl, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Modifier le carburant', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) ...[InlineAlert(message: _error!), const SizedBox(height: AppSpacing.lg)],
            AppTextField(label: 'Nom', controller: _nom, required: true, icon: Icons.local_gas_station_outlined),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Prix au litre (FCFA)',
              controller: _prix,
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final p = double.tryParse((v ?? '').replaceAll(',', '.'));
                return (p == null || p <= 0) ? 'Prix invalide' : null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Enregistrer', onPressed: _save, loading: _loading, expand: true),
          ],
        ),
      ),
    );
  }
}
