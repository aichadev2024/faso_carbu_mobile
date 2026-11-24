import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/notification_model.dart';

/// Historique local des notifications push.
/// SQLite sur mobile ; simple mémoire sur le web (aperçu navigateur).
class NotificationStore {
  NotificationStore._();

  static final List<NotificationModel> _memory = [];

  /// Nombre de notifications non lues, pour le badge de la barre de navigation.
  static final ValueNotifier<int> unread = ValueNotifier(0);

  static Future<void> add({required String titre, required String message}) async {
    final n = NotificationModel(titre: titre, message: message, date: DateTime.now().toIso8601String());
    if (kIsWeb) {
      _memory.insert(0, NotificationModel(id: _memory.length + 1, titre: titre, message: message, date: n.date));
    } else {
      final map = n.toMap()..remove('id');
      await DatabaseHelper.instance.insertNotification(map);
    }
    await refreshUnread();
  }

  static Future<List<NotificationModel>> all() async {
    if (kIsWeb) return List.of(_memory);
    return DatabaseHelper.instance.getAllNotifications();
  }

  static Future<void> markRead(int id) async {
    if (kIsWeb) {
      final i = _memory.indexWhere((n) => n.id == id);
      if (i >= 0) {
        final n = _memory[i];
        _memory[i] = NotificationModel(id: n.id, titre: n.titre, message: n.message, date: n.date, lu: true);
      }
    } else {
      await DatabaseHelper.instance.marquerNotificationCommeLue(id);
    }
    await refreshUnread();
  }

  static Future<void> markAllRead() async {
    for (final n in await all()) {
      if (!n.lu && n.id != null) await markRead(n.id!);
    }
  }

  static Future<void> refreshUnread() async {
    try {
      unread.value = (await all()).where((n) => !n.lu).length;
    } catch (_) {
      unread.value = 0;
    }
  }
}
