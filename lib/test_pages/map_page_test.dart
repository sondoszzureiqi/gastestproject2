import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocationAndSellers();
  }

  Future<void> _initLocationAndSellers() async {
    await _getLocationUpdates();
  }

  Future<void> _getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((LocationData locationData) async {
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng newPosition = LatLng(locationData.latitude!, locationData.longitude!);
        setState(() {
          _currentPosition = newPosition;
        });

        _moveCameraToPosition(newPosition);
        await _loadNearestSeller(newPosition);
      }
    });
  }

  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  Future<void> _loadNearestSeller(LatLng userLocation) async {
    final snapshot = await FirebaseFirestore.instance.collection('sellers').where('isAvailable', isEqualTo: true).get();
    if (snapshot.docs.isEmpty) return;

    double shortestDistance = double.infinity;
    DocumentSnapshot? nearestSeller;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sellerLat = data['location']['lat'];
      final sellerLng = data['location']['lng'];
      double distance = _calculateDistance(userLocation.latitude, userLocation.longitude, sellerLat, sellerLng);

      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestSeller = doc;
      }
    }

    if (nearestSeller != null) {
      final sellerLocation = nearestSeller['location'];
      final LatLng sellerPos = LatLng(sellerLocation['lat'], sellerLocation['lng']);

      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId("seller"),
            position: sellerPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: "Nearest Seller"),
          ),
        };
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        myLocationEnabled: true, // Blue dot (Google default)
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        markers: _markers,
      ),
    );
  }
}
