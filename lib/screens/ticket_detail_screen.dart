import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  Color _getStatusColor(String statut) {
    switch (statut) {
      case "VALIDE":
        return Colors.green;
      case "EN_ATTENTE":
        return Colors.orange;
      case "UTILISE":
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = ticket['statut'] ?? "-";

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎟️ Détail Ticket"),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔹 Bandeau
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "🏢 ${ticket['entrepriseNom'] ?? 'Entreprise'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(statut),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statut,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Infos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${ticket['carburantNom'] ?? 'Carburant'} • ${ticket['quantite'] ?? 0} L",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Text(
                      "💰 Somme : ${ticket['somme'] ?? 0} FCFA",
                    ), // 🔹 affichage somme
                    Text(
                      "👨 Chauffeur : ${ticket['utilisateurNom'] ?? '-'} ${ticket['utilisateurPrenom'] ?? ''}",
                    ),
                    Text(
                      "🛠 Validateur : ${ticket['validateurNom'] ?? '-'} ${ticket['validateurPrenom'] ?? ''}",
                    ),
                    Text(
                      "🚘 Véhicule : ${ticket['vehiculeImmatriculation'] ?? '-'}",
                    ),
                    Text("⛽ Station : ${ticket['stationNom'] ?? '-'}"),
                    Text("📅 Émis le : ${ticket['dateEmission'] ?? '-'}"),
                    Text("✅ Validé le : ${ticket['dateValidation'] ?? '-'}"),
                  ],
                ),
              ),

              // 🔹 QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: (ticket['codeQr'] != null)
                    ? QrImageView(data: ticket['codeQr'], size: 150)
                    : const Icon(Icons.qr_code, color: Colors.grey, size: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
