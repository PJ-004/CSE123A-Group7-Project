import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  var curr;

  late StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Updates always
      ),
    ).listen((Position position) {
      curr = '${position.latitude}, ${position.longitude}';
    });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('$curr'),
        ),
      ),
    );
  }
}