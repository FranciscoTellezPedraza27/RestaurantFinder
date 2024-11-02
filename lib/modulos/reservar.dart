import 'dart:ffi';
import 'package:aplicacion_maps/modulos/reservas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplicacion_maps/database_helper.dart';
import 'package:aplicacion_maps/modelo_reservas.dart';

class Reservar extends StatefulWidget {
  final String? imageUrl; // Recibe la URL de la imagen
  final String? direccion; // Recibe la dirección del restaurante
  final double? calificacion; // Recibe la calificación del restaurante

  Reservar({this.imageUrl, this.direccion, this.calificacion}); // Constructor para aceptar la imagen

  @override
  _ReservarState createState() => _ReservarState();
}

class _ReservarState extends State<Reservar> {
  DateTime _selectedDate = DateTime.now();
  int _adultos = 1;
  int _ninos = 1;
  int _adolescentes = 1;

  // Listado del estado de las mesas
  List<bool> _mesasOcupadas = List.generate(5, (index) => false);

  // Índice de la mesa seleccionada
  int? _mesaSeleccionada;

  // Lista local de reservas
  List<Map<String, dynamic>> _reservas = [];

  // Método para seleccionar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Método para mostrar las mesas en un cuadro de diálogo
  void _mostrarMesas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccione una mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return ListTile(
              title: Text('Mesa ${index + 1}'),
              trailing: _mesasOcupadas[index]
                  ? Icon(Icons.block, color: Colors.red)
                  : Icon(Icons.check, color: Colors.green),
              onTap: _mesasOcupadas[index]
                  ? null
                  : () {
                      setState(() {
                        if (_mesaSeleccionada == index) {
                          _mesaSeleccionada = null; // Desmarca la mesa
                        } else {
                          if (_mesaSeleccionada != null) {
                            _mesasOcupadas[_mesaSeleccionada!] = false; // Desmarca la mesa anterior
                          }
                          _mesaSeleccionada = index; // Marca la mesa seleccionada
                          _mesasOcupadas[index] = true; // Marca la mesa
                        }
                      });
                      Navigator.pop(context); // Cierra el diálogo
                    },
            );
          }),
        ),
      ),
    );
  }

  // Método para continuar a la pantalla de detalles
  void _continuar() async {
    if (_mesaSeleccionada != null) {
      Reserva nuevaReserva = Reserva(
        mesa: _mesaSeleccionada! + 1,
        fecha: DateFormat('dd MMMM yyyy').format(_selectedDate),
        adultos: _adultos,
        ninos: _ninos,
        adolescentes: _adolescentes,
      );

      // Guarda en la base de datos
      await DatabaseHelper().insertarReserva(nuevaReserva);

      // Actualiza la lista local para mostrar en la UI
      setState(() {
        _reservas.add(nuevaReserva.toMap());
        _mesasOcupadas[_mesaSeleccionada!] = true;
      });

      // Navega a la pantalla de reservas
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReservasScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona una mesa antes de continuar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de encabezado
            Image.network(
              widget.imageUrl ?? '',
              fit: BoxFit.cover,
              height: 250,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dirección del restaurante
                  ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text(widget.direccion ?? 'Dirección no disponible'),
                    subtitle: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          widget.calificacion?.toString() ?? "Sin calificación",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Selección de la fecha
                  Text('Fecha a reservar', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10),
                        Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Selección de cantidades
                  Text('Seleccione', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  _buildCounter('Adulto', _adultos, (newValue) {
                    setState(() {
                      _adultos = newValue;
                    });
                  }),
                  _buildCounter('Niños', _ninos, (newValue) {
                    setState(() {
                      _ninos = newValue;
                    });
                  }),
                  _buildCounter('Adolescentes', _adolescentes, (newValue) {
                    setState(() {
                      _adolescentes = newValue;
                    });
                  }),
                  SizedBox(height: 20),

                  // Mostrar mesa seleccionada
                  if (_mesaSeleccionada != null)
                    Text(
                      'Mesa seleccionada: ${_mesaSeleccionada! + 1}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 10),

                  // Botón para seleccionar mesa
                  Center(
                    child: ElevatedButton(
                      onPressed: _mostrarMesas, // Llama al método para mostrar las mesas
                      child: Text('Seleccionar mesa'),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Botón de continuar
                  Center(
                    child: ElevatedButton(
                      onPressed: _continuar,
                      child: Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar los contadores de personas
  Widget _buildCounter(String label, int count, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (count > 0) onChanged(count - 1);
              },
              icon: Icon(Icons.remove_circle_outline),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            IconButton(
              onPressed: () {
                onChanged(count + 1);
              },
              icon: Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}
