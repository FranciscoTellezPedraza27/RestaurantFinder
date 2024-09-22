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
  int currentIndex = 0;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = Set<Marker>();
  TextEditingController _searchController = TextEditingController();

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
      return Future.error('Los permisos de ubicación están denegados permanentemente.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
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
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14,
        ),
      ));
    }
  }

  Future<void> _fetchNearbyRestaurants(double lat, double lng) async {
    final String apiKey = 'AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI'; // Reemplaza con tu propia API Key
    final String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1500&type=restaurant&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _markers.clear();
        for (var place in data['results']) {
          final marker = Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']),
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['vicinity'],
            ),
          );
          _markers.add(marker);
        }
      });
    } else {
      throw Exception('Error al cargar lugares');
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('¿Deseas cerrar la aplicación?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sí'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _searchPlaces(String query) async {
    if (_currentPosition == null) return;
    final String apiKey = 'AIzaSyCgat8vWDnwurpGuIoo5n5eO68pIZ-1kWI';
    final String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=1500&type=restaurant&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _markers.clear();
        for (var place in data['results']) {
          final marker = Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']),
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

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentIndex == 0 ? 'Lugares cercanos' : 'Reservas'),
          backgroundColor: Colors.cyan,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            )
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194), // Ubicación predeterminada
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                ),
                Positioned(
                  top: 16,
                  left: 65,
                  right: 65,
                  child: Container(
                    alignment: Alignment.center,
                    width: 150,
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar lugares de comida',
                        fillColor: Colors.transparent,
                        filled: true,
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
              ],
            ),
            ReservasScreen(), // Asegúrate de que esta clase esté correctamente definida
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.place, color: Color.fromARGB(255, 32, 32, 32), ), label: "Mapa",),
            BottomNavigationBarItem(icon: Icon(Icons.turned_in_not, color: Color.fromARGB(255, 32, 32, 32)), label: "Reservas"),
          ],
        ),
      ),
    );
  }
}
