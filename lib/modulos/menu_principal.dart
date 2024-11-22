import 'package:aplicacion_maps/modulos/informacion_lugar.dart';
import 'package:aplicacion_maps/modulos/login.dart';
import 'package:aplicacion_maps/modulos/reservas.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedPlaceId; // Variable para guardar el placeId seleccionado

  int currentIndex = 0;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = Set<Marker>();
  TextEditingController _searchController = TextEditingController();

  final GlobalKey<ReservasScreenState> _reservasKey = GlobalKey();

  //final ReservasScreen reservasScreen = ReservasScreen();

  // Agregamos una lista de reservas
  List<Map<String, dynamic>> _reservas = [];

  // Variable para almacenar la información del lugar seleccionado
  Map<String, dynamic>? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _saveAppState();
  }

  void _saveAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMapScreen', true);
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está deshabilitado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están denegados permanentemente.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ));
    }

    _fetchNearbyRestaurants(position.latitude, position.longitude);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 15,
        ),
      ));
    }
  }

  void _fetchNearbyRestaurants(double lat, double lng) async {
    final String apiKey =
        'AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI'; // Reemplaza con tu propia API Key
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&type=restaurant&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _markers.clear();
        for (var place in data['results']) {
          //Se asegura que "Ubicación" almacene tanto "vicinity" como "formated_address"
          place['ubicacion'] = place['vicinity'] ?? place['formateted_address'];

          final marker = Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(place['geometry']['location']['lat'],
                place['geometry']['location']['lng']),
            onTap: () {
              setState(() {
                _selectedPlace = place;
                _selectedPlaceId =
                    _selectedPlace?['place_id']; // Agrega esta línea
              });
            },
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['ubicacion'],
            ),
          );
          _markers.add(marker);
        }
      });
    } else {
      throw Exception('Error al cargar lugares');
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (_currentPosition == null) return;
    final String apiKey = 'AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI';
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=1500&type=restaurant&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _markers.clear();
        for (var place in data['results']) {
          final marker = Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(place['geometry']['location']['lat'],
                place['geometry']['location']['lng']),
            onTap: () {
              setState(() {
                _selectedPlace = place;
              });
            },
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['formatted_address'],
            ),
          );
          _markers.add(marker);
        }
      });
    } else {
      throw Exception('Error al buscar lugares');
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); //Limpia todas las preferencias guardadas

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }

  void _reloadReservasIfNeed() {
    if (currentIndex == 1) {
      _reservasKey.currentState?.cargarReservasExternamente();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [
            Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target:
                        LatLng(37.7749, -122.4194), // Ubicación predeterminada
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onTap: (LatLng position) {
                    setState(() {
                      _selectedPlace = null;
                    });
                  },
                ),
                if (_selectedPlace != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        String? selectedPlaceId = _selectedPlace!['place_id'];
                        if (selectedPlaceId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    InformacionLugar(placeId: selectedPlaceId)),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              _selectedPlace!['photos'] != null &&
                                      _selectedPlace!['photos'].isNotEmpty &&
                                      _selectedPlace!['photos'][0]
                                              ['photo_reference'] !=
                                          null
                                  ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${_selectedPlace!['photos'][0]['photo_reference']}&key=AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI'
                                  : 'https://via.placeholder.com/400',
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedPlace!['name'] ?? 'Nombre no disponible',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _selectedPlace!['ubicacion'] ??
                                  'Ubicación no disponible',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (index) {
                                double rating =
                                    _selectedPlace!['rating'] != null
                                        ? _selectedPlace!['rating'].toDouble()
                                        : 0.0;
                                return Icon(
                                  Icons.star,
                                  color: index < rating
                                      ? Colors.amber
                                      : Colors.grey,
                                  size: 20,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.logout_sharp),
                    onPressed: _logout,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 65,
                  right: 65,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar lugar...',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _searchPlaces(_searchController.text);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ReservasScreen(
              key: _reservasKey,
              placeId: null, // Pasa un valor nulo si no se ha seleccionado un lugar
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
              _reloadReservasIfNeed(); //Verifica si es necesario recargar las reservas
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.place, color: Color.fromARGB(255, 32, 32, 32)),
                label: "Mapa"),
            BottomNavigationBarItem(
                icon: Icon(Icons.turned_in_not,
                    color: Color.fromARGB(255, 32, 32, 32)),
                label: "Reservas"),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (Navigator.of(context).canPop()) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
}
