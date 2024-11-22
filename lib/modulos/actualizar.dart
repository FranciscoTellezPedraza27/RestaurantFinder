
import 'package:aplicacion_maps/BD/nota.dart';
import 'package:aplicacion_maps/BD/operaciones.dart';
import 'package:flutter/material.dart';

class Actualizar extends StatelessWidget {
  
  final Nota nota;
  final TextEditingController _nombreControlador;
  final TextEditingController _apellidoControlador;
  final TextEditingController _correoControlador;
  final TextEditingController _contrasenaControlador;
  final TextEditingController _confContrasenaControlador;
  final _key=GlobalKey<FormState>();

  Actualizar({super.key, required this.nota}):
  _nombreControlador=TextEditingController(text: nota.nombre),
  _apellidoControlador=TextEditingController(text:nota.apellido),
  _correoControlador=TextEditingController(text: nota.correo),
  _contrasenaControlador=TextEditingController(text: nota.contrasena),
  _confContrasenaControlador=TextEditingController(text: nota.confContrasena)
  ;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Actualizar',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.yellow, Colors.red],
          ),
        ),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  Text("Actualizar Usuario"),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: _nombreControlador,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No se adminten campos vacios";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Nombre:"
                    ),
                   ),
                   TextFormField(
                    controller: _apellidoControlador,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No se adminten campos vacios";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Apellidos:"
                    ),
                   ),
                   TextFormField(
                    controller: _correoControlador,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No se adminten campos vacios";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Correo Electronico:"
                    ),
                   ),
                   TextFormField(
                    controller: _contrasenaControlador,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No se adminten campos vacios";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Contraseña:"
                    ),
                   ),
                   TextFormField(
                    controller: _confContrasenaControlador,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No se adminten campos vacios";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Confirmar Contraseña:"
                    ),
                   ),
                   SizedBox(
                    height: 10,
                   ),
                  OutlinedButton(
                    onPressed: () {
                      if (_key.currentState!.validate()) {
                        nota.nombre=_nombreControlador.text;
                        nota.apellido=_apellidoControlador.text;
                        nota.correo=_correoControlador.text;
                        nota.contrasena=_contrasenaControlador.text;
                        nota.confContrasena=_confContrasenaControlador.text;                      
                        
                        Operaciones.actualizarAppbd(nota);

                        print("Usuario Actualizado...");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario Actualizado'))); //Mostrar mensaje
                      
                             }
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => listamodulos(),));
                  }, child: Text("Actualizar"))
              ],
              ),
            ),
        ),
      );
  }
}
