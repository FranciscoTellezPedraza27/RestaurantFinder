import 'dart:ffi';
import 'package:aplicacion_maps/database_helper.dart';
import 'package:aplicacion_maps/BD/nota.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Operaciones {

  static Future<bool> esMesaDisponible(int mesa, String fecha) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> reservas = await db.query(
      'reservas',
      where: 'mesa = ? AND fecha = ?',
      whereArgs: [mesa, fecha],
    );

    return reservas.isEmpty;
  }

  static Future<void> eliminarReserva(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('reservas', where: 'id = ?', whereArgs: [id]);
  }

  // Crear la Base de Datos y la Tabla
  static Future<Database> _abrirBD() async {
    return openDatabase(
      join(await getDatabasesPath(), 'appdb.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE IF NOT EXISTS usuarios (id INTEGER PRIMARY KEY, nombre TEXT, apellido TEXT, correo TEXT, contrasena TEXT, confContrasena TEXT)"
        );
      },
      version: 1,
    );
  }

  // Insertar Elemento a la Tabla 
  static Future<void> insertarAppbd(Nota nota) async {
    Database db = await _abrirBD();
    db.insert("usuarios", nota.toMap());
  }

  // Listar los elementos de la tabla Usuarios
  static Future<List<Nota>> notas() async {
    Database db = await _abrirBD();

    // Listar los elementos del map
    final List<Map<String, dynamic>> notasMaps = await db.query("usuarios");

    for (var n in notasMaps) {
      print("___" + n['nombre'].toString());
      print("___" + n['apellido'].toString());
      print("___" + n['correo'].toString());
      print("___" + n['contrasena'].toString());
      print("___" + n['confContrasena'].toString());
    }

    return List.generate(
      notasMaps.length,
      (index) => Nota(
        id: notasMaps[index]['id'],
        nombre: notasMaps[index]['nombre'],
        apellido: notasMaps[index]['apellido'],
        correo: notasMaps[index]['correo'],
        contrasena: notasMaps[index]['contrasena'],
        confContrasena: notasMaps[index]['confContrasena'],
      ),
    );
  }

  // Eliminar un elemento de la Tabla
  static Future<void> eliminarAppbd(Nota nota) async {
    Database db = await _abrirBD();
    db.delete("usuarios", where: "id = ?", whereArgs: [nota.id]);
  }

  // Actualizar un elemento de la Tabla
  static Future<void> actualizarAppbd(Nota nota) async {
    Database db = await _abrirBD();
    db.update("usuarios", nota.toMap(), where: "id = ?", whereArgs: [nota.id]);
  }

  // Método para Iniciar Sesión
  static Future<Nota?> iniciarSesion(String correo, String contrasena) async {
    Database db = await _abrirBD();

    // Consulta para encontrar un usuario con el correo proporcionado
    final List<Map<String, dynamic>> usuarios = await db.query(
      "usuarios",  // Cambiado para seleccionar desde la tabla correcta
      where: "correo = ?",
      whereArgs: [correo],
    );

    if (usuarios.isNotEmpty) {
      // Si se encuentra el usuario, validamos la contraseña
      if (usuarios[0]['contrasena'] == contrasena) {
        // Si la contraseña coincide, retornamos el usuario
        return Nota(
          id: usuarios[0]['id'],
          nombre: usuarios[0]['nombre'],
          apellido: usuarios[0]['apellido'],
          correo: usuarios[0]['correo'],
          contrasena: usuarios[0]['contrasena'],
          confContrasena: usuarios[0]['confContrasena'],
        );
      } else {
        // Si la contraseña no coincide, retornamos null
        print('Contraseña incorrecta');
        return null;
      }
    } else {
      // Si no se encuentra el usuario, retornamos null
      print('Correo no registrado');
      return null;
    }
  }
}
