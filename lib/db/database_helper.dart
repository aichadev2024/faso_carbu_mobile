import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:faso_carbu_mobile/models/ticket.dart';
import 'package:faso_carbu_mobile/models/notification_model.dart';
import 'package:faso_carbu_mobile/models/user_model.dart';
import 'package:faso_carbu_mobile/models/carburant.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// ✅ Incrémente la version après suppression de vehicule
  static const int _databaseVersion = 11;

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
    // Tickets
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

    // Utilisateurs
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

    // Carburants
    await db.execute('''
      CREATE TABLE carburants (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        prix REAL NOT NULL
      )
    ''');

    // Notifications
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT,
        message TEXT,
        date TEXT,
        lu INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // On supprime vehicule si elle existait encore
    if (oldVersion < 11) {
      await db.execute('DROP TABLE IF EXISTS vehicule');
      await db.execute('DROP TABLE IF EXISTS demandes');
    }
  }

  // ================= TICKETS =================
  Future<void> insertTicket(Map<String, dynamic> ticket) async {
    final db = await instance.database;
    ticket['statut'] ??= 'local';
    await db.insert(
      'tickets',
      ticket,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveTicketsOffline(List<Map<String, dynamic>> tickets) async {
    final db = await instance.database;
    for (var ticket in tickets) {
      ticket['statut'] ??= 'local';
      await db.insert(
        'tickets',
        ticket,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Ticket>> getAllTickets() async {
    final db = await instance.database;
    final result = await db.query('tickets');
    return result.map((json) => Ticket.fromMap(json)).toList();
  }

  Future<List<Ticket>> getUnsyncedTickets() async {
    final db = await instance.database;
    final result = await db.query(
      'tickets',
      where: 'statut = ?',
      whereArgs: ['local'],
    );
    return result.map((json) => Ticket.fromMap(json)).toList();
  }

  Future<void> markTicketAsSynced(String id) async {
    final db = await instance.database;
    await db.update(
      'tickets',
      {'statut': 'sync'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= USERS =================
  Future<void> saveUser(UserModel users) async {
    final db = await instance.database;
    await db.insert(
      'users',
      users.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserByEmailAndPassword(
    String email,
    String motDePasse,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND motDePasse = ?',
      whereArgs: [email, motDePasse],
    );
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

  Future<List<UserModel>> getUnsyncedUsers() async {
    final db = await database;
    final maps = await db.query('users', where: 'isSynced = 0');
    return maps.map((u) => UserModel.fromMap(u)).toList();
  }

  Future<void> markUserAsSynced(int id) async {
    final db = await database;
    await db.update('users', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ================= CARBURANTS =================
  Future<void> insertCarburant(Carburant carburant) async {
    final db = await database;
    await db.insert(
      'carburants',
      carburant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Carburant>> getAllCarburants() async {
    final db = await database;
    final maps = await db.query('carburants');
    return maps.map((map) => Carburant.fromMap(map)).toList();
  }

  Future<void> clearCarburants() async {
    final db = await database;
    await db.delete('carburants');
  }

  // ================= NOTIFICATIONS =================
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    final db = await instance.database;
    await db.insert(
      'notifications',
      notification,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // ================= GLOBAL =================
  Future<void> clearAll() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('tickets');
    await db.delete('users');
    await db.delete('notifications');
    await db.delete('carburants');
  }
}
