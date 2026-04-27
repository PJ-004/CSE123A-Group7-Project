import 'package:geolocator/geolocator.dart';

/// Fixed position used across map tests (Santa Cruz area).
Position testMapPosition({double lat = 37.0, double lon = -122.05}) {
  return Position(
    latitude: lat,
    longitude: lon,
    timestamp: DateTime.utc(2026, 1, 1),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  FakeGeolocatorPlatform({
    this.checkPermissionResult = LocationPermission.whileInUse,
    this.requestPermissionResult = LocationPermission.whileInUse,
    this.locationServiceEnabled = true,
    Position? currentPosition,
  }) : _position = currentPosition ?? testMapPosition();

  LocationPermission checkPermissionResult;
  LocationPermission requestPermissionResult;
  bool locationServiceEnabled;
  Position _position;

  set position(Position value) => _position = value;

  @override
  Future<LocationPermission> checkPermission() async => checkPermissionResult;

  @override
  Future<LocationPermission> requestPermission() async =>
      requestPermissionResult;

  @override
  Future<bool> isLocationServiceEnabled() async => locationServiceEnabled;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async =>
      _position;
}
