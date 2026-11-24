import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';
import 'ticket_detail_screen.dart';

/// Accueil adapté au rôle : chauffeur, agent de station ou admin de station.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tickets = [];
  int? _agents;
  int? _carburants;
  bool _loading = true;
  String? _error;

  String get _role => Session.role.toUpperCase().replaceFirst('ROLE_', '');

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
      switch (_role) {
        case 'CHAUFFEUR':
          _tickets = Api.asList(await Api.get('/tickets/mes-tickets'));
        case 'AGENT_STATION':
          _tickets = Api.asList(await Api.get('/tickets/mes-tickets-valides'));
        case 'ADMIN_STATION':
          final r = await Future.wait([
            Api.get('/admin-stations/${Session.userId}/agents'),
            Api.get('/admin-stations/${Session.userId}/carburants'),
          ]);
          _agents = Api.asList(r[0]).length;
          _carburants = Api.asList(r[1]).length;
      }
      _tickets.sort((a, b) => '${b['dateEmission']}'.compareTo('${a['dateEmission']}'));
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _go(String route) => Navigator.pushNamed(context, route).then((_) => _load());

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Bonjour' : (h < 18 ? 'Bon après-midi' : 'Bonsoir');
  }

  bool _isToday(dynamic iso) {
    final d = DateTime.tryParse('${iso ?? ''}');
    final n = DateTime.now();
    return d != null && d.year == n.year && d.month == n.month && d.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshableList(
          onRefresh: _load,
          children: [
            Row(children: [
              InitialsAvatar(name: Session.fullName, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting, ${Session.prenom.isEmpty ? '' : Session.prenom}', style: t.headlineSmall),
                    const SizedBox(height: 2),
                    Text(Session.roleLabel, style: t.bodyMedium),
                  ],
                ),
              ),
              const BrandMark(size: 30, showName: false),
            ]),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null) ...[
              InlineAlert(message: _error!),
              const SizedBox(height: AppSpacing.lg),
            ],
            ..._roleContent(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _roleContent(BuildContext context) {
    switch (_role) {
      case 'CHAUFFEUR':
        final enAttente = _tickets.where((t) => '${t['statut']}'.toUpperCase() == 'EN_ATTENTE').toList();
        return [
          _stats([
            ('À utiliser', _loading ? '…' : '${enAttente.length}', Icons.confirmation_number_rounded, Tone.brand),
            ('Utilisés', _loading ? '…' : '${_tickets.length - enAttente.length}', Icons.check_circle_rounded, Tone.success),
          ]),
          const SizedBox(height: AppSpacing.xl),
          ActionCard(
            primary: true,
            icon: Icons.qr_code_2_rounded,
            title: 'Mes tickets',
            subtitle: 'Présentez le QR code en station',
            onTap: () => _go('/ticket'),
          ),
          const SizedBox(height: AppSpacing.md),
          ActionCard(
            icon: Icons.history_rounded,
            tone: Tone.info,
            title: 'Historique',
            subtitle: 'Vos pleins validés',
            onTap: () => _go('/ticket-list'),
          ),
          if (enAttente.isNotEmpty) ...[
            _sectionTitle(context, 'Prochain ticket à utiliser'),
            TicketTile(
              ticket: enAttente.first,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: enAttente.first)),
              ),
            ),
          ],
        ];
      case 'AGENT_STATION':
        final today = _tickets.where((t) => _isToday(t['dateValidation'])).toList();
        final litres = today.fold<double>(0, (s, t) => s + (double.tryParse('${t['quantite'] ?? 0}') ?? 0));
        return [
          _stats([
            ('Validés aujourd\'hui', _loading ? '…' : '${today.length}', Icons.task_alt_rounded, Tone.success),
            ('Volume du jour', _loading ? '…' : '${formatNumber(litres)} L', Icons.water_drop_rounded, Tone.info),
          ]),
          const SizedBox(height: AppSpacing.xl),
          ActionCard(
            primary: true,
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scanner un ticket',
            subtitle: 'Vérifier et valider un plein',
            onTap: () => _go('/scan-qr'),
          ),
          const SizedBox(height: AppSpacing.md),
          ActionCard(
            icon: Icons.receipt_long_rounded,
            tone: Tone.info,
            title: 'Tickets validés',
            subtitle: 'Historique de vos validations',
            onTap: () => _go('/ticket-list-agent'),
          ),
          if (today.isNotEmpty) ...[
            _sectionTitle(context, 'Dernières validations'),
            for (final ticket in today.take(3)) ...[
              TicketTile(
                ticket: ticket,
                showBeneficiaire: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket))),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ];
      case 'ADMIN_STATION':
        return [
          _stats([
            ('Agents', _agents == null ? '…' : '$_agents', Icons.badge_rounded, Tone.info),
            ('Carburants', _carburants == null ? '…' : '$_carburants', Icons.local_gas_station_rounded, Tone.brand),
          ]),
          const SizedBox(height: AppSpacing.xl),
          ActionCard(
            primary: true,
            icon: Icons.local_gas_station_rounded,
            title: 'Carburants et prix',
            subtitle: 'Mettre à jour les tarifs de la station',
            onTap: () => _go('/carburants-list'),
          ),
          const SizedBox(height: AppSpacing.md),
          ActionCard(
            icon: Icons.group_rounded,
            tone: Tone.info,
            title: 'Agents de station',
            subtitle: 'Gérer les comptes de vos pompistes',
            onTap: () => _go('/agents-list'),
          ),
        ];
      default:
        return [
          const InlineAlert(
            tone: Tone.info,
            message: 'Votre rôle n\'a pas d\'espace dédié dans l\'appli mobile. Utilisez le tableau de bord web.',
          ),
        ];
    }
  }

  Widget _stats(List<(String, String, IconData, Tone)> items) {
    return Row(children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(items[i].$3, size: 20, color: items[i].$4.fg),
                  const SizedBox(height: AppSpacing.md),
                  Text(items[i].$2, style: Theme.of(context).textTheme.headlineMedium),
                  Text(items[i].$1, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    ]);
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, AppSpacing.xl, 4, AppSpacing.md),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}
