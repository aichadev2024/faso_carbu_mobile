import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

var logger = Logger();

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Récupère le token FCM depuis Firebase
  Future<String?> getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      logger.e("⚠️ Erreur récupération FCM Token: $e");
      return null;
    }
  }

  /// Envoie le token FCM vers ton backend
  Future<void> updateFcmToken({
    required String userId,
    required String jwtToken,
  }) async {
    try {
      final fcmToken = await getFcmToken();
      if (fcmToken == null) {
        logger.e("❌ Impossible de récupérer le token FCM");
        return;
      }

      final response = await http.post(
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/utilisateur/update-token",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwtToken",
        },
        body: jsonEncode({
          "userId": userId, // ✅ doit être non null
          "fcmToken": fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        logger.i("✅ Token FCM mis à jour avec succès !");
      } else {
        logger.e(
          "❌ Erreur update FCM: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      logger.e("⚠️ Exception lors de l’update du FCM token: $e");
    }
  }
}
