class UserModel {
  final int? id;
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String role;
  final String? token;
  final String? backendId;
  final int isSynced;

  UserModel({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.role,
    this.token,
    this.backendId,
    this.isSynced = 0,
  });

  // 🔹 Pour API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      motDePasse: json['motDePasse'] ?? '',
      role: json['role'] ?? '',
      token: json['token'],
      backendId: json['backend_id'],
      isSynced: json['isSynced'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "motDePasse": motDePasse,
      "role": role,
      "token": token,
      "backend_id": backendId,
      "isSynced": isSynced,
    };
  }

  // 🔹 Pour SQLite
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      motDePasse: map['motDePasse'],
      role: map['role'],
      token: map['token'],
      backendId: map['backend_id'],
      isSynced: map['isSynced'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "motDePasse": motDePasse,
      "role": role,
      "token": token,
      "backend_id": backendId,
      "isSynced": isSynced,
    };
  }
}
