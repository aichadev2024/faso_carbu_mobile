import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faso_carbu_mobile/services/local_request_service.dart';
import 'package:faso_carbu_mobile/models/demande_ticket.dart';
import 'package:logger/logger.dart';

var logger = Logger();


class TicketRequestScreen extends StatefulWidget {
  final String token;

  const TicketRequestScreen({super.key, required this.token});

  @override
  State<TicketRequestScreen> createState() => _TicketRequestScreenState();
}

class _TicketRequestScreenState extends State<TicketRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs station
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _villeStationController = TextEditingController();
  final TextEditingController _adresseStationController = TextEditingController();

  // Contrôleurs véhicule
  final TextEditingController _immatController = TextEditingController();
  final TextEditingController _typeVehiculeController = TextEditingController();
  final TextEditingController _marqueVehiculeController = TextEditingController();

  // Quantité
  final TextEditingController _quantiteController = TextEditingController();

  // Carburants
  List<Map<String, dynamic>> carburants = [];
  String? selectedCarburantId;
  bool isLoadingCarburants = true;

  @override
  void initState() {
    super.initState();
    _fetchCarburants();
  }

  Future<void> _fetchCarburants() async {
    try {
      final response = await http.get(
        Uri.parse('https://faso-carbu-backend-2.onrender.com/api/carburants'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          carburants = data.cast<Map<String, dynamic>>();
          isLoadingCarburants = false;
        });
      } else {
        throw Exception('Erreur chargement carburants');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingCarburants = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Erreur réseau. Carburants non chargés.')),
      );
    }
  }

  Future<void> _soumettreDemande() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    logger.i("🧾 userId depuis SharedPreferences: $userId");

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Utilisateur non connecté')),
      );
      return;
    }

    final demande = DemandeTicket(
      demandeur: userId,
      stationId: _stationController.text.trim(),
      stationVille: _villeStationController.text.trim(),
      stationAdresse: _adresseStationController.text.trim(),
      vehiculeImmatriculation: _immatController.text.trim(),
      dateDemande: DateTime.now().toIso8601String(),
      quantite: double.tryParse(_quantiteController.text.trim()) ?? 0.0,
      carburantId: selectedCarburantId ?? '',
    );

    final body = jsonEncode(demande.toMap(forBackend: true));

    try {
      final response = await http.post(
        Uri.parse('https://faso-carbu-backend-2.onrender.com/api/demandes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: body,
      );

      logger.i("🛰️ [POST /demandes] Status code: ${response.statusCode}");
      logger.i("📦 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Demande envoyée avec succès')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Erreur serveur');
      }
    } catch (e) {
      logger.e("💥 Erreur POST demande: $e");
      await LocalRequestService.saveLocalRequest(demande.toMap(forBackend: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('💾 Erreur réseau. Demande sauvegardée localement.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demander un Ticket'),
        backgroundColor: const Color.fromARGB(255, 68, 184, 216),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Nom de la station", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stationController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Station Total Pissy',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              const Text("Ville de la station", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _villeStationController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Ouagadougou',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Adresse de la station", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adresseStationController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Avenue Charles De Gaulle',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Type de carburant", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              isLoadingCarburants
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedCarburantId,
                      hint: const Text("Choisir un carburant"),
                      items: carburants
                          .map((c) => DropdownMenuItem(
                                value: c['id'].toString(),
                                child: Text("${c['nom']} - ${c['prix']} FCFA/L"),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => selectedCarburantId = val),
                      validator: (value) => value == null ? 'Sélectionnez un carburant' : null,
                    ),
              const SizedBox(height: 16),

              const Text("Quantité (en litres)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ex: 10',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final q = double.tryParse(value ?? '');
                  if (q == null || q <= 0) return 'Entrez une quantité valide';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text("Informations véhicule", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _immatController,
                decoration: const InputDecoration(
                  hintText: 'Immatriculation (ex: 11AA1234)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Immatriculation requise' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeVehiculeController,
                decoration: const InputDecoration(
                  hintText: 'Type de véhicule (ex: Camion)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marqueVehiculeController,
                decoration: const InputDecoration(
                  hintText: 'Marque (ex: Toyota)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _soumettreDemande,
                icon: const Icon(Icons.send),
                label: const Text("Soumettre la demande"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 77, 205, 164),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
