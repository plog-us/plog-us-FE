import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';
import 'package:plog_us/app/controllers/login/login_controller.dart';

class Location {
  final int plogUuid;
  final String plogAddress;
  final double plogLatitude;
  final double plogLongitude;
  final int plogCount;

  Location({
    required this.plogUuid,
    required this.plogAddress,
    required this.plogLatitude,
    required this.plogLongitude,
    required this.plogCount,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      plogUuid: json['plogUuid'],
      plogAddress: json['plogAddress'],
      plogLatitude: json['plogLatitude'],
      plogLongitude: json['plogLongitude'],
      plogCount: json['plogCount'],
    );
  }
}

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
  late List<Location> _locations;
  BitmapDescriptor? customMarkerIcon;
  String locationName = "";
  int? locationUuid;
  bool isStreamingPaused = false;
  bool isPloggingStarted = false;
  // ignore: prefer_final_fields
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadCustomMarker();
    _fetchLocations();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    _stopwatch.stop();
    _timer?.cancel();
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

  void _toggleStreamSubscription() {
    setState(() {
      isStreamingPaused = !isStreamingPaused;
    });

    if (isStreamingPaused) {
      positionStreamSubscription?.pause();
    } else {
      positionStreamSubscription?.resume();
    }
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
            infoWindow: const InfoWindow(title: '내 위치'),
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

  Future<void> _fetchLocations() async {
    final response =
        await http.get(Uri.parse('http://35.212.137.41:8080/ploglocation'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Location> locations =
          data.map((json) => Location.fromJson(json)).toList();
      setState(() {
        _locations = locations;
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  void _showLocationPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('플로깅 장소 고르기'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _locations.map((location) {
                return ListTile(
                  title: Text(location.plogAddress),
                  onTap: () {
                    _toggleStreamSubscription();
                    _moveToLocation(
                        location.plogLatitude, location.plogLongitude);

                    setState(() {
                      markers.add(
                        Marker(
                          markerId: MarkerId(location.plogUuid.toString()),
                          position: LatLng(
                              location.plogLatitude, location.plogLongitude),
                          infoWindow: InfoWindow(title: location.plogAddress),
                          icon: customMarkerIcon!,
                        ),
                      );
                    });

                    setState(() {
                      locationName = location.plogAddress;
                      locationUuid = location.plogUuid;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _moveToLocation(double latitude, double longitude) {
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(latitude, longitude)),
    );
  }

  void _startPlogging(int locationUuid, String userId) {
    if (isStreamingPaused) {
      _toggleStreamSubscription();
    }
    if (!isPloggingStarted) {
      setState(() {
        isPloggingStarted = true;
      });
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {});
      });
    } else {
      _stopPlogging(locationUuid, userId);
    }
  }

  Future<void> _postStartPlog(int locationUuid, String userId) async {
    String apiUrl =
        'http://35.212.137.41:8080/startplogging/$userId/$locationUuid';

    try {
      var response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print("플로깅 시작 성공!");
      } else {
        print('플로깅 시작 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('시작 중 오류 발생: $e');
    }
  }

  void _stopPlogging(int locationUuid, String userId) {
    setState(() {
      isPloggingStarted = false;
      locationName = "";
      _stopwatch.stop();
      _timer?.cancel();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('플로깅 종료'),
          content: Text(
            '플로깅 시간: ${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.find<LoginController>();
    String userId = loginController.userId.value;
    LatLng currentLatLng = LatLng(
      currentPosition?.latitude ?? 37.54647500000001,
      currentPosition?.longitude ?? 126.9646916,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plog Map'),
        backgroundColor: AppColors.cardBackground,
        actions: [
          if (!isStreamingPaused)
            IconButton(
              icon: const Icon(Icons.directions_walk),
              onPressed: _showLocationPopup,
            ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              print('카메라인식페이지로 이동');
            },
          ),
          if (isStreamingPaused)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _toggleStreamSubscription,
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
                radius: 50,
                fillColor: Colors.blue.withOpacity(0.2),
                strokeColor: Colors.blue,
                strokeWidth: 2,
              ),
            },
            markers: markers,
          ),
          Positioned(
            top: 16,
            left: 16,
            child: isPloggingStarted
                ? Column(
                    children: [
                      const Text(
                        "플로깅 중입니다",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        ' ${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (locationUuid != null) {
                    _startPlogging(locationUuid!, userId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.black,
                        content: Text(
                          "플로깅 추천을 이용해주세요!",
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size(100.0, 56.0)),
                  backgroundColor: isPloggingStarted
                      ? MaterialStateProperty.all(AppColors.redOrigin)
                      : MaterialStateProperty.all(AppColors.greenOrigin),
                ),
                child: Text(
                  isPloggingStarted
                      ? '플로깅 종료'
                      : (locationName != ""
                          ? '$locationName에서 플로깅 시작하기'
                          : "플로깅 시작하기"),
                  style: TextStyle(
                    fontSize: 18.0,
                    color:
                        isPloggingStarted ? AppColors.white : AppColors.black,
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
