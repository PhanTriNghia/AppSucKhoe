// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
//
// class WalkingPage extends StatefulWidget {
//   const WalkingPage({super.key});
//
//   @override
//   State<WalkingPage> createState() => _WalkingPageState();
// }
//
// class _WalkingPageState extends State<WalkingPage> {
//   MapController mapController = MapController();
//   Location location = Location();
//   List<LatLng> routeCoordinates = [];
//   bool isTracking = false;
//   double currentSpeed = 0.0; // in meters per second
//   late StreamSubscription<LocationData> locationSubscription;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Walking'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FlutterMap(
//               options: MapOptions(
//                 center: LatLng(10.776183323564736, 106.66732187988492),
//                 zoom: 12,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                   "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c'],
//                 ),
//                 PolylineLayer(
//                   polylines: [
//                     Polyline(
//                       points: routeCoordinates,
//                       color: Colors.blue,
//                       strokeWidth: 4.0,
//                     ),
//                   ],
//                 ),
//                 MarkerLayer(
//                   markers: [
//                     if (isTracking && routeCoordinates.isNotEmpty)
//                       Marker(
//                         point: LatLng(
//                           routeCoordinates.last.latitude,
//                           routeCoordinates.last.longitude,
//                         ),
//                         child: Icon(
//                           Icons.location_on,
//                           color: Colors.red,
//                           size: 30.0,
//                         ),
//                       )
//                   ],
//                 ),
//               ],
//               mapController: mapController,
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   if (!isTracking) {
//                     startTracking();
//                   } else {
//                     stopTracking();
//                   }
//                 },
//                 child: Text(isTracking ? 'Stop' : 'Start'),
//               ),
//               Text('Speed: ${convertSpeed(currentSpeed).toInt()} km/h'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void startTracking() {
//     setState(() {
//       isTracking = true;
//       routeCoordinates.clear();
//     });
//
//     // Start tracking location
//     locationSubscription =
//         location.onLocationChanged.listen((LocationData currentLocation) {
//           if (isTracking) {
//             setState(() {
//               final LatLng newLatLng =
//               LatLng(currentLocation.latitude!, currentLocation.longitude!);
//               routeCoordinates.add(newLatLng);
//               mapController.move(newLatLng, 15.0);
//
//               // Calculate speed in meters per second
//               currentSpeed = currentLocation.speed ?? 0.0;
//
//               print(
//                   'latitude: ${currentLocation.latitude} | longitude: ${currentLocation.longitude} | speed: $currentSpeed');
//             });
//           }
//         });
//   }
//
//   void stopTracking() {
//     setState(() {
//       isTracking = false;
//       currentSpeed = 0.0;
//     });
//
//     // Cancel the location subscription
//     locationSubscription.cancel();
//   }
//
//   // Convert speed from meters per second to kilometers per hour
//   int convertSpeed(double speedInMetersPerSecond) {
//     return (speedInMetersPerSecond * 3.6).toInt();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthylife/model/CustomExercise.dart';
import 'package:healthylife/util/color_theme.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'dart:math' as math;

import '../../model/UserDetail.dart';

class WalkingPage extends StatefulWidget {
  UserDetail userDetail;

  WalkingPage({super.key, required this.userDetail});

  @override
  State<WalkingPage> createState() => _WalkingPageState();
}

class _WalkingPageState extends State<WalkingPage> {
  final MapController _mapController = MapController();
  LatLng? currentLocation;
  List<LatLng> positions = []; // List to store tracked positions
  bool isTracking = false;
  late DateTime startTime = DateTime.now(); // Variable to store the start time

  double speed = 0.0; // Movement speed in m/s
  num calorieBurnPerSecond = 0;
  num duration = 0;
  num distance = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clearTrackingData();
    print(widget.userDetail.UserWeight);
  }

  Future<void> updateWalking(String userID, String dateHistory) async {
    final walkingCollection =
        FirebaseFirestore.instance.collection('CustomExercise');

    final walkingQuerySnapshot = await walkingCollection
        .where('UserID', isEqualTo: userID)
        .where('DateHistory', isEqualTo: dateHistory)
        .get();

    if (walkingQuerySnapshot.docs.isNotEmpty) {
      final document = walkingQuerySnapshot.docs.first;

      num _calories = document['CustomExerciseCalo'] + calorieBurnPerSecond;
      num _duration = document['CustomExerciseDuration'] + duration;

      print(_calories);
      print(calorieBurnPerSecond);

      await walkingCollection.doc(document.id).update({
        'CustomExerciseCalo': _calories,
        'CustomExerciseDuration': _duration
      });

      // Nếu dữ liệu chưa có sẽ tạo rỗng
    } else {
      final uid = walkingCollection.doc().id;

      CustomExercise customExercise = CustomExercise(
          uid,
          widget.userDetail.UserID,
          'Chạy bộ',
          calorieBurnPerSecond,
          duration,
          getDate(DateTime.now()));

      await walkingCollection
          .doc(customExercise.CustomExerciseID)
          .set(customExercise.toJson());
    }
  }

  void clearTrackingData() {
    setState(() {
      positions.clear();
      isTracking = false;
      speed = 0;
      calorieBurnPerSecond = 0;
      duration = 0;
    });
  }

  Future<void> _getCurrentLocation() async {
    final locationData = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
      print("Latitude: " +
          locationData.latitude.toString() +
          " | Longitude: " +
          locationData.longitude.toString());
    });
  }

  void _startTracking() async {
    positions.clear();
    await _getCurrentLocation();
    positions.add(currentLocation!); // Add initial position
    setState(() {
      isTracking = true;
      startTime = DateTime.now();
    });
    _trackLocation();
  }

  void _stopTracking() {
    setState(() {
      isTracking = false;
      speed = 0;
    });
  }

  _trackLocation() async {
    if (isTracking) {
      final locationData = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final newPosition = LatLng(locationData.latitude, locationData.longitude);
      positions.add(newPosition); // Add new position to trail

      print(
          "Latitude: ${locationData.latitude} | Longitude: ${locationData.longitude}");
      print("This is speed: " + locationData.speed.toString());

      // Update current speed with the instantaneous speed provided by locationData
      setState(() {
        speed = locationData.speed ??
            0.0; // Use 0.0 as default speed if speed is null
        currentLocation = newPosition;
      });

      _mapController.move(
          currentLocation!, 18); // Keep map centered on current location

      await _calculateCalorieBurn(
          speed, widget.userDetail.UserHeight, widget.userDetail.UserWeight);

      await _calculateDistance();

      _calculateDuration();

      await _trackLocation();
    }
  }

  String getDate(DateTime _selectedDate) {
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  String getFormatDuration(num minutes) {
    if(minutes < 1) {
      return "${(duration * 60).toStringAsFixed(0)} giây";
    } else {
      int totalSeconds = (minutes * 60).floor();
      int minutesPart = totalSeconds ~/ 60;
      int secondsPart = totalSeconds % 60;
      String formattedDuration = '$minutesPart phút ';

      if (secondsPart > 0) {
        formattedDuration += '$secondsPart giây';
      }

      return formattedDuration + " ";
    }
  }

  _calculateDuration() {
    // Calculate the duration in seconds
    final durationInSeconds = DateTime.now().difference(startTime).inSeconds;

    setState(() {
      duration = durationInSeconds / 60;
    });

    print('Duration: ${duration.toStringAsFixed(2)} minutes');
  }

  _calculateCalorieBurn(double speed, num weight, num height) {
    // Constants
    const double speedFactor = 2.0;
    const double weightFactor = 0.035;
    const double heightFactor = 0.029;

    // Calculate calorie burn per minute
    double calorieBurnPerMinute = (weightFactor * weight) +
        ((speed * speedFactor) / height) * heightFactor * weight;

    print("Speed: " + speed.toString());

    setState(() {
      // Convert calorie burn per minute to per second
      calorieBurnPerSecond +=
          calorieBurnPerMinute / 60; // Convert to per second
    });

    print(calorieBurnPerSecond);
  }

  _calculateDistance() {
    distance = 0.0;
    for (int i = 0; i < positions.length - 1; i++) {
      double _distance = Geolocator.distanceBetween(
        positions[i].latitude,
        positions[i].longitude,
        positions[i + 1].latitude,
        positions[i + 1].longitude,
      );
      distance += _distance;
    }
    // Chuyển đổi từ mét sang kilômét
    distance /= 1000;

    // Sử dụng biểu thức điều kiện để quyết định cách hiển thị dữ liệu
    if (distance < 1) {
      // Nếu khoảng cách nhỏ hơn 1km, hiển thị trong mét
      print("Distance: ${(distance * 1000).toStringAsFixed(0)} m");
    } else {
      // Ngược lại, hiển thị trong kilômét
      print("Distance: ${distance.toStringAsFixed(2)} km");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(10.776183323564736, 106.66732187988492),
              zoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: positions,
                    color: Colors.blue,
                    strokeWidth: 6,
                  ),
                ],
              ),
              CurrentLocationLayer(
                alignDirectionOnUpdate: AlignOnUpdate.always,
                followOnLocationUpdate: FollowOnLocationUpdate.always,
                turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 1 / 4,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ColorTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 5/6,
                  height: MediaQuery.of(context).size.width * 0.12,
                  child: ElevatedButton(
                    style: isTracking
                        ? ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.backgroundColor,
                            // màu nền của button
                            foregroundColor: Colors.white,
                            // màu chữ của button
                            shape: RoundedRectangleBorder(
                              // border radius của button
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white, width: 2),
                            ),
                          )
                        : ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            // màu nền của button
                            foregroundColor: ColorTheme.backgroundColor,
                            // màu chữ của button
                            shape: RoundedRectangleBorder(
                              // border radius của button
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                    onPressed: () async {
                      if (!isTracking) {
                        _startTracking();
                      } else {
                        _stopTracking();
                        await updateWalking(
                            widget.userDetail.UserID, getDate(DateTime.now()));
                        // clearTrackingData();
                      }
                    },
                    child: Text(isTracking ? 'Dừng' : 'Bắt đầu',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Vận tốc: ',
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${speed.toStringAsFixed(2)} m/s",
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Quãng đường đã đi được: ',
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              distance < 1 ? "${(distance * 1000).toStringAsFixed(0)} m" : "${distance.toStringAsFixed(2)} km",
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Calo đã tiêu thụ: ',
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${calorieBurnPerSecond.toStringAsFixed(0)} calo",
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Thời gian đã đi được: ',
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              getFormatDuration(duration),
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
