import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aplicacion_maps/modelo_reservas.dart'; // Importa tu modelo Reserva

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'reservas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE reservas(id INTEGER PRIMARY KEY, mesa INTEGER, fecha TEXT, adultos INTEGER, ninos INTEGER, adolescentes INTEGER)',
        );
      },
    );
  }

  Future<void> insertarReserva(Reserva reserva) async {
    final db = await database;
    await db.insert('reservas', reserva.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reserva>> obtenerReservas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reservas');
    return List.generate(maps.length, (i) {
      return Reserva.fromMap(maps[i]);
    });
  }

  Future<void> eliminarReserva(int id) async {
    final db = await database;
    await db.delete(
      'reservas', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
}
