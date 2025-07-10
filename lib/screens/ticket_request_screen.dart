import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/demande_ticket.dart';

class TicketRequestScreen extends StatefulWidget {
  final String token;

  const TicketRequestScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<TicketRequestScreen> createState() => _TicketRequestScreenState();
}

class _TicketRequestScreenState extends State<TicketRequestScreen> {
  final _quantiteController = TextEditingController();
  final _stationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _message;

  Future<void> _soumettreDemande() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'anonyme';
    final uuid = const Uuid();

    final demande = DemandeTicket(
      id: uuid.v4(), // ID unique
      demandeur: email,
      station: _stationController.text.trim(),
      dateDemande: DateTime.now().toIso8601String(),
      quantite: double.parse(_quantiteController.text),
    );

    final isOnline = await Connectivity().checkConnectivity() != ConnectivityResult.none;

    try {
      if (isOnline) {
        final response = await http.post(
          Uri.parse('http://192.168.1.2:8080/api/demandes'), // ⚠️ adapte l'URL à ton backend
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode(demande.toMap()),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          setState(() {
            _message = "✅ Demande envoyée avec succès.";
          });
        } else {
          await DatabaseHelper.instance.insertDemande(demande.toMap());
          setState(() {
            _message = "⚠️ Erreur serveur. Demande enregistrée localement.";
          });
        }
      } else {
        await DatabaseHelper.instance.insertDemande(demande.toMap());
        setState(() {
          _message = "📴 Hors ligne. Demande enregistrée localement.";
        });
      }

      _quantiteController.clear();
      _stationController.clear();
    } catch (e) {
      await DatabaseHelper.instance.insertDemande(demande.toMap());
      setState(() {
        _message = "❌ Erreur réseau. Demande sauvegardée en local.";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de Ticket'),
        backgroundColor: const Color.fromARGB(255, 76, 162, 175)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _stationController,
                decoration: const InputDecoration(labelText: "Nom de la station"),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Station requise' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantité (litres)"),
                validator: (value) {
                  final quantite = double.tryParse(value ?? '');
                  if (quantite == null || quantite <= 0) return 'Quantité invalide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Soumettre"),
                      onPressed: _soumettreDemande,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 76, 175, 117),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),
                    ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains("❌") || _message!.contains("⚠️")
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
