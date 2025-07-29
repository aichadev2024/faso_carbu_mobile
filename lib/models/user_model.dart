class UserModel {
  int? id;
  String email;
  String motDePasse;
  String role;
  String nom;
  String prenom;
  String token;
  String backendId;
  int? isSynced;

  UserModel({
    this.id,
    required this.email,
    required this.motDePasse,
    required this.role,
    required this.nom,
    required this.prenom,
    this.token = '',
    this.backendId = '',
    this.isSynced = 0,
  });

  // 🔧 Ajoute ceci :
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'motDePasse': motDePasse,
      'role': role,
      'nom': nom,
      'prenom': prenom,
      'token': token,
      'backend_id': backendId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      motDePasse: map['motDePasse'],
      role: map['role'],
      nom: map['nom'],
      prenom: map['prenom'],
      token: map['token'] ?? '',
      backendId: map['backend_id'] ?? '',
      isSynced: map['isSynced'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'motDePasse': motDePasse,
      'role': role,
      'nom': nom,
      'prenom': prenom,
      'token': token,
      'backend_id': backendId,
      'isSynced': isSynced,
    };
  }
}
