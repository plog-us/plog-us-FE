import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  StreamSubscription<Position>? positionStreamSubscription;
  Position? currentPosition;
  Set<Marker> markers = {};
  BitmapDescriptor? customMarkerIcon;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadCustomMarker();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      _getCurrentLocation();
      _startLocationUpdates();
    } else {
      await Permission.location.request();
    }
  }

  void _startLocationUpdates() {
    positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentPosition = position;
        _updateCameraPosition();
      });
    });
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
        _updateCameraPosition();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _updateCameraPosition() {
    if (currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
        ),
      );

      setState(() {
        markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(
              currentPosition!.latitude,
              currentPosition!.longitude,
            ),
            infoWindow: const InfoWindow(title: 'Current Location'),
            icon: customMarkerIcon!,
          ),
        };
      });
    }
  }

  Future<void> _loadCustomMarker() async {
    final ByteData byteData =
        await rootBundle.load('assets/images/location.png');
    final Uint8List byteList = byteData.buffer.asUint8List();
    customMarkerIcon = BitmapDescriptor.fromBytes(
      byteList,
      size: const Size(20, 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng = LatLng(
      currentPosition?.latitude ?? 37.54647500000001,
      currentPosition?.longitude ?? 126.9646916,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plog Map'),
        backgroundColor: const Color.fromARGB(255, 143, 169, 144),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              print('Camera icon pressed!');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentLatLng,
              zoom: 16.0,
            ),
            circles: {
              Circle(
                circleId: const CircleId('circle'),
                center: currentLatLng,
                radius: 120,
                fillColor: Colors.blue.withOpacity(0.2),
                strokeColor: Colors.blue,
                strokeWidth: 2,
              ),
            },
            markers: markers,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  print('플로깅이 시작되었습니다!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(56.0), // Set button height
                ),
                child: const Text(
                  '플로깅 시작',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
