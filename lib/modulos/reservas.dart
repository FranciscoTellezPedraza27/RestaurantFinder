import 'package:flutter/material.dart';

class ReservasScreen extends StatelessWidget {
  const ReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Aquí puedes hacer una reserva',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
