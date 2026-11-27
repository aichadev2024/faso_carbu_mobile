import 'package:flutter/material.dart';

import '../core/notification_store.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';
import '../models/notification_model.dart';

/// Historique des notifications push reçues sur cet appareil.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationStore.unread.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    NotificationStore.unread.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await NotificationStore.all();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _ago(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    return formatDate(d, withTime: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasUnread = _items.any((n) => !n.lu);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(onPressed: () => NotificationStore.markAllRead(), child: const Text('Tout marquer lu')),
        ],
      ),
      body: _loading
          ? const LoadingView()
          : RefreshableList(
              onRefresh: _load,
              children: [
                if (_items.isEmpty)
                  const EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'Aucune notification',
                    message: 'Vous serez prévenu ici quand un ticket vous est attribué ou validé.',
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      for (var i = 0; i < _items.length; i++) ...[
                        if (i > 0) const Divider(indent: 60),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: _items[i].lu ? null : brandGradient,
                              color: _items[i].lu ? Tone.neutral.softBg(context) : null,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              _items[i].lu ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                              size: 20,
                              color: _items[i].lu ? Tone.neutral.fg : Colors.white,
                            ),
                          ),
                          trailing: _items[i].lu
                              ? null
                              : Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                                ),
                          title: Text(
                            _items[i].titre,
                            style: t.titleSmall?.copyWith(fontWeight: _items[i].lu ? FontWeight.w500 : FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(_items[i].message, style: t.bodyMedium),
                              const SizedBox(height: 4),
                              Text(_ago(_items[i].date), style: t.bodySmall),
                            ],
                          ),
                          onTap: _items[i].lu || _items[i].id == null
                              ? null
                              : () => NotificationStore.markRead(_items[i].id!),
                        ),
                      ],
                    ]),
                  ),
              ],
            ),
    );
  }
}
