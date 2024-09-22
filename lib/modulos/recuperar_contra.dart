import 'package:flutter/material.dart';

class RecuperarContra extends StatefulWidget {
  const RecuperarContra({super.key});

  @override
  State<RecuperarContra> createState() => _RecuperarContraState();
}

class _RecuperarContraState extends State<RecuperarContra> {
  final _key = GlobalKey<FormState>();
  final correoControlador = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recuperar Contraseña',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 183, 226, 234),
              Color.fromARGB(255, 1, 138, 202)
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 300,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: correoControlador,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "No se aceptan campos vacíos";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Correo",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      if (_key.currentState!.validate()) {
                        // Aquí puedes agregar la lógica para recuperar la contraseña
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Se ha enviado un enlace para recuperar la contraseña')),
                        );

                        // Redirigir o hacer otras acciones según sea necesario
                      }
                    },
                    child: Text("Enviar enlace de recuperación"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
