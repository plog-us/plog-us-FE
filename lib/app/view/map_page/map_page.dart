import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plog_us/app/view/map_page/finish_page.dart';
import 'package:plog_us/app/view/plog_log_page/plog_log_page.dart';
import 'package:plog_us/app/view/theme/app_colors.dart';
import 'package:plog_us/app/controllers/login/login_controller.dart';
import 'package:plog_us/flavors/build_config.dart';

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

class Distance {
  final double latitude;
  final double longitude;

  Distance(this.latitude, this.longitude);
}

double calculateDistance(Distance location1, Distance location2) {
  const double earthRadius = 6371;

  double lat1Rad = degreesToRadians(location1.latitude);
  double lon1Rad = degreesToRadians(location1.longitude);
  double lat2Rad = degreesToRadians(location2.latitude);
  double lon2Rad = degreesToRadians(location2.longitude);

  double latDiff = lat2Rad - lat1Rad;
  double lonDiff = lon2Rad - lon1Rad;

  double a = pow(sin(latDiff / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(lonDiff / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return distance;
}

double degreesToRadians(double degrees) {
  return degrees * pi / 180;
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
  String plogUuid = "";
  String ploggingUuid = "";
  int? plogIdx;
  String plogdistance = "";
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
    mapController.dispose();
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
    final response = await http
        .get(Uri.parse('${BuildConfig.instance.config.baseUrl}/ploglocation'));
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
              children: _locations.asMap().entries.map((entry) {
                final int index = entry.key;
                final location = entry.value;
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
                      plogUuid = location.plogUuid.toString();
                      plogIdx = index;
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

  void _startPlogging(String startUuid, String userId) {
    if (isStreamingPaused) {
      _toggleStreamSubscription();
    }
    if (!isPloggingStarted) {
      setState(() {
        isPloggingStarted = true;
      });
      _postStartPlog(startUuid, userId);
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        double distance = calculateDistance(
            Distance(_locations[plogIdx!].plogLatitude,
                _locations[plogIdx!].plogLongitude),
            Distance(currentPosition!.latitude, currentPosition!.longitude));
        setState(() {
          Decimal plogDistanceDecimal =
              Decimal.parse(distance.toStringAsFixed(1));
          String plogDistanceString = plogDistanceDecimal.toString();
          print('현재 위치와 선택한 플로깅 위치 간의 거리: $plogdistance 킬로미터');
        });
      });
    } else {
      _stopPlogging(ploggingUuid);
    }
  }

  Future<void> _postStartPlog(String plogUuid, String userUuid) async {
    String apiUrl =
        '${BuildConfig.instance.config.baseUrl}/startplogging/$userUuid/$plogUuid';

    try {
      print(apiUrl);
      var response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData);
        setState(() {
          ploggingUuid = responseData.toString();
        });
        print("플로깅 시작 성공!");
      } else {
        print('플로깅 시작 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('시작 중 오류 발생: $e');
    }
  }

  Future<void> _postStopPlog(String ploggingUuid) async {
    String apiUrl =
        '${BuildConfig.instance.config.baseUrl}/finishplogging/$ploggingUuid';
    String finaldistance = plogdistance.toString();

    Map<String, dynamic> requestData = {'ploggingDistance': finaldistance};

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"content-type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print("플로깅이 종료되었습니다!");
      } else {
        print('플로깅 종료 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('종료 중 오류 발생: $e');
    }
  }

  void _stopPlogging(String finshUuid) {
    _postStopPlog(finshUuid);
    String location = locationName;
    print(locationName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinishScreen(
          locationName: location,
          stopwatch: _stopwatch,
          timer: _timer!,
          finalUuid: _locations[plogIdx!].plogUuid.toString(),
        ),
      ),
    );

    setState(() {
      isPloggingStarted = false;
      locationName = "";
      _stopwatch.stop();
      _timer?.cancel();
    });
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
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlogLogScreen(),
                ),
              );
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
                  if (locationName != "") {
                    _startPlogging(plogUuid, userId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        content: Text(
                          "업데이트 전입니다. 플로깅 추천 경로를 이용하세요",
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
