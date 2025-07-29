import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/models/demande_ticket.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';

class HistoriqueValidationScreen extends StatefulWidget {
  const HistoriqueValidationScreen({super.key});

  @override
  State<HistoriqueValidationScreen> createState() => _HistoriqueValidationScreenState();
}

class _HistoriqueValidationScreenState extends State<HistoriqueValidationScreen> {
  List<DemandeTicket> _demandes = [];

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    final demandes = await DatabaseHelper.instance.getAllDemandes();
    setState(() {
      _demandes = demandes.where((d) => d.statut != 'en_attente').toList();
    });
  }

  String _getStatutText(String statut) {
    switch (statut.toLowerCase()) {
      case 'acceptee':
        return 'Acceptée';
      case 'rejetee':
        return 'Rejetée';
      default:
        return statut;
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'acceptee':
        return Colors.green;
      case 'rejetee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des validations"),
        backgroundColor: Colors.teal,
      ),
      body: _demandes.isEmpty
          ? const Center(child: Text("Aucune demande validée."))
          : ListView.builder(
              itemCount: _demandes.length,
              itemBuilder: (context, index) {
                final demande = _demandes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.local_gas_station, color: _getStatutColor(demande.statut)),
                    title: Text("🛢 ${demande.stationNom} (${demande.stationVille})"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📍 Adresse : ${demande.stationAdresse}"),
                        Text("⛽ Quantité : ${demande.quantite} L"),
                        Text("📅 Date : ${demande.dateDemande}"),
                        Text("🚗 Véhicule : ${demande.vehiculeImmatriculation}"),
                      ],
                    ),
                    trailing: Text(
                      _getStatutText(demande.statut),
                      style: TextStyle(
                        color: _getStatutColor(demande.statut),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
