import 'package:aplicacion_maps/database_helper.dart';
import 'package:aplicacion_maps/modelo_reservas.dart';

class ReservaStorage {
  //Almacenamiento de reservas en una lista estatica
  static List<Map<String, dynamic>> reservas = [];

  //Metodo para agregar una reserva
  static void agregarReserva(Map<String, dynamic> reserva) async {
  await DatabaseHelper().insertarReserva(Reserva.fromMap(reserva));
}

  //Metodo para obtener todas las reservas
  static Future<List<Map<String, dynamic>>> obtenerReservas() async {
  final data = await DatabaseHelper().obtenerTodasLasReservas();
  return data.map((reserva) => reserva.toMap()).toList();
}
}