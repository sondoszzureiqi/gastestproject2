import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastestproject/consts.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Map<PolylineId, Polyline> polylines = {};
  String? _userRole;

  @override
  void initState() {
    super.initState();
    determineRole();
  }

  Future<void> determineRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _userRole = userDoc.data()?['role'];

    await getLocationUpdates();

    if (_userRole == 'buyer') {
      listenToNearbySellers();
      placeOrder(); // Demo: simulate placing an order
    } else if (_userRole == 'seller') {
      listenToOrderForSeller(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => _mapController.complete(controller),
        initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
        myLocationEnabled: _userRole == 'buyer',
        myLocationButtonEnabled: true,
        markers: _markers,
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await _locationController.requestService();
    if (!serviceEnabled) return;

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((locData) async {
      if (locData.latitude == null || locData.longitude == null) return;
      final LatLng pos = LatLng(locData.latitude!, locData.longitude!);
      setState(() => _currentPosition = pos);
      _moveCamera(pos);

      if (_userRole == 'seller') {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('sellers').doc(uid).set({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'last_updated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  void listenToNearbySellers() {
    FirebaseFirestore.instance.collection('sellers').snapshots().listen((snapshot) {
      if (_currentPosition == null) return;
      Set<Marker> sellerMarkers = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final LatLng sellerPos = LatLng(data['latitude'], data['longitude']);
        if (_calculateDistance(_currentPosition!, sellerPos) <= 5.0) {
          sellerMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: sellerPos,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(title: "Nearby Seller"),
            ),
          );
        }
      }
      setState(() => _markers = sellerMarkers);
    });
  }

  void placeOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _currentPosition == null) return;

    final randomSellerSnapshot = await FirebaseFirestore.instance.collection('sellers').limit(1).get();
    if (randomSellerSnapshot.docs.isEmpty) return;

    final sellerDoc = randomSellerSnapshot.docs.first;
    final sellerId = sellerDoc.id;

    await FirebaseFirestore.instance.collection('orders').add({
      'buyerId': uid,
      'sellerId': sellerId,
      'buyerLat': _currentPosition!.latitude,
      'buyerLng': _currentPosition!.longitude,
      'status': 'pending',
    });
  }

  void listenToOrderForSeller(String sellerId) {
    FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final order = snapshot.docs.first.data();
        final LatLng buyerPos = LatLng(order['buyerLat'], order['buyerLng']);
        showRouteToBuyer(buyerPos);
      }
    });
  }

  void showRouteToBuyer(LatLng buyerLocation) async {
    if (_currentPosition == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: google_Maps_Key,
      request: PolylineRequest(
        origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        destination: PointLatLng(buyerLocation.latitude, buyerLocation.longitude),
        mode: TravelMode.driving,
      ),
    );

    List<LatLng> polylineCoordinates = result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      _markers = {
        Marker(markerId: const MarkerId('buyer'), position: buyerLocation),
        Marker(markerId: const MarkerId('seller'), position: _currentPosition!),
      };
      polylines[PolylineId('route')] = Polyline(
        polylineId: const PolylineId('route'),
        points: polylineCoordinates,
        color: Colors.green,
        width: 6,
      );
    });
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const earthRadius = 6371; // in km
    final dLat = _deg2rad(pos2.latitude - pos1.latitude);
    final dLng = _deg2rad(pos2.longitude - pos1.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(pos1.latitude)) * cos(_deg2rad(pos2.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  void _moveCamera(LatLng pos) async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLng(pos));
  }
}

