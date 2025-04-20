// ✅ Updated MapPage with Firebase Integration for Real-Time Seller Location
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../global/global_var.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _currentP;
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    listenToSellers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      )
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
        initialCameraPosition: CameraPosition(target: _currentP!, zoom: 15),
        markers: _markers,
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        LatLng currentLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);

        setState(() {
          _currentP = currentLatLng;
          _markers.add(
            Marker(
              markerId: MarkerId("currentLocation"),
              position: currentLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: "You are here"),
            ),
          );
          _cameraToPosition(currentLatLng);
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('sellers').doc(user.uid).set({
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude,
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  void listenToSellers() {
    FirebaseFirestore.instance.collection('sellers').snapshots().listen((snapshot) {
      Set<Marker> updatedMarkers = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          updatedMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(data['latitude'], data['longitude']),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(title: "Seller: ${doc.id}"),
            ),
          );
        }
      }
      setState(() {
        _markers.addAll(updatedMarkers);
      });
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleMapKey,
      request: PolylineRequest(
        origin: PointLatLng(_currentP?.latitude ?? 0, _currentP?.longitude ?? 0),
        destination: PointLatLng(_currentP?.latitude ?? 0.001, _currentP?.longitude ?? 0.001),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("route");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}
