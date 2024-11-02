class ReservaStorage {
  //Almacenamiento de reservas en una lista estatica
  static List<Map<String, dynamic>> reservas = [];

  //Metodo para agregar una reserva
  static void agregarReserva (Map<String, dynamic> reserva) {
    reservas.add(reserva);
  }

  //Metodo para obtener todas las reservas
  static List<Map<String, dynamic>> obtenerReservas() {
    return reservas;
  }
}