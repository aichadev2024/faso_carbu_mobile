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
import 'package:faso_carbu_mobile/screens/ticket_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_history_screen.dart';
import 'package:faso_carbu_mobile/screens/carburants_list_screen.dart';
import 'package:faso_carbu_mobile/screens/creer_carburant_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_list_agent_screen.dart';
import 'package:faso_carbu_mobile/screens/onboarding_screen.dart';
import 'package:logger/logger.dart';

var logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    _handleMessageNavigation(message);
  });

  RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    Future.delayed(const Duration(seconds: 1), () {
      _handleMessageNavigation(initialMessage);
    });
  }

  final fcmToken = await FirebaseMessaging.instance.getToken();
  logger.i("📱 Token FCM : $fcmToken");

  runApp(const FasoCarbuApp());
}

void _handleMessageNavigation(RemoteMessage message) {
  final data = message.data;
  logger.i("📦 Données de la notification : $data");

  final route = data['route'];
  if (route != null && navigatorKey.currentState != null) {
    navigatorKey.currentState!.pushNamed(route, arguments: data);
  } else {
    logger.w("⚠️ Aucune route trouvée dans la notification");
  }
}

class FasoCarbuApp extends StatelessWidget {
  const FasoCarbuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FasoCarbu',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/onboarding',
      onGenerateRoute: (settings) {
        logger.i(
          "➡️ onGenerateRoute appelée avec route: ${settings.name}, args: ${settings.arguments}",
        );

        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ?? {};

        switch (settings.name) {
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/home':
            return MaterialPageRoute(
              builder: (_) => MainScreen(
                email: args['userEmail'] ?? '',
                role: args['userRole'] ?? '',
                token: args['token'] ?? '',
                nom: args['nom'] ?? '',
                prenom: args['prenom'] ?? '',
              ),
            );

          case '/ticket':
            return MaterialPageRoute(
              builder: (_) => TicketScreen(token: args['token'] ?? ''),
            );

          case '/ticket-list':
            return MaterialPageRoute(
              builder: (_) => TicketHistoryScreen(token: args['token'] ?? ''),
            );

          case '/ticket-list-agent':
            return MaterialPageRoute(
              builder: (_) => TicketListAgentScreen(
                token: args['token'] ?? '',
                agentId: args['userId'] ?? '',
              ),
            );

          case '/scan-qr':
            return MaterialPageRoute(
              builder: (_) => ScanQrScreen(
                token: args['token'] ?? '',
                userId: args['userId'] ?? '',
              ),
            );

          // Admin Station
          case '/agents-list':
            return MaterialPageRoute(
              builder: (_) => AgentsListScreen(
                token: args['token'] ?? '',
                adminStationId: args['adminStationId'] ?? '',
              ),
            );

          case '/carburants-list':
            return MaterialPageRoute(
              builder: (_) => CarburantsListScreen(
                token: args['token'] ?? '',
                adminStationId: args['adminStationId'] ?? '',
              ),
            );

          case '/creer-agent_station':
            return MaterialPageRoute(
              builder: (_) => CreerAgentScreen(
                token: args['token'] ?? '',
                adminStationId: args['adminStationId'] ?? '',
              ),
            );

          case '/creer-carburant':
            return MaterialPageRoute(
              builder: (_) => CreerCarburantScreen(
                token: args['token'] ?? '',
                adminStationId: args['adminStationId'] ?? '',
              ),
            );

          case '/profil':
            return MaterialPageRoute(
              builder: (_) => ProfilScreen(
                userEmail: args['userEmail'] ?? '',
                userRole: args['userRole'] ?? '',
                token: args['token'] ?? '',
                nom: args['nom'] ?? '',
                prenom: args['prenom'] ?? '',
                onLogout: () {
                  Navigator.pushNamedAndRemoveUntil(
                    navigatorKey.currentContext!,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            );

          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            );

          default:
            return _errorRoute(settings.name, args);
        }
      },
    );
  }

  Route _errorRoute([String? routeName, dynamic args]) {
    logger.w("⚠️ Erreur de navigation ! Route: $routeName, args: $args");
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: Center(
          child: Text(
            "Page non trouvée ou arguments manquants\nRoute: $routeName\nArgs: $args",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
