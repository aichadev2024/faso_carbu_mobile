import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'ticket_detail_screen.dart';

var logger = Logger();

class TicketHistoryScreen extends StatefulWidget {
  final String token;

  const TicketHistoryScreen({super.key, required this.token});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  List<dynamic> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://faso-carbu-backend-2.onrender.com/api/tickets/mes-tickets",
        ),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          // 🔹 On garde seulement les tickets utilisés
          tickets = data.where((t) => t['statut'] == 'UTILISE').toList();
          isLoading = false;
        });
      } else {
        logger.e("Erreur: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique Tickets"),
        backgroundColor: Colors.red.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? const Center(child: Text("Aucun ticket utilisé trouvé."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.red),
                    title: Text(
                      "Ticket #${ticket['id'] ?? ''}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Carburant: ${ticket['carburantNom'] ?? '---'}"),
                        Text("Quantité: ${ticket['quantite'] ?? ''} L"),
                        Text("Validé le: ${ticket['dateValidation'] ?? '---'}"),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailScreen(ticket: ticket),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
