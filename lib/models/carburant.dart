class Carburant {
  final int id;
  final String nom;
  final double prix;

  Carburant({required this.id, required this.nom, required this.prix});

  // 🔹 Depuis l’API (backend JSON)
  factory Carburant.fromJson(Map<String, dynamic> json) {
    return Carburant(
      id: json['id'],
      nom: json['nom'],
      prix: (json['prix'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'prix': prix};
  }

  // 🔹 Pour SQLite (DB locale)
  factory Carburant.fromMap(Map<String, dynamic> map) {
    return Carburant(
      id: map['id'],
      nom: map['nom'],
      prix: (map['prix'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'prix': prix};
  }
}
