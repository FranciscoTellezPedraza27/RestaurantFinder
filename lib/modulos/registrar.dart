import 'package:flutter/material.dart';
import 'package:aplicacion_maps/BD/operaciones.dart';
import 'package:aplicacion_maps/BD/nota.dart';
import 'package:aplicacion_maps/modulos/login.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

//Funciíon para encriptar la contraseña usando SHA256
String encriptarContrasena(String contrasena) {
  final bytes = utf8.encode(contrasena); //Codifica la contraseña a bytes
  final digest = sha256.convert(bytes); //Encripta la contraseña
  return digest.toString(); //Devuelve la contraseña encriptada
}

class Registrar extends StatefulWidget {
  const Registrar({super.key});

  @override
  State<Registrar> createState() => _registrarState();
}

class _registrarState extends State<Registrar> {
  bool _mostrarContrasena = false; //Variable para mostrar/ocultar la contraseña
  bool _mostrarConfContrasena =
      false; // Nueva variable para confirmar contraseña
  final _key = GlobalKey<FormState>(); //Clave global para el formulario
  final nombreControlador = TextEditingController(); //Controlador para el nombre
  final apellidoControlador = TextEditingController(); //Controlador para el apellido
  final correoControlador = TextEditingController(); //Controlador para el correo
  final contrasenaControlador = TextEditingController(); //Controlador para la contraseña
  final confContrasenacontrolador = TextEditingController(); //Controlador para confirmar la contraseña

  //Función para validar correos electrónicos
  String? validarEmail(String? value) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'; //Expresión regular para validar correos
    RegExp regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese un correo';
    } else if (!regExp.hasMatch(value)) {
      return 'Correo inválido';
    } else {
      return null;
    }
  }

  //Función para validar los nombres y los apellidos
  String? validarNombreApellido(String? value) {
    String pattern = r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s']+$"; // Permitir solo letras, espacios y apóstrofe
    RegExp regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese un nombre';
    } else if (!regExp.hasMatch(value)) {
      return 'Solo se permiten letras';
    }
      return null;
  }

  void _mostrarNotificacionYRedirigir() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registro exitoso'),
        content: Text('Te has registrado correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => login(),
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/restaurante.jpg'), // Cambia a tu imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Container(
                width: screenWidth,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xBF9AD7E5).withOpacity(0.7),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Form(
                  key: _key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20.0),
                      // Campo Nombre
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: TextFormField(
                          controller: nombreControlador,
                          validator: validarNombreApellido,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0x29141218).withOpacity(0.2),
                            labelText: 'Nombre(s)',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Color del borde por defecto
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
                      SizedBox(height: 10),
                      // Campo Apellido
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: TextFormField(
                          controller: apellidoControlador,
                          validator: validarNombreApellido,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0x29141218).withOpacity(0.2),
                            labelText: 'Apellido(s)',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(
                              Icons.person_outline_outlined,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Color del borde por defecto
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
                      SizedBox(height: 10),
                      // Campo Correo
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: TextFormField(
                          controller: correoControlador,
                          validator: validarEmail,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0x29141218).withOpacity(0.2),
                            labelText: 'Correo',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Color del borde por defecto
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
                      SizedBox(height: 10),
                      // Campo Contraseña
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: TextFormField(
                          controller: contrasenaControlador,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "No se aceptan campos vacíos";
                            }
                            return null;
                          },
                          obscureText: !_mostrarContrasena,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0x29141218).withOpacity(0.2),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Contraseña",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.black,
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Color del borde por defecto
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
                      SizedBox(height: 10),
                      // Campo Confirmar Contraseña
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: TextFormField(
                          controller: confContrasenacontrolador,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "No se aceptan campos vacíos";
                            }
                            return null;
                          },
                          obscureText: !_mostrarConfContrasena,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0x29141218).withOpacity(0.2),
                            labelText: "Confirmar contraseña",
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarConfContrasena
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarConfContrasena =
                                      !_mostrarConfContrasena;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Color del borde por defecto
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF92DFF3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 80),
                        ),
                        onPressed: () {
                          if (_key.currentState!.validate()) {
                            //Validar las contraseñas
                            if (contrasenaControlador.text ==
                                confContrasenacontrolador.text) {
                              //Encriptar la contraseña
                              String contrasenaEncriptada = encriptarContrasena(
                                  contrasenaControlador.text);
                              // Imprimir los datos en la consola antes de insertar en la base de datos
                              print('Datos del usuario:');
                              print('Nombre: ${nombreControlador.text}');
                              print('Apellido: ${apellidoControlador.text}');
                              print('Correo: ${correoControlador.text}');
                              print(
                                  'Contraseña encriptada: $contrasenaEncriptada');

                              //Si las contraseñas coinciden, se registra el usuario
                              Operaciones.insertarAppbd(Nota(
                                nombre: nombreControlador.text,
                                apellido: apellidoControlador.text,
                                correo: correoControlador.text,
                                contrasena: contrasenaControlador.text,
                                confContrasena: confContrasenacontrolador.text,
                              ));
                              _mostrarNotificacionYRedirigir();
                            } else {
                              //Si las contraseñas no coinciden, le aparezca un error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Las contraseñas no coinciden'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text('Registrarse',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
