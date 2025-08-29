import 'package:faso_carbu_mobile/screens/agents_list_screen.dart';
import 'package:faso_carbu_mobile/screens/creer_agent_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:faso_carbu_mobile/screens/login_screen.dart';
import 'package:faso_carbu_mobile/screens/main_screen.dart';
import 'package:faso_carbu_mobile/screens/scan_qr_screen.dart';
import 'package:faso_carbu_mobile/screens/profil_screen.dart';
import 'package:faso_carbu_mobile/screens/notification_screen.dart';

// 🔹 Ajouts
import 'package:faso_carbu_mobile/screens/ticket_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_history_screen.dart';

// 🔹 Ajouts Carburants
import 'package:faso_carbu_mobile/screens/carburants_list_screen.dart';
import 'package:faso_carbu_mobile/screens/creer_carburant_screen.dart';

import 'package:logger/logger.dart';

var logger = Logger();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  logger.i(
    "🔔 Notification reçue en arrière-plan : ${message.notification?.title}",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    logger.i("📨 Notification reçue en premier plan !");
    if (message.notification != null) {
      logger.i("🔔 Titre : ${message.notification!.title}");
      logger.i("📝 Body : ${message.notification!.body}");
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    logger.i("📲 Application ouverte via une notification !");
  });

  final fcmToken = await FirebaseMessaging.instance.getToken();
  logger.i("📱 Token FCM : $fcmToken");

  runApp(const FasoCarbuApp());
}

class FasoCarbuApp extends StatelessWidget {
  const FasoCarbuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FasoCarbu',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/home':
            final userEmail = args?['userEmail'];
            final userRole = args?['userRole'];
            final token = args?['token'];
            final nom = args?['nom'];
            final prenom = args?['prenom'];

            if (userEmail is String &&
                userRole is String &&
                token is String &&
                nom is String &&
                prenom is String) {
              return MaterialPageRoute(
                builder: (_) => MainScreen(
                  email: userEmail,
                  role: userRole,
                  token: token,
                  nom: nom,
                  prenom: prenom,
                ),
              );
            }
            return _errorRoute();

          case '/scan-qr':
            return MaterialPageRoute(builder: (_) => const ScanQrScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/profil':
            final userEmail = args?['userEmail'];
            final userRole = args?['userRole'];
            final token = args?['token'];
            final nom = args?['nom'];
            final prenom = args?['prenom'];

            if (userEmail is String &&
                userRole is String &&
                token is String &&
                nom is String &&
                prenom is String) {
              return MaterialPageRoute(
                builder: (_) => ProfilScreen(
                  userEmail: userEmail,
                  userRole: userRole,
                  token: token,
                  nom: nom,
                  prenom: prenom,
                  onLogout: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              );
            }
            return _errorRoute();

          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            );

          // 🔹 Routes Admin Station

          case '/agents-list':
            final token = args?['token'];
            final userId = args?['userId'];
            if (token is String && userId is String) {
              return MaterialPageRoute(
                builder: (_) =>
                    AgentsListScreen(token: token, adminStationId: userId),
              );
            }
            return _errorRoute();

          case '/creer-agent_station':
            final token = args?['token'];
            final userId = args?['userId'];
            if (token is String && userId is String) {
              return MaterialPageRoute(
                builder: (_) =>
                    CreerAgentScreen(token: token, adminStationId: userId),
              );
            }
            return _errorRoute();

          // 🔹 Routes Carburants
          case '/carburants-list':
            final token = args?['token'];
            final adminStationId = args?['adminStationId'];
            if (token is String && adminStationId is String) {
              return MaterialPageRoute(
                builder: (_) => CarburantsListScreen(
                  token: token,
                  adminStationId: adminStationId,
                ),
              );
            }
            return _errorRoute();

          case '/creer-carburant':
            final token = args?['token'];
            final adminStationId = args?['adminStationId'];
            if (token is String && adminStationId is String) {
              return MaterialPageRoute(
                builder: (_) => CreerCarburantScreen(
                  token: token,
                  adminStationId: adminStationId,
                ),
              );
            }
            return _errorRoute();

          // 🔹 Routes Chauffeur
          case '/ticket':
            final token = args?['token'];
            if (token is String) {
              return MaterialPageRoute(
                builder: (_) => TicketScreen(token: token),
              );
            }
            return _errorRoute();

          case '/ticket-list':
            final token = args?['token'];
            if (token is String) {
              return MaterialPageRoute(
                builder: (_) => TicketHistoryScreen(token: token),
              );
            }
            return _errorRoute();

          default:
            return _errorRoute();
        }
      },
    );
  }

  Route _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: const Center(
          child: Text("Page non trouvée ou arguments manquants"),
        ),
      ),
    );
  }
}
