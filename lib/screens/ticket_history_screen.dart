import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import 'ticket_screen.dart';

/// Chauffeur : pleins déjà validés en station.
class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key, required this.token});
  final String token;

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  List<Map<String, dynamic>> _tickets = [];
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
      _tickets = Api.asList(await Api.get('/tickets/mes-tickets-valides'))
        ..sort((a, b) => '${b['dateValidation']}'.compareTo('${a['dateValidation']}'));
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final litres = _tickets.fold<double>(0, (s, t) => s + (double.tryParse('${t['quantite'] ?? 0}') ?? 0));
    final total = _tickets.fold<double>(0, (s, t) => s + (double.tryParse('${t['montant'] ?? t['somme'] ?? 0}') ?? 0));
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: TicketListBody(
        loading: _loading,
        error: _error,
        tickets: _tickets,
        onRefresh: _load,
        emptyTitle: 'Aucun plein validé',
        emptyMessage: 'Les tickets utilisés en station apparaîtront ici.',
        header: _tickets.isEmpty
            ? null
            : Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(children: [
                    Expanded(child: _Total(label: 'Pleins', value: '${_tickets.length}')),
                    Expanded(child: _Total(label: 'Volume', value: '${formatNumber(litres)} L')),
                    Expanded(child: _Total(label: 'Montant', value: '${formatNumber(total)} F')),
                  ]),
                ),
              ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(children: [
      Text(value, style: t.titleLarge),
      const SizedBox(height: 2),
      Text(label, style: t.bodySmall),
    ]);
  }
}
