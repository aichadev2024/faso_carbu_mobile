import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/demande_ticket.dart';
import 'package:logger/logger.dart';

var logger = Logger();
class LocalRequestService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'requests.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE demandes (
            id TEXT PRIMARY KEY,
            demandeur TEXT,
            station TEXT,
            dateDemande TEXT,
            quantite REAL,
            statut TEXT,
            carburantId TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertDemande(DemandeTicket demande) async {
    final db = await database;
    await db.insert(
      'demandes',
      demande.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DemandeTicket>> getDemandes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('demandes');
    return List.generate(maps.length, (i) {
      return DemandeTicket.fromMap(maps[i]);
    });
  }

  Future<DemandeTicket?> getDemandeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('demandes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return DemandeTicket.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DemandeTicket>> getDemandesByStatut(String statut) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'demandes',
      where: 'statut = ?',
      whereArgs: [statut],
    );
    return List.generate(maps.length, (i) {
      return DemandeTicket.fromMap(maps[i]);
    });
  }

  Future<void> updateDemande(DemandeTicket demande) async {
    final db = await database;
    await db.update(
      'demandes',
      demande.toMap(),
      where: 'id = ?',
      whereArgs: [demande.id],
    );
  }

  Future<void> deleteDemande(String id) async {
    final db = await database;
    await db.delete('demandes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('demandes');
  }

  Future<bool> demandeExists(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'demandes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<int> countDemandes() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM demandes')) ?? 0;
  }

  /// Sauvegarde une demande locale en s'assurant que les champs requis sont bien définis
  static Future<void> saveLocalRequest(Map<String, dynamic> demandeMap) async {
    try {
      // Sécurisation manuelle si certaines données sont absentes ou mal formatées
      final String demandeur = demandeMap['demandeur'] ?? 'inconnu';
      final String carburantId = demandeMap['carburant']?['id'] ?? '';

      if (carburantId.isEmpty) {
        throw Exception("❌ ID carburant manquant lors de la sauvegarde locale");
      }

      final demande = DemandeTicket.fromMap({
        ...demandeMap,
        'demandeur': demandeur,
        'carburant': {'id': carburantId}
      });

      final service = LocalRequestService();
      await service.insertDemande(demande);
    } catch (e) {
      logger.e("⚠️ Erreur lors de la sauvegarde locale: $e");
    }
  }
}
