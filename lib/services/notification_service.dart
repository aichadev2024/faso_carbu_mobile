import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../core/api.dart';
import '../core/session.dart';

final _log = Logger();

/// Enregistre le token de notifications push de l'appareil auprès du backend.
class NotificationService {
  NotificationService._();

  static Future<String?> fcmToken() async {
    if (kIsWeb) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      _log.w('Token FCM indisponible : $e');
      return null;
    }
  }

  /// À appeler après la connexion. N'échoue jamais : les notifications
  /// sont un confort, pas une condition pour utiliser l'appli.
  static Future<void> registerDevice() async {
    final token = await fcmToken();
    if (token == null || Session.userId.isEmpty) return;
    try {
      await Api.post('/utilisateurs/update-token', {'userId': Session.userId, 'fcmToken': token});
    } catch (e) {
      _log.w('Enregistrement du token FCM impossible : $e');
    }
  }
}
