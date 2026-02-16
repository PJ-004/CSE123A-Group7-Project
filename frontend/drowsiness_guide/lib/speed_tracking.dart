//Idea for implementing speed using the built in Geolocator of flutter

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeedTracker {
  Stream<Position>? _positionStream;
  
  // Initialize location tracking
  Future<bool> initializeTracking() async {
    // Request location permission
    var status = await Permission.location.request();
    if (!status.isGranted) {
      return false;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    return true;
  }

  Stream<double> getSpeedStream() async* {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    await for (Position position in _positionStream!) {
      double speedMps = position.speed;
      
      double speedKmh = speedMps * 3.6;
      
      yield speedKmh;
    }
  }

  Future<double> getCurrentSpeed() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    return position.speed * 3.6;
  }
}

class SpeedDisplay extends StatefulWidget {
  @override
  _SpeedDisplayState createState() => _SpeedDisplayState();
}

class _SpeedDisplayState extends State<SpeedDisplay> {
  final SpeedTracker _speedTracker = SpeedTracker();
  double _currentSpeed = 0.0;
  
  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    bool initialized = await _speedTracker.initializeTracking();
    
    if (initialized) {
      _speedTracker.getSpeedStream().listen((speed) {
        setState(() {
          _currentSpeed = speed;
        });
      });
    } else {
      // Handle permission denied
      print("Location permission not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speed Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_currentSpeed.toStringAsFixed(1)} km/h',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '${(_currentSpeed * 0.621371).toStringAsFixed(1)} mph',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}