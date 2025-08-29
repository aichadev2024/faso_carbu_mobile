import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ticket_detail_screen.dart';

class TicketScreen extends StatefulWidget {
  final String token;

  const TicketScreen({super.key, required this.token});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late Future<List<dynamic>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchTickets();
  }

  Future<List<dynamic>> fetchTickets() async {
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
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Erreur lors du chargement des tickets");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎟️ Mes Tickets"),
        backgroundColor: Colors.red.shade700,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun ticket trouvé"));
          }

          final tickets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_gas_station,
                    color: Colors.red,
                  ),
                  title: Text("Ticket #${ticket['id']}"),
                  subtitle: Text(
                    "Carburant: ${ticket['carburantNom']} - ${ticket['quantite']} L\n"
                    "Statut: ${ticket['statut']}",
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
          );
        },
      ),
    );
  }
}
