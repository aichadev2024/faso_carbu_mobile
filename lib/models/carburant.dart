class Carburant {
  final int? id;
  final String nom;
  final double prix;

  Carburant({
    this.id,
    required this.nom,
    required this.prix,
  });

  factory Carburant.fromJson(Map<String, dynamic> json) {
    return Carburant(
      id: json['id'],
      nom: json['nom'],
      prix: (json['prix'] is int)
          ? (json['prix'] as int).toDouble()
          : json['prix'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prix': prix,
    };
  }
}
