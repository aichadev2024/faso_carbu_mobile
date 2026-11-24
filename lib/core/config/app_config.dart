import 'package:flutter/foundation.dart';

/// Configuration injectée à la compilation :
///   flutter run --dart-define=API_URL=http://192.168.1.20:9090
///   flutter build apk --dart-define=API_URL=https://api.fasocarbu.bf
class AppConfig {
  AppConfig._();

  static const String _fromEnv = String.fromEnvironment('API_URL');

  /// Racine du backend, sans `/api`. Par défaut : le backend local
  /// (10.0.2.2 = la machine hôte vue depuis l'émulateur Android).
  static String get backendUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kIsWeb) return 'http://localhost:9090';
    return defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:9090' : 'http://localhost:9090';
  }

  static String get apiUrl => '$backendUrl/api';
}
