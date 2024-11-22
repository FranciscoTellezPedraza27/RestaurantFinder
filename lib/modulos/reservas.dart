// reservas.dart
import 'package:flutter/material.dart';
import 'package:aplicacion_maps/database_helper.dart';
import 'package:aplicacion_maps/modelo_reservas.dart';
import 'package:aplicacion_maps/modulos/reservar.dart';

class ReservasScreen extends StatefulWidget {
  final VoidCallback? onReservasLoaded; // Callback para cuando se carguen las reservas
  final String? placeId; // Nuevo campo para el lugar

  const ReservasScreen({super.key, this.onReservasLoaded, this.placeId});

  @override
  ReservasScreenState createState() => ReservasScreenState();
}

class ReservasScreenState extends State<ReservasScreen> {
  List<Reserva> reservas = [];
  List<bool> _mesasOcupadas = List.generate(5, (_) => false);

  @override
  void initState() {
    super.initState();
    _cargarReservas();
    _cargarMesasOcupadas();
    DatabaseHelper().verificarTabla(); // Agrega esta línea
  }

  

  Future<void> _cargarMesasOcupadas() async {
    final mesasOcupadas = await DatabaseHelper().obtenerMesasOcupadas(widget.placeId ?? '');
    setState(() {
      for (int mesa in mesasOcupadas) {
        if (mesa <= _mesasOcupadas.length) {
          _mesasOcupadas[mesa - 1] = true;
        }
      }
    });
  }

  // Método para cargar las reservas desde la base de datos
  Future<void> _cargarReservas() async {
  if (widget.placeId!= null) {
    final data = await DatabaseHelper().obtenerReservasPorPlaceId(widget.placeId!);
    setState(() {
      reservas = data;
    });
  } else {
    final data = await DatabaseHelper().obtenerTodasLasReservas(); // Llama a la función para obtener todas las reservas
    setState(() {
      reservas = data.isEmpty? [] : data;
    });
  }

  // Notifica al widget padre que las reservas han sido cargadas
  if (widget.onReservasLoaded!= null) {
    widget.onReservasLoaded!();
  }
}

  // Llama a esta función desde MapScreen para cargar las reservas
  void cargarReservasExternamente() {
  if (widget.placeId!= null) {
    _cargarReservas();
  } else {
    _cargarReservas(); // Llama a _cargarReservas() incluso si placeId es null
  }
}

  Future<void> _confirmarEliminarReservas(int id, int mesa) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Elminar reserva'),
          content: Text('¿Estas seguro de eliminar esta reservación?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Si'),
              onPressed: (){
                _eliminarReserva(id, mesa);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _eliminarReserva(int id, int mesa) async {
    await DatabaseHelper().eliminarReserva(id);

    setState(() {
      //Refresca la lista local y libera la mesa seleccionada
      _cargarReservas();
      if (mesa <= _mesasOcupadas.length) {
        _mesasOcupadas[mesa - 1] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reserva eliminada'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
      ),
      body: reservas.isEmpty
          ? Center(
              child: Text(
                'No hay reservas.',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                return ListTile(
                  title: Text(
                      'Fecha: ${reserva.fecha} - Mesa: ${reserva.mesa}'),
                  subtitle: Text(
                      'Adultos: ${reserva.adultos}, Niños: ${reserva.ninos}, Adolescentes: ${reserva.adolescentes}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarEliminarReservas(reserva.id!, reserva.mesa),
                  ),
                );
              },
            ),
    );
  }
}