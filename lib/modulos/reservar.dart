import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Reservar extends StatefulWidget {
  final String? imageUrl; //Recibe la URL de la imagen
  final String? direccion; //Recibe la dirección del restaurante
  final double? calificacion; //Recibe la calificación del restaurante

  Reservar({this.imageUrl, this.direccion, this.calificacion}); //Constructor para aceptar la imagen

  @override
  _ReservarState createState() => _ReservarState();
}

class _ReservarState extends State<Reservar> {
  DateTime _selectedDate = DateTime.now();
  int _adultos = 1;
  int _ninos = 1;
  int _adolescentes = 1;

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
                        Spacer(),
                        Text(DateFormat('d').format(_selectedDate)),
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

                  // Botón de continuar
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción del botón de continuar
                      },
                      child: Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 80, vertical: 15),
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

void main() => runApp(MaterialApp(home: Reservar()));
