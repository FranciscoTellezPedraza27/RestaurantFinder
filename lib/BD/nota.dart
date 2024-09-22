
//Creacion del MODELO
class Nota {

  int? id;
  String nombre;
  String apellido;
  String correo;
  String contrasena;
  String confContrasena;

  Nota({this.id, required this.nombre, required this.apellido, required this.correo, required this.contrasena, required this.confContrasena});

  //Creacion del MAPA
  Map<String, dynamic> toMap(){
    return {
      'id':id,
      'nombre':nombre,
      'apellido':apellido,
      'correo':correo,
      'contrasena':contrasena,
      'confContrasena':confContrasena
      };
  }

  
}