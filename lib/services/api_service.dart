import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:faso_carbu_mobile/models/user_model.dart';
import 'package:faso_carbu_mobile/models/ticket.dart';
import 'package:faso_carbu_mobile/models/carburant.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class ApiService {
  static const String baseUrl = 'https://faso-carbu-backend-2.onrender.com/api';

  // ✅ Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    logger.i('TOKEN SAUVEGARDÉ : $token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ✅ Auth
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "motDePasse": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['userId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('userId', userId.toString());

        logger.i('✅ Connexion réussie. Token : $token');
        return true;
      } else {
        logger.i('❌ Erreur login : ${response.body}');
        return false;
      }
    } catch (e) {
      logger.i('❌ Exception login : $e');
      return false;
    }
  }

  static Future<List<Ticket>> fetchTicketsOnline() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tickets'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final tickets = jsonData.map((e) => Ticket.fromJson(e)).toList();

      await DatabaseHelper.instance.saveTicketsOffline(
        tickets.map((t) => t.toMap()).toList(),
      );
      return tickets;
    } else {
      throw Exception('Erreur de chargement des tickets');
    }
  }

  static Future<List<Ticket>> fetchTicketsOffline() async {
    return await DatabaseHelper.instance.getAllTickets();
  }

  static Future<void> submitTicket(Ticket ticket) async {
    final token = await getToken();
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity != ConnectivityResult.none) {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ticket.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final syncedTicket = Ticket.fromJson(jsonDecode(response.body));
        await DatabaseHelper.instance.insertTicket(syncedTicket.toMap());
      } else {
        throw Exception("Échec de l'envoi du ticket");
      }
    } else {
      await DatabaseHelper.instance.insertTicket(ticket.toMap());
    }
  }

  static Future<void> syncOfflineTickets() async {
    final token = await getToken();
    final offlineTickets = await DatabaseHelper.instance.getUnsyncedTickets();

    for (var ticket in offlineTickets) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/tickets'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(ticket.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await DatabaseHelper.instance.markTicketAsSynced(
            ticket.id.toString(),
          );
        }
      } catch (_) {}
    }
  }

  static Future<void> registerUser(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur d\'enregistrement');
    }
  }

  static Future<void> syncOfflineUsers() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final offlineUsers = await DatabaseHelper.instance.getUnsyncedUsers();

    for (UserModel user in offlineUsers) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/users/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await DatabaseHelper.instance.markUserAsSynced(user.id!);
        }
      } catch (_) {}
    }
  }

  static Future<void> createDemande(Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/demandes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    logger.i('Demande ➜ Code ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Échec de la création de la demande');
    }
  }

  static Future<List<dynamic>> getDemandesByChauffeur() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/demandes/mes-demandes'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des demandes');
    }
  }

  static Future<List<dynamic>> getDemandesByStatut(String statut) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/demandes/statut/$statut'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des demandes');
    }
  }

  // ✅ Carburants
  static Future<List<Carburant>> fetchCarburants() async {
    final response = await http.get(Uri.parse('$baseUrl/carburants'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Carburant.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des carburants');
    }
  }

  static Future<void> syncCarburants() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    try {
      final response = await http.get(Uri.parse('$baseUrl/carburants'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final carburants = data.map((e) => Carburant.fromJson(e)).toList();

        // Supprimer les anciens carburants
        await DatabaseHelper.instance.clearCarburants();

        // Insérer les nouveaux carburants
        for (Carburant carburant in carburants) {
          await DatabaseHelper.instance.insertCarburant(carburant);
        }
      } else {
        throw Exception('Échec de la récupération des carburants');
      }
    } catch (e) {
      logger.e('Erreur de synchronisation carburants : $e');
    }
  }
}
