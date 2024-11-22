import 'package:aplicacion_maps/BD/nota.dart';
import 'package:aplicacion_maps/BD/operaciones.dart';
import 'package:aplicacion_maps/modulos/actualizar.dart';
import 'package:flutter/material.dart';

class usuarioRegistrado extends StatefulWidget {
  const usuarioRegistrado({super.key});

  @override
  State<usuarioRegistrado> createState() => _usuariosRegistradosState();
}

class _usuariosRegistradosState extends State<usuarioRegistrado> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Usuarios registrados',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),

      body: Center(
        child: Container(
          child: _miLista(),
        )
      ),
    );
  }
}

class _miLista extends StatefulWidget {

  @override
  State<_miLista> createState() => _miListaState();
}

class _miListaState extends State<_miLista> {
  List<Nota> notas=[];

  @override
  void initState() {
    _cargarDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notas.length,
      itemBuilder: (_, i) => _crearItem(i),
       );
  }

  _cargarDatos() async{
    List<Nota> auxNota= await Operaciones.notas();
    setState(() {
      notas= auxNota;
    });
     
  }

  _crearItem(int i) {
    return Dismissible( //widget que permite manipular los datos de un ListTitle
      key: Key(i.toString()),
      direction: DismissDirection.startToEnd, //permite laeliminacion de un elemento de la lista desplazandolo a de izquierda a derecha
      background: Container(
        color: Colors.blue,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.white,),
              Text("Eliminar", style: TextStyle(color: Colors.white),)
            ],
          ),
        ),
      ),
      onDismissed: (direction) {
        print("Eliminado");
        Operaciones.eliminarAppbd(notas[i]);  //llamamos al metodo eliminar de la clase Operaciones
      },
      child: ListTile(
        title: Text(notas[i].nombre),
        trailing: MaterialButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Actualizar(nota: notas[i]),));
          },
          child: Icon(Icons.edit),
          ),
      ),
    );
  }
}