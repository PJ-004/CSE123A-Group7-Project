import 'package:drowsiness_guide/screens/live_monitor_screen.dart';
import 'package:drowsiness_guide/screens/osm_map_screen.dart';
import 'package:drowsiness_guide/services/osm_places_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'support/fake_geolocator_platform.dart';
import 'support/map_pump.dart';
import 'support/map_test_http.dart';

void main() {
  GeolocatorPlatform? savedGeo;

  setUp(() {
    savedGeo ??= GeolocatorPlatform.instance;
    OSMPlacesService.clearCachesForTesting();
  });

  tearDown(() {
    GeolocatorPlatform.instance = savedGeo!;
    OSMPlacesService.clearCachesForTesting();
  });

  testWidgets(
    'N1 DROWSINESS DETECTED opens Map route',
    (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const LiveMonitorScreen(),
          routes: {'/map': (_) => const OSMMapScreen()},
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.ensureVisible(find.byKey(const ValueKey('drowsinessDetectedBar')));
      await tester.tap(find.byKey(const ValueKey('drowsinessDetectedBar')));
      await tester.pump();
      await pumpUntilMapRouteSettled(tester);
      expect(find.text('Map'), findsOneWidget);
      // Drain LiveMonitor Jetson WebSocket `ready.timeout(8s)` pending timers.
      await tester.pump(const Duration(seconds: 10));
    }, () => createMapTestHttpClient(MapHttpStubOptions()));

  testWidgets(
    'N2 back from Map returns to live monitor',
    (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const LiveMonitorScreen(),
          routes: {'/map': (_) => const OSMMapScreen()},
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.ensureVisible(find.byKey(const ValueKey('drowsinessDetectedBar')));
      await tester.tap(find.byKey(const ValueKey('drowsinessDetectedBar')));
      await tester.pump();
      await pumpUntilMapRouteSettled(tester);
      expect(find.text('Map'), findsOneWidget);

      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('blink'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });
}
