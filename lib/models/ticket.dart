class Ticket {
  final int? id;
  final String? date;
  final String? statut;
  final int? quantite;
  final int? vehiculeId;
  final int? stationId;
  final String? qrCode;

  Ticket({
    this.id,
    this.date,
    this.statut,
    this.quantite,
    this.vehiculeId,
    this.stationId,
    this.qrCode,
  });

  // 🔄 Convertir JSON → Ticket (API ou SQLite)
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      date: json['date'],
      statut: json['statut'],
      quantite: json['quantite'],
      vehiculeId: json['vehiculeId'] ?? json['vehicule_id'],
      stationId: json['stationId'] ?? json['station_id'],
      qrCode: json['qrCode'] ?? json['qr_code'],
    );
  }

  // 🔄 Convertir Ticket → JSON (vers API ou SQLite)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'statut': statut,
      'quantite': quantite,
      'vehiculeId': vehiculeId,
      'stationId': stationId,
      'qrCode': qrCode,
    };
  }

  // 🔄 Pour insertion SQLite (sans l’id auto-généré)
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'statut': statut,
      'quantite': quantite,
      'vehicule_id': vehiculeId,
      'station_id': stationId,
      'qr_code': qrCode,
    };
  }

  // 🔄 Pour lecture depuis SQLite (avec id)
  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      date: map['date'],
      statut: map['statut'],
      quantite: map['quantite'],
      vehiculeId: map['vehicule_id'],
      stationId: map['station_id'],
      qrCode: map['qr_code'],
    );
  }
}
