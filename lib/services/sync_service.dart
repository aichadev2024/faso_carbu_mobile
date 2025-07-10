import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../db/database_helper.dart';
import '../models/ticket.dart';

class SyncService {
  final String baseUrl;

  SyncService({required this.baseUrl});

  Future<void> syncTickets(String token) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      final unsyncedTickets = await DatabaseHelper.instance.getUnsyncedTickets();

      for (final ticket in unsyncedTickets) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/api/tickets'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(ticket.toMap()),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            await DatabaseHelper.instance.markTicketAsSynced(ticket.id.toString());
          }
        } catch (e) {
          // Tu peux logguer les erreurs ici si besoin
        }
      }
    }
  }

  Future<void> saveTicketsFromServerOffline(List<Ticket> tickets) async {
    await DatabaseHelper.instance.saveTicketsOffline(
      tickets.map((t) => t.toMap()).toList()
    );
  }
}
