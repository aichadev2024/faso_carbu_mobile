class Vehicule {
  final String id;
  final String immatriculation;
  final String? marque;
  final String? type;
  final String? chauffeurId;

  Vehicule({
    required this.id,
    required this.immatriculation,
    this.marque,
    this.type,
    this.chauffeurId,
  });

  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      id: json['id'],
      immatriculation: json['immatriculation'],
      marque: json['marque'],
      type: json['type'],
      chauffeurId: json['chauffeur']?['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'immatriculation': immatriculation,
      'marque': marque,
      'type': type,
      'chauffeurId': chauffeurId,
    };
  }
}
