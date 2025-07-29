
import 'package:faso_carbu_mobile/screens/carburant_screen.dart';
import 'package:faso_carbu_mobile/screens/local_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



// Import de tes écrans
import 'package:faso_carbu_mobile/screens/login_screen.dart';
import 'package:faso_carbu_mobile/screens/register_screen.dart';
import 'package:faso_carbu_mobile/screens/main_screen.dart';
import 'package:faso_carbu_mobile/screens/scan_qr_screen.dart';
import 'package:faso_carbu_mobile/screens/valider_demandes_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_request_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_list_screen.dart';
import 'package:faso_carbu_mobile/screens/stats_screen.dart';
import 'package:faso_carbu_mobile/screens/profil_screen.dart';
import 'package:faso_carbu_mobile/screens/notification_screen.dart';
import 'package:logger/logger.dart';
var logger = Logger();


// 🔥 Fonction pour gérer les notifications reçues en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  logger.i("🔔 Notification reçue en arrière-plan : ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔔 Gérer les notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔔 Obtenir et afficher le token
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

          case '/valider-demandes':
            return MaterialPageRoute(builder: (_) => const ValiderDemandesScreen());

          case '/ticket-request':
            return MaterialPageRoute(
              builder: (_) => TicketRequestScreen(token: args?['token'] ?? ''),
            );

          case '/ticket-list':
            return MaterialPageRoute(
              builder: (_) => TicketListScreen(
                token: args?['token'] ?? '',
                userEmail: args?['userEmail'] ?? '',
                userRole: args?['userRole'] ?? '',
              ),
            );

          case '/stats':
            return MaterialPageRoute(
              builder: (_) => StatsScreen(token: args?['token'] ?? ''),
            );

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

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
                        context, '/login', (route) => false);
                  },
                ),
              );
            } else {
              return _errorRoute();
            }


          case '/notifications':
            return MaterialPageRoute(builder: (_) => const NotificationScreen());
          case '/local-requests':
             return MaterialPageRoute(builder: (_) => const LocalRequestScreen());
          case '/carburants':
            return MaterialPageRoute(builder: (_)=>  CarburantsScreen());


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
        body: const Center(child: Text("Page non trouvée ou arguments manquants")),
      ),
    );
  }
}