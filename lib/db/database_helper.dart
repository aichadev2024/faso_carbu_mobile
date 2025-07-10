import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:faso_carbu_mobile/models/demande_ticket.dart';
import 'package:faso_carbu_mobile/models/ticket.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fasocarbu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Table demandes
    await db.execute('''
      CREATE TABLE demandes (
        id TEXT PRIMARY KEY,
        demandeur TEXT,
        station TEXT,
        dateDemande TEXT,
        quantite REAL,
        statut TEXT,
        commentaire TEXT
      )
    ''');

    // Table tickets
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

    // ✅ Table utilisateurs avec nom et prénom
    await db.execute('''
      CREATE TABLE users (
        email TEXT PRIMARY KEY,
        motDePasse TEXT,
        role TEXT,
        token TEXT,
        nom TEXT,
        prenom TEXT
      )
    ''');
  }

  // ================= DEMANDES =================

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

  // ================= TICKETS =================

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

  // ================= USERS =================

 Future<void> saveUser(Map<String, dynamic> user) async {
  final db = await instance.database;
  try {
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    print("Utilisateur enregistré localement ✅");
  } catch (e) {
    print("❌ Erreur lors de l'enregistrement dans SQLite : $e");
    rethrow;
  }
}

// 🔍 Récupère un utilisateur par email uniquement (utilisé pour vérifier si l'utilisateur existe déjà à l'inscription)
Future<Map<String, dynamic>?> getUser(String email) async {
  final db = await instance.database;
  final result = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
  );
  return result.isNotEmpty ? result.first : null;
}

// 🔐 Récupère un utilisateur par email + mot de passe (utilisé pour le login)
Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String motDePasse) async {
  final db = await instance.database;
  final result = await db.query(
    'users',
    where: 'email = ? AND motDePasse = ?',
    whereArgs: [email, motDePasse],
  );
  return result.isNotEmpty ? result.first : null;
}


  Future<void> clearUsers() async {
    final db = await instance.database;
    await db.delete('users');
  }

  // ================= GÉNÉRAL =================

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('demandes');
    await db.delete('tickets');
    await db.delete('users');
  }
}
