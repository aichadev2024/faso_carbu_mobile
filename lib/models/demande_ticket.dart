import 'package:uuid/uuid.dart';

class DemandeTicket {
  final String id;
  final String demandeur; // Chauffeur (ID)
  final String dateDemande;
  final double quantite;
  final String carburantId;
  final String? dateValidation;
  final String? validateurId;
  final String statut;

  // Pour station
  final String? stationId;
  final String? stationNom;
  final String? stationVille;
  final String? stationAdresse;

  // Pour véhicule
  final String? vehiculeId;
  final String? vehiculeImmatriculation;

  DemandeTicket({
    String? id,
    required this.demandeur,
    required this.dateDemande,
    required this.quantite,
    required this.carburantId,
    this.stationId,
    this.stationNom,
    this.stationVille,
    this.stationAdresse,
    this.vehiculeId,
    this.vehiculeImmatriculation,
    this.dateValidation,
    this.validateurId,
    String? statut,
  })  : id = id ?? const Uuid().v4(),
        statut = statut ?? 'EN_ATTENTE';

  Map<String, dynamic> toMap({bool forBackend = false}) {
    final map = <String, dynamic>{
      'dateDemande': dateDemande,
      'quantite': quantite,
      'statutDemande': statut,
    };

    if (forBackend) {
      map['chauffeur'] = {'id': demandeur};
      map['carburant'] = {'id': carburantId};

      // Station
      if (stationId != null) {
        map['station'] = {'id': stationId};
      } else {
        map['station'] = {
          'nom': stationNom ?? '',
          'ville': stationVille ?? '',
          'adresse': stationAdresse ?? '',
        };
      }

      // Véhicule
      if (vehiculeId != null) {
        map['vehicule'] = {'id': vehiculeId};
      } else if (vehiculeImmatriculation != null) {
        map['vehicule'] = {'immatriculation': vehiculeImmatriculation};
      }

      if (validateurId != null) {
        map['validateur'] = {'id': validateurId};
      }
    } else {
      map['id'] = id;
      map['demandeur'] = demandeur;
      map['carburantId'] = carburantId;
      map['stationId'] = stationId;
      map['stationNom'] = stationNom;
      map['stationVille'] = stationVille;
      map['stationAdresse'] = stationAdresse;
      map['vehiculeId'] = vehiculeId;
      map['vehiculeImmatriculation'] = vehiculeImmatriculation;
      map['validateurId'] = validateurId;
    }

    if (dateValidation != null) {
      map['dateValidation'] = dateValidation;
    }

    return map;
  }

  factory DemandeTicket.fromMap(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value is String) return value;
      if (value is Map && value['id'] != null) return value['id'];
      return null;
    }

    return DemandeTicket(
      id: json['id'] ?? const Uuid().v4(),
      demandeur: extractId(json['chauffeur'] ?? json['demandeur']) ?? '',
      dateDemande: json['dateDemande'] ?? '',
      quantite: (json['quantite'] is num)
          ? (json['quantite'] as num).toDouble()
          : double.tryParse(json['quantite'].toString()) ?? 0.0,
      carburantId: extractId(json['carburant'] ?? json['carburantId']) ?? '',
      stationId: extractId(json['station']),
      stationNom: json['station']?['nom'],
      stationVille: json['station']?['ville'],
      stationAdresse: json['station']?['adresse'],
      vehiculeId: extractId(json['vehicule']),
      vehiculeImmatriculation: json['vehicule']?['immatriculation'],
      validateurId: extractId(json['validateur']),
      dateValidation: json['dateValidation'],
      statut: json['statutDemande'] ?? json['statut'] ?? 'EN_ATTENTE',
    );
  }
}
