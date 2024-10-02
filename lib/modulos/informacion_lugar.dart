import 'package:flutter/material.dart';

class InformacionLugar extends StatefulWidget {
  const InformacionLugar({super.key});

  @override
  State<InformacionLugar> createState() => _InformacionLugarState();
}

class _InformacionLugarState extends State<InformacionLugar> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Módulo de información del lugar',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}