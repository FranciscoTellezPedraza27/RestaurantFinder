import 'dart:math';
import 'package:aplicacion_maps/modulos/login.dart';
import 'package:aplicacion_maps/modulos/menu_principal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences para la gestión de estados

void main() {
  runApp(myapp()); // Inicia la aplicación
}

// Clase principal de la aplicación
class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    // Construye la aplicación MaterialApp con la pantalla principal
    return MaterialApp(home: PrinPage());
  }
}

// Pantalla principal de la aplicación
class PrinPage extends StatefulWidget {
  const PrinPage({super.key});

  @override
  State<PrinPage> createState() => _PrinPageState();
}

class _PrinPageState extends State<PrinPage> {
  @override
  void initState() {
    super.initState();
    _checkAppState(); // Verifica el estado de la app al iniciar
  }

  // Función para verificar el estado de la app
  void _checkAppState() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // Accede a SharedPreferences
    bool? isMapScreen = prefs.getBool('isMapScreen') ??
        false; // Obtiene el estado de la pantalla del mapa

    // Después de 5 segundos, decide si ir a login o a MapScreen
    Future.delayed(Duration(milliseconds: 5000), () {
      if (isMapScreen) {
        // Si estaba en MapScreen, navega directamente a esa pantalla
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(),
          ),
        );
      } else {
        // Si no, navega a la pantalla de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => login(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de la pantalla principal
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 183, 226, 234),
              Color.fromARGB(255, 1, 138, 202)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 500,
            height: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Distribuye los elementos uniformemente
              children: [
                // Imagen arriba
                Image.asset(
                  'assets/logo.png',
                  width: 250, // Cambia el ancho de la imagen
                  height: 250, // Cambia la altura de la imagen
                ),
                // Texto debajo de la imagen
                Text(
                  "RestaurantFinder",
                  style: TextStyle(color: Colors.white, fontSize: 27),
                ),
                // Barra de progreso debajo del texto
                CircularProgressIndicator(
                  backgroundColor: Color.fromARGB(255, 182, 234, 213),
                  valueColor:
                      AlwaysStoppedAnimation(Color.fromARGB(255, 202, 1, 1)),
                  strokeWidth: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
