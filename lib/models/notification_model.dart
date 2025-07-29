class NotificationModel {
  final int? id;
  final String titre;
  final String message;
  final String date; // format ISO ou juste "2025-07-10 14:00"
  final bool lu; // true si déjà consultée

  NotificationModel({
    this.id,
    required this.titre,
    required this.message,
    required this.date,
    this.lu = false,
  });

  // 🔁 Pour insertion dans SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'message': message,
      'date': date,
      'lu': lu ? 1 : 0,
    };
  }

  // 🔁 Pour lecture depuis SQLite
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      titre: map['titre'],
      message: map['message'],
      date: map['date'],
      lu: map['lu'] == 1,
    );
  }
}
