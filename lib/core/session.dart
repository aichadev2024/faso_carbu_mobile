import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Session de l'utilisateur connecté, persistée dans SharedPreferences
/// et gardée en mémoire après [Session.load] (appelé au démarrage).
class Session {
  Session._();

  static const _tokenKey = 'auth_token';

  static String token = '';
  static String userId = '';
  static String email = '';
  static String nom = '';
  static String prenom = '';
  static String role = '';

  static bool get isLoggedIn => token.isNotEmpty;

  static String get fullName => '$prenom $nom'.trim();

  static String get initials {
    final p = prenom.isNotEmpty ? prenom[0] : '';
    final n = nom.isNotEmpty ? nom[0] : '';
    final i = '$p$n'.toUpperCase();
    return i.isEmpty ? '?' : i;
  }

  static String get roleLabel => roleLabelOf(role);

  static String roleLabelOf(String role) {
    switch (role.toUpperCase().replaceFirst('ROLE_', '')) {
      case 'GESTIONNAIRE':
        return 'Gestionnaire';
      case 'DEMANDEUR':
        return 'Demandeur';
      case 'CHAUFFEUR':
        return 'Chauffeur';
      case 'ADMIN_STATION':
        return 'Admin station';
      case 'AGENT_STATION':
        return 'Agent station';
      default:
        return role;
    }
  }

  /// Arguments de route standard attendus par les écrans existants.
  static Map<String, dynamic> get routeArgs => {'jwtToken': token, 'userId': userId};

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString(_tokenKey) ?? '';
    userId = p.getString('userId') ?? '';
    email = p.getString('email') ?? '';
    nom = _fixUtf8(p.getString('nom') ?? '');
    prenom = _fixUtf8(p.getString('prenom') ?? '');
    role = p.getString('role') ?? '';
  }

  static Future<void> save({
    required String token,
    required String userId,
    required String email,
    required String nom,
    required String prenom,
    required String role,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
    await p.setString('userId', userId);
    await p.setString('email', email);
    await p.setString('nom', nom);
    await p.setString('prenom', prenom);
    await p.setString('role', role);
    await load();
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [_tokenKey, 'userId', 'email', 'nom', 'prenom', 'role']) {
      await p.remove(k);
    }
    token = userId = email = nom = prenom = role = '';
  }

  /// Corrige les accents mal décodés (latin-1 lu comme UTF-8).
  static String _fixUtf8(String value) {
    try {
      return utf8.decode(value.runes.toList());
    } catch (_) {
      return value;
    }
  }
}
