import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'creer_agent_screen.dart';

class AgentsListScreen extends StatefulWidget {
  final String token;
  final String adminStationId; // ✅ correction

  const AgentsListScreen({
    super.key,
    required this.token,
    required this.adminStationId,
  });

  @override
  State<AgentsListScreen> createState() => _AgentsListScreenState();
}

class _AgentsListScreenState extends State<AgentsListScreen> {
  List agents = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
        "https://faso-carbu-backend-2.onrender.com/api/admin-stations/${widget.adminStationId}/agents",
      ),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      setState(() {
        agents = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur chargement agents : ${response.body}"),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> supprimerAgent(String agentId) async {
    final response = await http.delete(
      Uri.parse(
        "https://faso-carbu-backend-2.onrender.com/api/admin-stations/agents/$agentId", // ✅ correction endpoint
      ),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Agent supprimé")));
      fetchAgents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur suppression : ${response.body}")),
      );
    }
  }

  void goToCreateAgent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreerAgentScreen(
          token: widget.token,
          adminStationId: widget.adminStationId, // ✅ correction
        ),
      ),
    );

    if (result == true) {
      fetchAgents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Liste des Agents"),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToCreateAgent,
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agents.isEmpty
          ? const Center(
              child: Text(
                "Aucun agent trouvé",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: agents.length,
              itemBuilder: (context, index) {
                final agent = agents[index];
                final nom = agent['nom'] ?? '';
                final prenom = agent['prenom'] ?? '';
                final email = agent['email'] ?? '';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade700,
                      child: Text(
                        prenom.isNotEmpty ? prenom[0].toUpperCase() : "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      "$prenom $nom",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade700),
                      onPressed: () => supprimerAgent(agent['id'].toString()),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
