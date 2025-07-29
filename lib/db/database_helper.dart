import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:faso_carbu_mobile/models/demande_ticket.dart';
import 'package:faso_carbu_mobile/models/ticket.dart';
import 'package:faso_carbu_mobile/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:faso_carbu_mobile/models/user_model.dart';
import 'package:faso_carbu_mobile/models/carburant.dart';
import 'package:faso_carbu_mobile/models/vehicule.dart';
import 'package:faso_carbu_mobile/models/station.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

var logger = Logger();


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const int _databaseVersion = 8; // Incrémenté pour appliquer la nouvelle colonne

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fasocarbu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE demandes (
        id TEXT PRIMARY KEY,
        demandeur TEXT NOT NULL,
        station TEXT NOT NULL,
        dateDemande TEXT NOT NULL,
        quantite REAL NOT NULL,
        statut TEXT,
        carburantId TEXT
        vehiculeId TEXT,
        validateurId TEXT,
        dateValidation TEXT


      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT,
        message TEXT,
        date TEXT,
        lu INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE tickets (
        id TEXT PRIMARY KEY,
        code TEXT,
        dateCreation TEXT,
        dateExpiration TEXT,
        station TEXT,
        chauffeur TEXT,
        quantite REAL,
        statut TEXT
      )
    ''');
    await db.execute('''
  CREATE TABLE vehicule (
    id TEXT PRIMARY KEY,
    immatriculation TEXT,
    marque TEXT,
    type TEXT,
    chauffeurId TEXT
  )
''');

await db.execute('''
  CREATE TABLE station (
    id TEXT PRIMARY KEY,
    nom TEXT,
    ville TEXT,
    adresse TEXT
  )
''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        motDePasse TEXT,
        role TEXT,
        nom TEXT,
        prenom TEXT,
        token TEXT,
        backend_id TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
        CREATE TABLE carburants (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        prix REAL NOT NULL
  )
''');

  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN backend_id TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN isSynced INTEGER DEFAULT 0');
      
    }

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE demandes ADD COLUMN carburantId TEXT');
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE demandes ADD COLUMN vehiculeId TEXT');
      await db.execute('ALTER TABLE demandes ADD COLUMN validateurId TEXT');
      await db.execute('ALTER TABLE demandes ADD COLUMN dateValidation TEXT');
}

  }

  // =============== DEMANDES ===============
  Future<void> insertDemande(Map<String, dynamic> demande) async {
    final db = await instance.database;
    await db.insert('demandes', demande, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DemandeTicket>> getAllDemandes() async {
    final db = await instance.database;
    final result = await db.query('demandes');
    return result.map((json) => DemandeTicket.fromMap(json)).toList();
  }

  Future<void> updateDemande(DemandeTicket demande) async {
    final db = await instance.database;
    await db.update(
      'demandes',
      demande.toMap(),
      where: 'id = ?',
      whereArgs: [demande.id],
    );
  }

  Future<void> deleteDemande(String id) async {
    final db = await instance.database;
    await db.delete('demandes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DemandeTicket>> getLocalDemandes() async {
    final db = await instance.database;
    final result = await db.query('demandes', where: 'statut = ?', whereArgs: ['en_attente']);
    return result.map((json) => DemandeTicket.fromMap(json)).toList();
  }

  Future<bool> demandeExiste(String? id) async {
    if (id == null) return false;
    final db = await instance.database;
    final result = await db.query('demandes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  Future<void> marquerDemandeCommeSynced(String id) async {
    final db = await instance.database;
    await db.update(
      'demandes',
      {'statut': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =============== TICKETS ===============
  Future<void> insertTicket(Map<String, dynamic> ticket) async {
    final db = await instance.database;
    await db.insert('tickets', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveTicketsOffline(List<Map<String, dynamic>> tickets) async {
    final db = await instance.database;
    for (var ticket in tickets) {
      await db.insert('tickets', ticket, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Ticket>> getAllTickets() async {
    final db = await instance.database;
    final result = await db.query('tickets');
    return result.map((json) => Ticket.fromMap(json)).toList();
  }

  Future<List<Ticket>> getUnsyncedTickets() async {
    final db = await instance.database;
    final result = await db.query('tickets', where: 'statut = ?', whereArgs: ['local']);
    return result.map((json) => Ticket.fromMap(json)).toList();
  }

  Future<void> markTicketAsSynced(String id) async {
    final db = await instance.database;
    await db.update('tickets', {'statut': 'sync'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTicket(String id) async {
    final db = await instance.database;
    await db.delete('tickets', where: 'id = ?', whereArgs: [id]);
  }

  // =============== USERS ===============
  Future<void> saveUser(UserModel users) async {
    final db = await instance.database;
    await db.insert('users', users.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUser(String email) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

  Future<UserModel?> getUserByEmailAndPassword(String email, String motDePasse) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND motDePasse = ?',
      whereArgs: [email, motDePasse],
    );
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

  Future<void> clearUsers() async {
    final db = await instance.database;
    await db.delete('users');
  }

  Future<void> syncLocalUsersToServer() async {
    final db = await database;
    final List<Map<String, dynamic>> localUsers = await db.query(
      'users',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    for (final userMap in localUsers) {
      final user = UserModel.fromMap(userMap);

      try {
        final response = await http.post(
          Uri.parse('https://faso-carbu-back-2.onrender.com/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "nom": user.nom,
            "prenom": user.prenom,
            "email": user.email,
            "motDePasse": user.motDePasse,
            "role": user.role,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await db.update(
            'users',
            {'isSynced': 1},
            where: 'id = ?',
            whereArgs: [user.id],
          );
          logger.i('✅ Utilisateur synchronisé : ${user.email}');
        } else {
          logger.e('❌ Erreur serveur pour ${user.email} - Code: ${response.statusCode}');
        }
      } catch (e) {
        logger.e('❌ Erreur réseau pour ${user.email} : $e');
      }
    }
  }

  Future<void> markUserAsSynced(int id) async {
    final db = await database;
    await db.update(
      'users',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<UserModel>> getUnsyncedUsers() async {
    final db = await database;
    final maps = await db.query('users', where: 'isSynced = 0');
    return maps.map((u) => UserModel.fromMap(u)).toList();
  }

  Future<int> insertUser(UserModel users) async {
    final db = await database;
    return await db.insert(
      'users',
      users.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> syncOldUsersToServer() async {
    final db = await database;
    final unsyncedUsers = await getUnsyncedUsers();

    for (final user in unsyncedUsers) {
      try {
        final response = await http.post(
          Uri.parse('https://faso-carbu-back-2.onrender.com/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "nom": user.nom,
            "prenom": user.prenom,
            "email": user.email,
            "motDePasse": user.motDePasse,
            "role": user.role,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await db.update(
            'users',
            {'isSynced': 1},
            where: 'id = ?',
            whereArgs: [user.id],
          );
         logger.i('🔁 Ancien utilisateur synchronisé : ${user.email}');
        } else {
          logger.i('❌ Ancien utilisateur non synchronisé : ${user.email}');
        }
      } catch (e) {
        logger.e('⚠ Erreur de sync pour ${user.email} : $e');
      }
    }
  }

  // =============== NOTIFICATIONS ===============
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await instance.database;
    final result = await db.query('notifications', orderBy: 'date DESC');
    return result.map((map) => NotificationModel.fromMap(map)).toList();
  }

  Future<void> marquerNotificationCommeLue(int id) async {
    final db = await instance.database;
    await db.update(
      'notifications',
      {'lu': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNotification(int id) async {
    final db = await instance.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }

  Future<int> countNotificationsNonLues() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM notifications WHERE lu = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<void> insertCarburant(Carburant carburant) async {
  final db = await database;
  await db.insert(
    'carburants',
    carburant.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
Future<List<Carburant>> getAllCarburants() async {
  final db = await database;
  final maps = await db.query('carburants');
  return maps.map((map) => Carburant.fromJson(map)).toList();
}
Future<void> clearCarburants() async {
  final db = await database;
  await db.delete('carburants');
}
Future<void> updateCarburant(Carburant carburant) async {
  final db = await database;
  await db.update(
    'carburants',
    carburant.toJson(),
    where: 'id = ?',
    whereArgs: [carburant.id],
  );
}
// Insert Vehicule
Future<void> insertVehicule(Vehicule vehicule) async {
  final db = await database;
  await db.insert(
    'vehicule',
    vehicule.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Get all Vehicules
Future<List<Vehicule>> getAllVehicules() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('vehicule');
  return maps.map((map) => Vehicule.fromJson(map)).toList();
}

// Delete Vehicule
Future<void> deleteVehicule(String id) async {
  final db = await database;
  await db.delete('vehicule', where: 'id = ?', whereArgs: [id]);
}
// Insert Station
Future<void> insertStation(Station station) async {
  final db = await database;
  await db.insert(
    'station',
    station.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Get all Stations
Future<List<Station>> getAllStations() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('station');
  return maps.map((map) => Station.fromJson(map)).toList();
}

// Delete Station
Future<void> deleteStation(String id) async {
  final db = await database;
  await db.delete('station', where: 'id = ?', whereArgs: [id]);
}


  // =============== GLOBAL ===============
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('demandes');
    await db.delete('tickets');
    await db.delete('users');
  }

}