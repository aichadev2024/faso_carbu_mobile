import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';

/// Admin de station : liste et suppression des agents (pompistes).
class AgentsListScreen extends StatefulWidget {
  const AgentsListScreen({super.key, required this.token, required this.adminStationId});
  final String token;
  final String adminStationId;

  @override
  State<AgentsListScreen> createState() => _AgentsListScreenState();
}

class _AgentsListScreenState extends State<AgentsListScreen> {
  List<Map<String, dynamic>> _agents = [];
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
      _agents = Api.asList(await Api.get('/admin-stations/${widget.adminStationId}/agents'));
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> a) async {
    final ok = await confirmDialog(
      context,
      title: 'Supprimer ${a['prenom'] ?? ''} ${a['nom'] ?? ''} ?',
      message: 'Cet agent ne pourra plus valider de tickets.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!ok) return;
    try {
      await Api.delete('/admin-stations/agents/${a['id']}');
      if (!mounted) return;
      showAppSnack(context, 'Agent supprimé.', tone: Tone.success);
      _load();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Agents de station')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/creer-agent_station').then((_) => _load()),
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text('Nouvel agent'),
      ),
      body: _loading && _agents.isEmpty
          ? const LoadingView()
          : RefreshableList(
              onRefresh: _load,
              children: [
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load)
                else if (_agents.isEmpty)
                  const EmptyState(
                    icon: Icons.group_outlined,
                    title: 'Aucun agent',
                    message: 'Ajoutez les pompistes qui scanneront les tickets dans votre station.',
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      for (var i = 0; i < _agents.length; i++) ...[
                        if (i > 0) const Divider(indent: 72),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
                          leading: InitialsAvatar(name: '${_agents[i]['prenom'] ?? ''} ${_agents[i]['nom'] ?? ''}', size: 40),
                          title: Text('${_agents[i]['prenom'] ?? ''} ${_agents[i]['nom'] ?? ''}', style: t.titleSmall),
                          subtitle: Text('${_agents[i]['telephone'] ?? _agents[i]['email'] ?? ''}'),
                          trailing: IconButton(
                            tooltip: 'Supprimer',
                            icon: Icon(Icons.delete_outline_rounded, color: Tone.danger.fg),
                            onPressed: () => _delete(_agents[i]),
                          ),
                        ),
                      ],
                    ]),
                  ),
              ],
            ),
    );
  }
}
