import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:faso_carbu_mobile/models/demande_ticket.dart';

class LocalRequestScreen extends StatefulWidget {
  const LocalRequestScreen({super.key});

  @override
  State<LocalRequestScreen> createState() => _LocalRequestScreenState();
}

class _LocalRequestScreenState extends State<LocalRequestScreen> {
  List<DemandeTicket> demandes = [];

  @override
  void initState() {
    super.initState();
    chargerDemandesLocales();
  }

  Future<void> chargerDemandesLocales() async {
    final data = await DatabaseHelper.instance.getLocalDemandes();
    setState(() {
      demandes = data;
    });
  }

  Future<void> supprimerDemande(String id) async {
    await DatabaseHelper.instance.deleteDemande(id);
    await chargerDemandesLocales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demandes Locales"),
        backgroundColor: Colors.teal,
      ),
      body: demandes.isEmpty
          ? const Center(child: Text("Aucune demande locale trouvée."))
          : ListView.builder(
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final demande = demandes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text("🛢 Station : ${demande.stationNom} (${demande.stationVille})"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📍 Adresse : ${demande.stationAdresse}"),
                        Text("📅 Date : ${demande.dateDemande}"),
                        Text("⛽ Quantité : ${demande.quantite} L"),
                        Text("🔋 Carburant ID : ${demande.carburantId}"),
                        Text("🚗 Véhicule : ${demande.vehiculeImmatriculation}"),
                        Text("👤 Demandeur : ${demande.demandeur}"),
                        Text("📌 Statut : ${demande.statut }"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => supprimerDemande(demande.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
