import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'creer_carburant_screen.dart';

class CarburantsListScreen extends StatefulWidget {
  final String token;
  final String adminStationId;

  const CarburantsListScreen({
    super.key,
    required this.token,
    required this.adminStationId,
  });

  @override
  State<CarburantsListScreen> createState() => _CarburantsListScreenState();
}

class _CarburantsListScreenState extends State<CarburantsListScreen> {
  List carburants = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCarburants();
  }

  Future<void> fetchCarburants() async {
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
        "https://faso-carbu-backend-2.onrender.com/api/admin-stations/${widget.adminStationId}/carburants",
      ),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      setState(() {
        carburants = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur chargement : ${response.body}")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> supprimerCarburant(int carburantId) async {
    final response = await http.delete(
      Uri.parse(
        "https://faso-carbu-backend-2.onrender.com/api/admin-stations/carburants/$carburantId",
      ),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Carburant supprimé")));
      fetchCarburants();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur suppression : ${response.body}")),
      );
    }
  }

  Future<void> modifierCarburant(Map carburant) async {
    final nomController = TextEditingController(text: carburant['nom']);
    final prixController = TextEditingController(
      text: carburant['prix'].toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text("Modifier Carburant"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: "Nom",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Prix (FCFA)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final response = await http.put(
                Uri.parse(
                  "https://faso-carbu-backend-2.onrender.com/api/admin-stations/${widget.adminStationId}/carburants/${carburant['id']}",
                ),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer ${widget.token}",
                },
                body: jsonEncode({
                  "nom": nomController.text,
                  "prix": double.tryParse(prixController.text) ?? 0,
                }),
              );

              Navigator.pop(context);

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Carburant modifié")),
                );
                fetchCarburants();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Erreur : ${response.body}")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.save),
            label: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void goToCreateCarburant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreerCarburantScreen(
          token: widget.token,
          adminStationId: widget.adminStationId,
        ),
      ),
    );

    if (result == true) {
      fetchCarburants();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("⛽ Liste Carburants"),
        backgroundColor: Colors.red.shade700,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToCreateCarburant,
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : carburants.isEmpty
          ? const Center(
              child: Text(
                "Aucun carburant trouvé",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: carburants.length,
              itemBuilder: (context, index) {
                final carburant = carburants[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.local_gas_station, color: Colors.white),
                    ),
                    title: Text(
                      carburant['nom'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Prix : ${carburant['prix']} FCFA",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => modifierCarburant(carburant),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => supprimerCarburant(carburant['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
