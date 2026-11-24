import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../core/widgets/mobile_widgets.dart';

/// Détail d'un ticket, avec son QR code à présenter en station.
class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticket});
  final Map<String, dynamic> ticket;

  String _person(String prefix) =>
      '${ticket['${prefix}Prenom'] ?? ''} ${ticket['${prefix}Nom'] ?? ''}'.trim();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final statut = '${ticket['statut'] ?? ''}'.toUpperCase();
    final aUtiliser = statut == 'EN_ATTENTE';
    final qr = ticket['codeQr']?.toString();
    final qte = double.tryParse('${ticket['quantite'] ?? 0}') ?? 0;
    final somme = double.tryParse('${ticket['somme'] ?? ticket['montant'] ?? 0}') ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Ticket #${ticket['id'] ?? ''}')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(children: [
                StatusBadge.fromStatus(ticket['statut']?.toString()),
                const SizedBox(height: AppSpacing.lg),
                Text('${formatNumber(qte)} L', style: t.displaySmall),
                Text('${ticket['carburantNom'] ?? 'Carburant'} · ${formatNumber(somme)} FCFA', style: t.bodyLarge),
                const SizedBox(height: AppSpacing.xl),
                if (qr != null && qr.isNotEmpty)
                  Opacity(
                    opacity: aUtiliser ? 1 : 0.35,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: QrImageView(data: qr, size: 220),
                    ),
                  )
                else
                  const InlineAlert(tone: Tone.warning, message: 'QR code indisponible pour ce ticket.'),
                const SizedBox(height: AppSpacing.md),
                Text(
                  aUtiliser
                      ? 'Présentez ce code à l\'agent de la station.'
                      : 'Ce ticket a déjà été utilisé ou n\'est plus valable.',
                  style: t.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Column(children: [
                KeyValueRow(icon: Icons.place_outlined, label: 'Station', value: '${ticket['stationNom'] ?? ''}'),
                KeyValueRow(icon: Icons.directions_car_outlined, label: 'Véhicule', value: '${ticket['vehiculeImmatriculation'] ?? ''}'),
                KeyValueRow(icon: Icons.badge_outlined, label: 'Chauffeur', value: _person('utilisateur')),
                KeyValueRow(icon: Icons.business_outlined, label: 'Entreprise', value: '${ticket['entrepriseNom'] ?? ''}'),
                KeyValueRow(
                  icon: Icons.event_outlined,
                  label: 'Émis le',
                  value: formatDate(DateTime.tryParse('${ticket['dateEmission'] ?? ''}'), withTime: true),
                ),
                if (ticket['dateValidation'] != null) ...[
                  KeyValueRow(
                    icon: Icons.task_alt_rounded,
                    label: 'Validé le',
                    value: formatDate(DateTime.tryParse('${ticket['dateValidation']}'), withTime: true),
                  ),
                  KeyValueRow(icon: Icons.person_pin_outlined, label: 'Validé par', value: _person('validateur')),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
