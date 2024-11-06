import 'package:flutter/material.dart';
import 'package:aplicacion_maps/database_helper.dart';
import 'package:aplicacion_maps/modelo_reservas.dart';
import 'package:aplicacion_maps/database_helper.dart';
import 'package:aplicacion_maps/modulos/reservar.dart';

class ReservasScreen extends StatefulWidget {
  final VoidCallback? onReservasLoaded; // Callback para cuando se carguen las reservas

  const ReservasScreen({super.key, this.onReservasLoaded});

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
  }

  Future<void> _cargarMesasOcupadas() async {
    final mesasOcupadas = await DatabaseHelper().obtenerMesasOcupadas();
    setState(() {
      for (int mesa in mesasOcupadas){
        _mesasOcupadas[mesa - 1] = true;
      }
    });
  }

  // Método para cargar las reservas desde la base de datos
  Future<void> _cargarReservas() async {
    final data = await DatabaseHelper().obtenerReservas();
    setState(() {
      reservas = data;
    });

    // Notifica al widget padre que las reservas han sido cargadas
    if (widget.onReservasLoaded != null) {
      widget.onReservasLoaded!();
    }
  }

  // Llama a esta función desde MapScreen para cargar las reservas
  void cargarReservasExternamente() {
    _cargarReservas();
  }

  Future<void> _eliminarReservas(int id, int mesa) async {
    await DatabaseHelper().eliminarReserva(id);

    setState(() {
      //Refresca la lista local y libera la mesa seleccionada
      _cargarReservas();
      _mesasOcupadas[mesa - 1] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reserva eliminada')),
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
                    onPressed: () => _eliminarReservas(reserva.id!, reserva.mesa),
                  ),
                );
              },
            ),
    );
  }
}
