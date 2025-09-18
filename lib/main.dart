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
import 'package:faso_carbu_mobile/screens/ticket-list-agent.dart';
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

        // Sécuriser la récupération des arguments
        final Map<String, dynamic> args =
            (settings.arguments as Map<String, dynamic>?) ?? {};

        switch (settings.name) {
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/home':
            final args = (settings.arguments as Map<String, dynamic>?) ?? {};
            final token = args['token']?.toString() ?? '';
            final userEmail = args['userEmail'] ?? '';
            final userRole = args['userRole'] ?? '';
            final nom = args['nom'] ?? '';
            final prenom = args['prenom'] ?? '';

            if (token.isNotEmpty &&
                userEmail.isNotEmpty &&
                userRole.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => MainScreen(
                  email: userEmail,
                  role: userRole,
                  token: token,
                  nom: nom,
                  prenom: prenom,
                ),
              );
            } else {
              return _errorRoute('/home', args);
            }

          case '/scan-qr':
            final token = args['token']?.toString() ?? '';
            final userId = args['userId']?.toString() ?? '';
            if (token.isNotEmpty && userId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => ScanQrScreen(token: token, userId: userId),
              );
            }
            return _errorRoute('/scan-qr', args);

          case '/profil':
            final token = args['token']?.toString() ?? '';
            if (token.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => ProfilScreen(
                  userEmail: args['userEmail'] ?? '',
                  userRole: args['userRole'] ?? '',
                  token: token,
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
            }
            return _errorRoute('/profil', args);

          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            );

          // Admin Station
          case '/agents-list':
            final token = args['token']?.toString() ?? '';
            final adminStationId = args['adminStationId']?.toString() ?? '';
            if (token.isNotEmpty && adminStationId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => AgentsListScreen(
                  token: token,
                  adminStationId: adminStationId,
                ),
              );
            }
            return _errorRoute('/agents-list', args);

          case '/creer-agent_station':
            final token = args['token']?.toString() ?? '';
            final adminStationId = args['adminStationId']?.toString() ?? '';
            if (token.isNotEmpty && adminStationId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => CreerAgentScreen(
                  token: token,
                  adminStationId: adminStationId,
                ),
              );
            }
            return _errorRoute('/creer-agent_station', args);

          case '/carburants-list':
            final token = args['token']?.toString() ?? '';
            final adminStationId = args['adminStationId']?.toString() ?? '';
            if (token.isNotEmpty && adminStationId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => CarburantsListScreen(
                  token: token,
                  adminStationId: adminStationId,
                ),
              );
            }
            return _errorRoute('/carburants-list', args);

          case '/creer-carburant':
            final token = args['token']?.toString() ?? '';
            final adminStationId = args['adminStationId']?.toString() ?? '';
            if (token.isNotEmpty && adminStationId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => CreerCarburantScreen(
                  token: token,
                  adminStationId: adminStationId,
                ),
              );
            }
            return _errorRoute('/creer-carburant', args);

          // Chauffeur
          case '/ticket':
            final token = args['token']?.toString() ?? '';
            if (token.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => TicketScreen(token: token),
              );
            }
            return _errorRoute('/ticket', args);

          case '/ticket-list':
            final token = args['token']?.toString() ?? '';
            if (token.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => TicketHistoryScreen(token: token),
              );
            }
            return _errorRoute('/ticket-list', args);

          case '/ticket-list-agent':
            final token = args['token']?.toString() ?? '';
            final agentId = args['userId']?.toString() ?? '';
            if (token.isNotEmpty && agentId.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) =>
                    TicketListAgentScreen(token: token, agentId: agentId),
              );
            }
            return _errorRoute('/ticket-list-agent', args);

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
