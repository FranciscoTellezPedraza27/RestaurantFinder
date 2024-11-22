import 'dart:async';
import 'dart:convert';
import 'package:aplicacion_maps/modulos/reservar.dart';
import 'package:aplicacion_maps/modulos/reservas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class InformacionLugar extends StatefulWidget {
  final String placeId;

  InformacionLugar({required this.placeId});

  @override
  _InformacionLugarState createState() => _InformacionLugarState();
}

class _InformacionLugarState extends State<InformacionLugar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? placeDetails;
  String? imageUrl;
  List<String> reviewList = [];
  final TextEditingController _reviewController = TextEditingController();
  String selectedDay = '';
  String? currentOpeningHours;
  bool showAllHours = false; // Controla si se muestran todos los horarios
  final List<String> daysOfWeek = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    fetchPlaceDetails();
    loadReviews();

    //Escucha los cambios de pestaña activa para mostrar los campos necesarios
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        // Muestra el formulario de reseñas al cambiar a la pestaña de reseñas
        setState(() {});
      }
    }); 
  }

  Future<void> loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Usar el PlaceID como clave para almacenar las reseñas
      reviewList = prefs.getStringList('reviewList_${widget.placeId}') ?? [];
    });
  }

  //Guardar la imagen del lugar
  String? mainImageURL; //Variable para almacenar la URL de la imagen principal


  Future<void> fetchPlaceDetails() async {
    final apiKey =
        'AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI'; // Reemplaza con tu API key
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&key=$apiKey&language=es';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        placeDetails = json.decode(response.body)['result'];

        //Obtiene la URL de la imagen principal
        if (placeDetails!['photos'] != null && placeDetails!['photos'].isNotEmpty){
          final photoReference = placeDetails!['photos'][0]['photo_reference'];
          mainImageURL = 
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
        }
      });
    } else {
      print('Failed to load place details');
    }
  }

  // Modificar el método _addReview para recibir la calificación como parámetro
  void _addReview(String review, double rating) async {
    setState(() {
      reviewList.add(json.encode({'text': review, 'rating': rating}));
      _reviewController.clear(); //Limpia el campo de texto
    });

    //Guarda las lista de reseñas
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('reviewList_${widget.placeId}', reviewList);
  }

  @override
  Widget build(BuildContext context) {
    if (placeDetails == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAcercaDe(),
                _buildFotos(),
                _buildResenas(),
              ],
            ),
          ),
          _buildReservarSection(),

          // Muestra el formulario de reseñas en la pestaña de reseñas
          if (_tabController.index == 2) _buildReviewInput(),
        ],
      ),
    );
  }

  final TextEditingController _ratingController = TextEditingController();//Controlador para las reseñas

  Widget _buildReviewInput() {
    double rating = 0.0;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      padding: const EdgeInsets.all(8.0), // Añade un relleno interno
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey.shade100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Escribe una reseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                rating = newRating;
              },
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_reviewController.text.isNotEmpty) {
                  _addReview(_reviewController.text, rating);
                }
              },
              child: Text("Enviar reseña"),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Column(
      children: [
        // Cinta de imágenes
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: placeDetails!['photos']?.length ?? 0,
            itemBuilder: (context, index) {
              final photoReference =
                  placeDetails!['photos'][index]['photo_reference'];
              final photoUrl =
                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(photoUrl),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        // Nombre del lugar
        Text(
          placeDetails!['name'] ?? 'Nombre del lugar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '${placeDetails!['formatted_address'] ?? 'Dirección no disponible'}',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.star, color: Colors.yellow),
            Text(
                '${placeDetails!['rating']?.toString() ?? 'Sin calificación'} (${placeDetails!['user_ratings_total'] ?? 0} reseñas)'),
            Icon(Icons.favorite_border),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'Acerca de'),
          Tab(text: 'Fotos'),
          Tab(text: 'Reseñas'),
        ],
      ),
    );
  }

  Widget _buildAcercaDe() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SizedBox(height: 16),
        if (placeDetails!['opening_hours'] != null) ...[
          _buildHorarioDeApertura(),
          SizedBox(height: 16),
        ],
        if (placeDetails!['formatted_phone_number'] != null) ...[
          SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.phone,
            text: 'Teléfono: ${placeDetails!['formatted_phone_number']}',
          ),
        ],
        if (placeDetails!['user_ratings_total'] != null) ...[
          SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.star,
            text: 'Total de reseñas: ${placeDetails!['user_ratings_total']}',
          ),
        ],
        if (placeDetails!['website'] != null) ...[
          SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.link,
            text: 'Sitio web: ${placeDetails!['website']}',
          ),
        ],
      ],
    );
  }

  Widget _buildHorarioDeApertura() {
    final currentDayIndex = DateTime.now().weekday - 1;
    selectedDay = daysOfWeek[currentDayIndex];
    final openingHours = placeDetails!['opening_hours']['weekday_text'];
    currentOpeningHours = openingHours[currentDayIndex];

    return GestureDetector(
      onTap: () {
        setState(() {
          showAllHours =
              !showAllHours; // Alterna la visibilidad de los horarios
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horarios de apertura',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildInfoCard(
            // Tarjeta para el horario de apertura
            icon: Icons.access_time,
            text:
                '$selectedDay: ${currentOpeningHours ?? 'Horario no disponible'}',
            showAll: showAllHours,
            allHours: List.generate(openingHours.length, (index) {
              String hours = openingHours[index];
              return '$hours';
            }),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String text,
      bool showAll = false,
      List<String>? allHours}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(text, style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            if (showAll && allHours != null) ...[
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allHours
                    .map((hour) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(hour, style: TextStyle(fontSize: 16)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFotos() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: placeDetails!['photos']?.length ?? 0,
      itemBuilder: (context, index) {
        final photoReference =
            placeDetails!['photos'][index]['photo_reference'];
        final photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI';
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(photoUrl, fit: BoxFit.cover),
        );
      },
    );
  }

  bool isValidJson(String source) {
    try {
      json.decode(source);
      return true;
    } catch (e) {
      return false;
    }
  }

// Modificar el método _addReview para recibir la calificación como parámetro
  Widget _buildResenas() {
  // Combina las reseñas existentes de placeDetails con las nuevas de reviewList
  final combinedReviews = List<Map<String, dynamic>>.from(placeDetails!['reviews'] ?? [])
    ..addAll(reviewList.where(isValidJson).map((jsonString) => json.decode(jsonString)));

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    padding: EdgeInsets.all(8.0),
    itemCount: combinedReviews.length,
    itemBuilder: (context, index) {
      final review = combinedReviews[index];
      final profilePhotoUrl = review['profile_photo_url'] ?? '';

      return Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: profilePhotoUrl.isNotEmpty
                          ? NetworkImage(profilePhotoUrl)
                          : null,
                      radius: 20,
                      child: profilePhotoUrl.isEmpty
                          ? Text('U', style: TextStyle(color: Colors.white))
                          : null,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review['author_name'] ?? 'Autor desconocido',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(review['text'] ?? 'Sin reseña'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Text('${review['rating'] ?? 'Sin calificación'}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

@override
void dispose() {
  _tabController.dispose();
  super.dispose();
  }

  Widget _buildReservarSection() {
  // Verifica si la pestaña activa es la de reseñas
  if (_tabController.index == 2) {
    return SizedBox.shrink();
  }
  return Container(
    padding: EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: () {
        // Aquí se navega para reservar un lugar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Reservar(
              imageUrl: mainImageURL, // Imagen del lugar
              direccion: placeDetails!['formatted_address'] ?? 'Dirección no disponible', 
              calificacion: placeDetails!['rating']?.toDouble() ?? 0.0, // Calificación del lugar
              placeId: widget.placeId, // Pasa el placeId
            ),
          ),
        );
      },
      child: Text('Reservar una mesa'),
    ),
  );
}
}
