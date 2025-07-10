class DemandeTicket {
  String id;
  String demandeur;
  String station;
  String dateDemande;
  double quantite;
  String statut;
  String commentaire;

  DemandeTicket({
    required this.id,
    required this.demandeur,
    required this.station,
    required this.dateDemande,
    required this.quantite,
    this.statut = 'En attente',
    this.commentaire = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'demandeur': demandeur,
      'station': station,
      'dateDemande': dateDemande,
      'quantite': quantite,
      'statut': statut,
      'commentaire': commentaire,
    };
  }

  factory DemandeTicket.fromMap(Map<String, dynamic> map) {
    return DemandeTicket(
      id: map['id'],
      demandeur: map['demandeur'],
      station: map['station'],
      dateDemande: map['dateDemande'],
      quantite: map['quantite'],
      statut: map['statut'] ?? 'En attente',
      commentaire: map['commentaire'] ?? '',
    );
  }
}
