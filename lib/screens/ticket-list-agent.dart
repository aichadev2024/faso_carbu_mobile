import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketListAgentScreen extends StatefulWidget {
  final String token;
  final String agentId;

  const TicketListAgentScreen({
    super.key,
    required this.token,
    required this.agentId,
  });

  @override
  State<TicketListAgentScreen> createState() => _TicketListAgentScreenState();
}

class _TicketListAgentScreenState extends State<TicketListAgentScreen> {
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
          "https://faso-carbu-backend-2.onrender.com/api/tickets/agent/${widget.agentId}",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          tickets = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("Erreur API: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Historique Tickets"),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 3,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? const Center(
              child: Text(
                "Aucun ticket trouvé 🚫",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: Colors.red.shade100,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: ticket["status"] == "VALIDE"
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    title: Text(
                      "${ticket['chauffeurNom']} - ${ticket['carburant']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Quantité : ${ticket['quantite']}"),
                          Text("Date : ${ticket['date']}"),
                        ],
                      ),
                    ),
                    trailing: Text(
                      ticket["status"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ticket["status"] == "VALIDE"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
