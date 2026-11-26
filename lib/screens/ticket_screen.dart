import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';
import 'ticket_detail_screen.dart';

/// Chauffeur : tous ses tickets, ceux à utiliser en premier.
class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key, required this.token});
  final String token;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
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
      final list = Api.asList(await Api.get('/tickets/mes-tickets'));
      int rank(Map t) => '${t['statut']}'.toUpperCase() == 'EN_ATTENTE' ? 0 : 1;
      list.sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : '${b['dateEmission']}'.compareTo('${a['dateEmission']}');
      });
      _tickets = list;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tickets')),
      body: TicketListBody(
        loading: _loading,
        error: _error,
        tickets: _tickets,
        onRefresh: _load,
        emptyTitle: 'Aucun ticket',
        emptyMessage: 'Vos tickets apparaîtront ici dès qu\'une demande sera validée par votre gestionnaire.',
      ),
    );
  }
}

/// Corps commun des listes de tickets : chargement, erreur, vide, liste.
class TicketListBody extends StatelessWidget {
  const TicketListBody({
    super.key,
    required this.loading,
    required this.error,
    required this.tickets,
    required this.onRefresh,
    required this.emptyTitle,
    required this.emptyMessage,
    this.showBeneficiaire = false,
    this.header,
  });

  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> tickets;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String emptyMessage;
  final bool showBeneficiaire;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    if (loading && tickets.isEmpty) return const LoadingView();
    return RefreshableList(
      onRefresh: onRefresh,
      children: [
        if (header != null) ...[header!, const SizedBox(height: AppSpacing.lg)],
        if (error != null)
          ErrorState(message: error!, onRetry: onRefresh)
        else if (tickets.isEmpty)
          EmptyState(icon: Icons.confirmation_number_outlined, title: emptyTitle, message: emptyMessage)
        else
          for (final t in tickets) ...[
            TicketTile(
              ticket: t,
              showBeneficiaire: showBeneficiaire,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t))),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}
