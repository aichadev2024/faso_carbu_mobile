import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreerCarburantScreen extends StatefulWidget {
  final String token;
  final String adminStationId;

  const CreerCarburantScreen({
    super.key,
    required this.token,
    required this.adminStationId,
  });

  @override
  State<CreerCarburantScreen> createState() => _CreerCarburantScreenState();
}

class _CreerCarburantScreenState extends State<CreerCarburantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prixController = TextEditingController();

  bool isLoading = false;

  Future<void> creerCarburant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse(
        "https://faso-carbu-backend-2.onrender.com/api/admin-stations/${widget.adminStationId}/carburants",
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

    setState(() => isLoading = false);

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Carburant ajouté avec succès")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Erreur : ${response.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("➕ Ajouter Carburant"),
        backgroundColor: Colors.red.shade700,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(
                  labelText: "Nom du carburant",
                  prefixIcon: const Icon(Icons.local_gas_station),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: prixController,
                decoration: InputDecoration(
                  labelText: "Prix (FCFA)",
                  prefixIcon: const Icon(Icons.monetization_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : creerCarburant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isLoading ? "En cours..." : "Créer",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
