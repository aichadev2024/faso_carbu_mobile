import 'package:flutter/material.dart';

// Import des écrans
import 'package:faso_carbu_mobile/screens/login_screen.dart';
import 'package:faso_carbu_mobile/screens/register_screen.dart';
import 'package:faso_carbu_mobile/screens/home_screen.dart';
import 'package:faso_carbu_mobile/screens/scan_qr_screen.dart';
import 'package:faso_carbu_mobile/screens/valider_demandes_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_request_screen.dart';
import 'package:faso_carbu_mobile/screens/ticket_list_screen.dart';
import 'package:faso_carbu_mobile/screens/stats_screen.dart';
import 'package:faso_carbu_mobile/screens/profile_screen.dart';

void main () {
 

  runApp(const FasoCarbuApp());
}

class FasoCarbuApp extends StatelessWidget {
  const FasoCarbuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FasoCarbu',
      theme: ThemeData(primarySwatch: Colors.green),

     onGenerateRoute: (settings) {
  final args = settings.arguments as Map<String, dynamic>?;

  switch (settings.name) {
    case '/home':
      return MaterialPageRoute(
        builder: (_) => HomeScreen(
          userEmail: args?['userEmail'] ?? '',
          userRole: args?['userRole'] ?? '',
          token: args?['token'] ?? '',
          nom: args?['nom']??'',
          prenom: args?['prenom']??'',
        ),
      );
    case '/scan-qr':
      return MaterialPageRoute(builder: (_) => const ScanQrScreen());
    case '/valider-demandes':
      return MaterialPageRoute(builder: (_) => const ValiderDemandesScreen());
    case '/ticket-request':
      return MaterialPageRoute(
        builder: (_) => TicketRequestScreen(
          token: args?['token'] ?? '',
        ),
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
        builder: (_) => StatsScreen(
          token: args?['token'] ?? '',
        ),
      );
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case '/profil':
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    default:
      return null;
  }
  
},


      // Toujours commencer par l'écran de connexion
      home: const LoginScreen(),
    );
  }
}
