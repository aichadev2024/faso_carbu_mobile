import 'package:flutter/material.dart';

class ValiderDemandesScreen extends StatelessWidget {
  const ValiderDemandesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de données factices
    final demandes = [
      {
        'nom': 'Ali Traoré',
        'quantite': '20L',
        'station': 'Station Total',
      },
      {
        'nom': 'Awa Coulibaly',
        'quantite': '15L',
        'station': 'Station Shell',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Demandes à valider"),
      ),
      body: ListView.builder(
        itemCount: demandes.length,
        itemBuilder: (context, index) {
          final demande = demandes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text("${demande['nom']} - ${demande['quantite']}"),
              subtitle: Text("Station : ${demande['station']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      // Valider
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      // Rejeter
                    },
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