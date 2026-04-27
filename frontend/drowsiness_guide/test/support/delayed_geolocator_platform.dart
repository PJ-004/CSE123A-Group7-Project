import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'fake_geolocator_platform.dart';

/// Holds back [getCurrentPosition] until [completePosition] is called (for M3/M5).
class DelayedFakeGeolocatorPlatform extends GeolocatorPlatform {
  final Completer<Position> _positionCompleter = Completer<Position>();

  void completePosition([Position? p]) {
    if (!_positionCompleter.isCompleted) {
      _positionCompleter.complete(p ?? testMapPosition());
    }
  }

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) =>
      _positionCompleter.future;
}
