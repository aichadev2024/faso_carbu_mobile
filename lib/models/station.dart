class Station {
  final String id;
  final String nom;
  final String ville;
  final String adresse;

  Station({
    required this.id,
    required this.nom,
    required this.ville,
    required this.adresse,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      nom: json['nom'],
      ville: json['ville'],
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'ville': ville,
      'adresse': adresse,
    };
  }
}
