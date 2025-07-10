import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:faso_carbu_mobile/models/ticket.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.2:8080/api'; // Adapté pour Android emulator

  // ✅ Récupérer les tickets en ligne
  static Future<List<Ticket>> fetchTicketsOnline(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tickets'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<Ticket> tickets =
          jsonData.map((json) => Ticket.fromJson(json)).toList();

      // 🔄 Sauvegarder offline aussi
      final List<Map<String, dynamic>> ticketsMap =
          tickets.map((t) => t.toMap()).toList();

      await DatabaseHelper.instance.saveTicketsOffline(tickets.map((t) =>t.toMap()).toList());
      return tickets;
    } else {
      throw Exception('Erreur serveur lors du chargement des tickets');
    }
  }

  // ✅ Récupérer les tickets depuis SQLite (offline)
  static Future<List<Ticket>> fetchTicketsOffline() async {
    return await DatabaseHelper.instance.getAllTickets();
  }

  // ✅ Envoyer une demande de ticket
  static Future<void> submitTicket(
      Ticket ticket, String token) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // ✅ En ligne → envoyer au serveur
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ticket.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Enregistrement online + synchronisation locale
        final json = jsonDecode(response.body);
        final syncedTicket = Ticket.fromJson(json);
        await DatabaseHelper.instance.insertTicket(syncedTicket.toMap());
      } else {
        throw Exception('Échec de l\'envoi du ticket');
      }
    } else {
      // ❌ Hors ligne → sauvegarde locale
      await DatabaseHelper.instance.insertTicket(ticket.toMap());
    }
  }

  // ✅ Synchroniser les tickets enregistrés hors ligne
  static Future<void> syncOfflineTickets(String token) async {
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
          await DatabaseHelper.instance.markTicketAsSynced(ticket.id.toString());
        }
      } catch (e) {
        // Ne rien faire → tentera plus tard
      }
    }
  }
}
