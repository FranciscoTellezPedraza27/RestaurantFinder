class Reserva {
  final int? id;
  final int mesa;
  final String fecha;
  final int adultos;
  final int ninos;
  final int adolescentes;

  Reserva({
    this.id,
    required this.mesa,
    required this.fecha,
    required this.adultos,
    required this.ninos,
    required this.adolescentes,
  });

  // Convertir a Map para almacenar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mesa': mesa,
      'fecha': fecha,
      'adultos': adultos,
      'ninos': ninos,
      'adolescentes': adolescentes,
    };
  }

  // Crear una reserva desde un Map (para leer de SQLite)
  static Reserva fromMap(Map<String, dynamic> map) {
    return Reserva(
      id: map['id'],
      mesa: map['mesa'],
      fecha: map['fecha'],
      adultos: map['adultos'],
      ninos: map['ninos'],
      adolescentes: map['adolescentes'],
    );
  }
}
