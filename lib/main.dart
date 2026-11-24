import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'core/notification_store.dart';
import 'core/session.dart';
import 'core/theme/app_theme.dart';
import 'screens/agents_list_screen.dart';
import 'screens/carburants_list_screen.dart';
import 'screens/creer_agent_screen.dart';
import 'screens/creer_carburant_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/ticket_history_screen.dart';
import 'screens/ticket_list_agent_screen.dart';
import 'screens/ticket_screen.dart';

final _log = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  final n = message.notification;
  if (n != null) await NotificationStore.add(titre: n.title ?? 'FasoCarbu', message: n.body ?? '');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.load();
  if (!kIsWeb) await _initPush();
  await NotificationStore.refreshUnread();
  runApp(const FasoCarbuApp());
}

/// Notifications push : enregistrées dans l'historique local et,
/// si elles portent une route, ouvrent l'écran correspondant.
Future<void> _initPush() async {
  try {
    await Firebase.initializeApp();
    final fm = FirebaseMessaging.instance;
    await fm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null) return;
      NotificationStore.add(titre: n.title ?? 'FasoCarbu', message: n.body ?? '');
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${n.title ?? ''} — ${n.body ?? ''}')));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_openFromNotification);
    final initial = await fm.getInitialMessage();
    if (initial != null) Future.delayed(const Duration(seconds: 1), () => _openFromNotification(initial));
  } catch (e) {
    _log.w('Notifications push indisponibles : $e');
  }
}

void _openFromNotification(RemoteMessage message) {
  final route = message.data['route'];
  if (route is String && Session.isLoggedIn) {
    navigatorKey.currentState?.pushNamed(route, arguments: message.data);
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      onGenerateRoute: _route,
    );
  }

  static Route<dynamic> _route(RouteSettings settings) {
    final token = Session.token;
    final userId = Session.userId;
    Widget page;
    switch (settings.name) {
      case '/onboarding':
        page = const OnboardingScreen();
      case '/login':
        page = const LoginScreen();
      case '/home':
        page = const MainScreen();
      case '/ticket':
        page = TicketScreen(token: token);
      case '/ticket-list':
        page = TicketHistoryScreen(token: token);
      case '/ticket-list-agent':
        page = TicketListAgentScreen(token: token, agentId: userId);
      case '/scan-qr':
        page = ScanQrScreen(token: token, userId: userId);
      case '/agents-list':
        page = AgentsListScreen(token: token, adminStationId: userId);
      case '/carburants-list':
        page = CarburantsListScreen(token: token, adminStationId: userId);
      case '/creer-agent_station':
        page = CreerAgentScreen(token: token, adminStationId: userId);
      case '/creer-carburant':
        page = CreerCarburantScreen(token: token, adminStationId: userId);
      case '/notifications':
        page = const NotificationScreen();
      default:
        page = Session.isLoggedIn ? const MainScreen() : const LoginScreen();
    }
    if (!Session.isLoggedIn && settings.name != '/onboarding') page = const LoginScreen();
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }
}
