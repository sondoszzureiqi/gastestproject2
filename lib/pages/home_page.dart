import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'order_history_page.dart'; // Import the Orders page
import 'profile_screen.dart'; // Import the Profile page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUsers;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  final CameraPosition googlePlexInitialPosition = const CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 14,
  );

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes('themes/standard_style.json')
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUsers = positionOfUser;

    LatLng positionOfUserInLatLng =
    LatLng(currentPositionOfUsers!.latitude, currentPositionOfUsers!.longitude);
    CameraPosition cameraPosition =
    CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId("user"),
        position: positionOfUserInLatLng,
        infoWindow: const InfoWindow(title: "You"),
      ));
    });

    LatLng sellerLocation = const LatLng(31.9642, 35.9255);
    _markers.add(Marker(
      markerId: const MarkerId("seller"),
      position: sellerLocation,
      infoWindow: const InfoWindow(title: "Gas Seller"),
    ));

    await getPolylineRoute(positionOfUserInLatLng, sellerLocation);
  }

  Future<void> getPolylineRoute(LatLng origin, LatLng destination) async {
    String apiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // <-- Replace this!
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if ((data["routes"] as List).isNotEmpty) {
        final points = data["routes"][0]["overview_polyline"]["points"];
        polylineCoordinates = decodePoly(points);

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ));
        });
      }
    } else {
      print("Failed to load directions: ${response.statusCode}");
    }
  }

  List<LatLng> decodePoly(String poly) {
    List<LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPosition,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                updateMapTheme(controllerGoogleMap!);
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLiveLocationOfUser();
              },
            ),
          ],
        );
      case 1:
        //return const OrderScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _getSelectedPage(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFF0D47A1),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
