import 'package:flutter/material.dart';
import 'package:aplicacion_maps/BD/operaciones.dart';
import 'package:aplicacion_maps/modulos/menu_principal.dart';
import 'package:aplicacion_maps/modulos/recuperar_contra.dart';
import 'package:aplicacion_maps/modulos/registrar.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  bool _mostrarContrasena = false;

  void _iniciarSesion() async {
    String correo = correoController.text;
    String contrasena = contrasenaController.text;

    var usuario = await Operaciones.iniciarSesion(correo, contrasena);
    if (usuario != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(),
        ),
      );
    } else {
      //Limpia los campos después del intento fallido
      correoController.clear();
      contrasenaController.clear();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Correo o contraseña incorrectos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/restaurante.jpg'), // Cambia a tu imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Formulario alineado hacia la parte inferior
          Align(
            alignment: Alignment
                .bottomCenter, // Alinea el formulario en la parte inferior
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 0), // Ajusta el espaciado desde el borde inferior
              child: Container(
                width:
                    screenWidth, // Ajusta el ancho del contenedor al 100% de la pantalla
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xBF9AD7E5)
                      .withOpacity(0.7), // Fondo semi-transparente
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                        25), // Bordes redondeados solo en la parte superior
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    // Campo de correo con ancho limitado
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            300, // Fija el ancho máximo para los campos de texto
                      ),
                      child: TextFormField(
                        controller: correoController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0x29141218).withOpacity(0.2),
                          labelText: 'Correo',
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(Icons.email, color: Colors.black,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Color del borde cuando el campo está habilitado
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Color del borde cuando el campo está enfocado
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    // Campo de contraseña con ancho limitado
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            300, // Fija el ancho máximo para los campos de texto
                      ),
                      child: TextFormField(
                        controller: contrasenaController,
                        obscureText: !_mostrarContrasena,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0x29141218).withOpacity(0.2),
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.black),
                          prefixIcon: Icon(Icons.lock, color: Colors.black,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Color del borde cuando el campo está habilitado
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Color del borde cuando el campo está enfocado
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _mostrarContrasena
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _mostrarContrasena = !_mostrarContrasena;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF92DFF3), // Color de fondo del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Bordes redondeados del botón
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      ),
                      onPressed: _iniciarSesion,
                      child: Text('Iniciar Sesión',
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecuperarContra(),
                          ),
                        );
                      },
                      child: Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF92DFF3), // Color de fondo del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Bordes redondeados del botón
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Registrar(),
                          ),
                        );
                      },
                      child: Text('Registrarse',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
