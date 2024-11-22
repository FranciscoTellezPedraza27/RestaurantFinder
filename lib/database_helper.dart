import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aplicacion_maps/modelo_reservas.dart'; // Importa tu modelo Reserva
import 'BD/operaciones.dart';

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
  String path = join(await getDatabasesPath(),'reservas.db');
  bool exists = await databaseExists(path);
  if (!exists) {
    // Crea la base de datos si no existe
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) {
        print('Creando tabla reservas');
        return db.execute(
          'CREATE TABLE IF NOT EXISTS reservas(id INTEGER PRIMARY KEY, mesa INTEGER, fecha TEXT, adultos INTEGER, ninos INTEGER, adolescentes INTEGER, placeId TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          print('Actualizando base de datos a versión 2');
          print('Agregando columna placeId a la tabla reservas');
          await db.execute(
            'ALTER TABLE reservas ADD COLUMN placeId TEXT',
          );
        }
        if (oldVersion < 3) {
          print('Actualizando base de datos a versión 3');
          // Aquí puedes agregar más actualizaciones en el futuro si es necesario
        }
      },
    );
  } else {
    // Abre la base de datos si ya existe
    return await openDatabase(
      path,
      version: 4,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          print('Actualizando base de datos a versión 2');
          print('Agregando columna placeId a la tabla reservas');
          await db.execute(
            'ALTER TABLE reservas ADD COLUMN placeId TEXT',
          );
        }
        if (oldVersion < 3) {
          print('Actualizando base de datos a versión 3');
          // Aquí puedes agregar más actualizaciones en el futuro si es necesario
        }
      },
    );
  }
}

  Future<void> insertarReserva(Reserva reserva) async {
    final db = await database;
    await db.insert('reservas', reserva.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reserva>> obtenerReservasPorPlaceId(String placeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reservas', where: 'placeId = ?', whereArgs: [placeId]);
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

  Future<List<int>> obtenerMesasOcupadas(String placeId) async {
    final db = await database;
    final List<Map<String, dynamic>> reservas = await db.query('reservas', where: 'placeId = ?', whereArgs: [placeId]);
    return reservas.map((reserva) => reserva['mesa'] as int).toList();
  }

  Future<void> verificarTabla() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('PRAGMA table_info(reservas)');
    print(result);
  }

  Future<List<Reserva>> obtenerTodasLasReservas() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('reservas');
  return List.generate(maps.length, (i) {
    return Reserva.fromMap(maps[i]);
  });
}
}