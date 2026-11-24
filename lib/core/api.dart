import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config/app_config.dart';
import 'session.dart';

/// Erreur d'appel API avec un message affichable à l'utilisateur.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

/// Client HTTP minimal : ajoute le token de session, décode le JSON en UTF-8
/// et transforme les erreurs en messages lisibles.
class Api {
  Api._();

  static const _timeout = Duration(seconds: 20);

  static Map<String, String> _headers({bool auth = true}) => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (auth && Session.token.isNotEmpty) 'Authorization': 'Bearer ${Session.token}',
      };

  static Uri _uri(String path) => Uri.parse('${AppConfig.apiUrl}$path');

  static Future<dynamic> get(String path) => _send(() => http.get(_uri(path), headers: _headers()));

  static Future<dynamic> post(String path, [Object? body, bool auth = true]) =>
      _send(() => http.post(_uri(path), headers: _headers(auth: auth), body: body == null ? null : jsonEncode(body)));

  static Future<dynamic> put(String path, [Object? body]) =>
      _send(() => http.put(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body)));

  static Future<dynamic> delete(String path) => _send(() => http.delete(_uri(path), headers: _headers()));

  static Future<dynamic> _send(Future<http.Response> Function() call) async {
    http.Response res;
    try {
      res = await call().timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre.');
    } catch (_) {
      throw ApiException('Serveur injoignable. Vérifiez votre connexion.');
    }
    final text = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (text.isEmpty) return null;
      try {
        return jsonDecode(text);
      } catch (_) {
        return text;
      }
    }
    if (res.statusCode == 401) throw ApiException('Session expirée. Reconnectez-vous.', statusCode: 401);
    if (res.statusCode == 403) throw ApiException('Action non autorisée pour votre compte.', statusCode: 403);
    String message = 'Erreur ${res.statusCode}.';
    try {
      final body = jsonDecode(text);
      if (body is Map && body['message'] is String) message = body['message'];
    } catch (_) {
      if (text.isNotEmpty && text.length < 200) message = text;
    }
    throw ApiException(message, statusCode: res.statusCode);
  }

  static List<Map<String, dynamic>> asList(dynamic data) =>
      data is List ? data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];
}
