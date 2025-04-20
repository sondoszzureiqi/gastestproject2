import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LiveTrackingMap extends StatefulWidget {
  const LiveTrackingMap({super.key});

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  LatLng _initialPosition = const LatLng(0, 0);
  LatLng? _currentPosition;
  Marker? _sellerMarker;
  List<LatLng> _trail = [];
  double _distanceTravelled = 0;
  bool _tracking = true;
  BitmapDescriptor? _truckIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _startLiveLocationTracking();
  }

  Future<void> _loadCustomMarker() async {
    _truckIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/robust-pickup-truck-icon-vector-removebg-preview.png', // Make sure to add this icon in your assets folder
    );
  }

  Future<void> _startLiveLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (!_tracking) return;

      LatLng updatedLatLng = LatLng(position.latitude, position.longitude);

      if (_currentPosition != null) {
        _distanceTravelled += Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          updatedLatLng.latitude,
          updatedLatLng.longitude,
        );
      }

      setState(() {
        _currentPosition = updatedLatLng;
        _trail.add(updatedLatLng);
        _sellerMarker = Marker(
          markerId: const MarkerId("seller"),
          position: updatedLatLng,
          icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: "Distance: ${_distanceTravelled.toStringAsFixed(1)} m"),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: updatedLatLng, zoom: 16),
        ),
      );
    });
  }

  void _toggleTracking() {
    setState(() {
      _tracking = !_tracking;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 14),
            markers: _sellerMarker != null ? {_sellerMarker!} : {},
            polylines: {
              Polyline(
                polylineId: const PolylineId("trail"),
                color: Colors.blueAccent,
                width: 4,
                points: _trail,
              )
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Text(
                "Distance Traveled: ${_distanceTravelled.toStringAsFixed(1)} meters",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _toggleTracking,
              label: Text(_tracking ? "Pause" : "Resume"),
              icon: Icon(_tracking ? Icons.pause : Icons.play_arrow),
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
