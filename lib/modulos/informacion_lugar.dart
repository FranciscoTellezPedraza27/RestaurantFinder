import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    fetchPlaceDetails();
  }

  Future<void> fetchPlaceDetails() async {
    final apiKey =
        'AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI'; // Reemplaza con tu API key
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&key=$apiKey&language=es';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        placeDetails = json.decode(response.body)['result'];
      });
    } else {
      print('Failed to load place details');
    }
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
        ],
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

  Widget _buildResenas() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        childAspectRatio: 1.5, // Relación de aspecto para las tarjetas
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: placeDetails!['reviews']?.length ?? 0,
      itemBuilder: (context, index) {
        final review = placeDetails!['reviews'][index];
        final profilePhotoUrl =
            review['profile_photo_url'] ?? ''; // URL de la foto del perfil

        return Card(
          elevation: 4, // Sombra de la tarjeta
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              // Permite el desplazamiento
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: profilePhotoUrl.isNotEmpty
                            ? NetworkImage(profilePhotoUrl)
                            : null, // Cargar la imagen del perfil
                        radius: 20, // Tamaño del avatar
                        child: profilePhotoUrl
                                .isEmpty // Texto en caso de no tener imagen
                            ? Text(
                                'U',
                                style: TextStyle(color: Colors.white),
                              )
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

  Widget _buildReservarSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          // Implementa la lógica para hacer una reserva
        },
        child: Text('Reservar'),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
