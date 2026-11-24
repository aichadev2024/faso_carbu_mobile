import 'package:flutter/material.dart';

import '../core/api.dart';
import 'ticket_screen.dart';

/// Agent de station : tickets qu'il a validés.
class TicketListAgentScreen extends StatefulWidget {
  const TicketListAgentScreen({super.key, required this.token, required this.agentId});
  final String token;
  final String agentId;

  @override
  State<TicketListAgentScreen> createState() => _TicketListAgentScreenState();
}

class _TicketListAgentScreenState extends State<TicketListAgentScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets validés')),
      body: TicketListBody(
        loading: _loading,
        error: _error,
        tickets: _tickets,
        onRefresh: _load,
        showBeneficiaire: true,
        emptyTitle: 'Aucune validation',
        emptyMessage: 'Les tickets que vous scannez et validez apparaîtront ici.',
      ),
    );
  }
}
