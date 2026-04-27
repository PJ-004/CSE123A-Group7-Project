import 'package:drowsiness_guide/screens/osm_map_screen.dart';
import 'package:drowsiness_guide/services/osm_places_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'support/delayed_geolocator_platform.dart';
import 'support/fake_geolocator_platform.dart';
import 'support/fake_url_launcher_platform.dart';
import 'support/map_pump.dart';
import 'support/map_test_http.dart';

void main() {
  GeolocatorPlatform? savedGeo;
  UrlLauncherPlatform? savedUrl;

  setUp(() {
    savedGeo ??= GeolocatorPlatform.instance;
    savedUrl ??= UrlLauncherPlatform.instance;
    OSMPlacesService.clearCachesForTesting();
  });

  tearDown(() {
    GeolocatorPlatform.instance = savedGeo!;
    UrlLauncherPlatform.instance = savedUrl!;
    OSMPlacesService.clearCachesForTesting();
  });

  Future<void> pumpMapMaterialApp(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: child,
      ),
    );
  }

  testWidgets('M1 title Map is shown', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.text('Map'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('M2 app bar tooltips and map icons', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.byTooltip('Re-center'), findsOneWidget);
      expect(find.byTooltip('Re-route'), findsOneWidget);
      expect(find.byTooltip('Reload stops'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('M3 re-center disabled until position resolves', (tester) async {
    final delayed = DelayedFakeGeolocatorPlatform();
    GeolocatorPlatform.instance = delayed;
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await tester.pump();
      expect(
        tester.widget<IconButton>(find.byKey(const ValueKey('mapReCenter'))).onPressed,
        isNull,
      );
      delayed.completePosition();
      await pumpUntilMapRouteSettled(tester);
      expect(
        tester.widget<IconButton>(find.byKey(const ValueKey('mapReCenter'))).onPressed,
        isNotNull,
      );
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('M4 re-route enabled after route is ready', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(
        tester.widget<IconButton>(find.byKey(const ValueKey('mapReRoute'))).onPressed,
        isNotNull,
      );
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('M5 reload stops disabled until position resolves', (tester) async {
    final delayed = DelayedFakeGeolocatorPlatform();
    GeolocatorPlatform.instance = delayed;
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await tester.pump();
      expect(
        tester.widget<IconButton>(find.byKey(const ValueKey('mapReloadStops'))).onPressed,
        isNull,
      );
      delayed.completePosition();
      await pumpUntilMapRouteSettled(tester);
      expect(
        tester.widget<IconButton>(find.byKey(const ValueKey('mapReloadStops'))).onPressed,
        isNotNull,
      );
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('S1 early status mentions loading or permission', (tester) async {
    final delayed = DelayedFakeGeolocatorPlatform();
    GeolocatorPlatform.instance = delayed;
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await tester.pump();
      final loadingOrPermission = find.byWidgetPredicate(
        (w) =>
            w is Text &&
            ((w.data?.contains('Loading location') == true) ||
                (w.data?.contains('Requesting location permission') == true) ||
                (w.data?.contains('Getting current position') == true)),
      );
      expect(tester.any(loadingOrPermission), isTrue);
      delayed.completePosition();
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('S2 permission denied forever', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      checkPermissionResult: LocationPermission.deniedForever,
    );
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilStatusContains(tester, 'Location permission denied forever');
      expect(find.textContaining('Location permission denied forever'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('S3 location services disabled', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      locationServiceEnabled: false,
    );
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilStatusContains(tester, 'Location services are disabled');
      expect(find.textContaining('Location services are disabled'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('S4 route banner shows miles and minutes', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.textContaining(' mi • '), findsOneWidget);
      expect(find.textContaining('min'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('S5 route HTTP error message', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.textContaining('Route error: HTTP 500'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions(routeGet500: true)));
  });

  testWidgets('S6 stops failure surfaces error text', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilStatusContains(tester, 'Exception');
      expect(find.textContaining('Exception'), findsWidgets);
    }, () => createMapTestHttpClient(MapHttpStubOptions(overpassFail: true)));
  });

  testWidgets('G1 main Navigate records Google Maps dir URL', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    final launcher = RecordingFakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = launcher;
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      await tester.tap(find.byKey(const ValueKey('mapNavigateMain')));
      await tester.pump();
      expect(launcher.lastLaunchedUrl, isNotNull);
      expect(launcher.lastLaunchedUrl, contains('google.com/maps/dir'));
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('G2 row Navigate launches URL for that stop', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    final launcher = RecordingFakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = launcher;
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      await tester.tap(find.byKey(const ValueKey('mapMoreStops')));
      await tester.pump(const Duration(milliseconds: 400));
      final navigates = find.byTooltip('Navigate');
      expect(navigates, findsNWidgets(3));
      await tester.tap(navigates.at(2));
      await tester.pump();
      expect(launcher.lastLaunchedUrl, contains('37.003'));
      expect(launcher.lastLaunchedUrl, contains('-122.053'));
    }, () => createMapTestHttpClient(MapHttpStubOptions(fuelStopCount: 2)));
  });

  testWidgets('G3 failed launch shows SnackBar', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    final launcher = RecordingFakeUrlLauncherPlatform(launchReturns: false);
    UrlLauncherPlatform.instance = launcher;
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      await tester.tap(find.byKey(const ValueKey('mapNavigateMain')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Could not open Google Maps.'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('T1 More hidden with only one stop', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.byKey(const ValueKey('mapMoreStops')), findsNothing);
    }, () => createMapTestHttpClient(MapHttpStubOptions(fuelStopCount: 1)));
  });

  testWidgets('T2 More expands list and Close collapses', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.byTooltip('Navigate'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('mapMoreStops')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byTooltip('Navigate'), findsNWidgets(3));
      await tester.tap(find.text('Close'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byTooltip('Navigate'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions(fuelStopCount: 2)));
  });

  testWidgets('T3 table API fail shows Distance unavailable', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      await tester.tap(find.byKey(const ValueKey('mapMoreStops')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Distance unavailable'), findsWidgets);
    }, () => createMapTestHttpClient(MapHttpStubOptions(fuelStopCount: 2, tableFail: true)));
  });

  testWidgets('P1 FlutterMap is present', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(FlutterMap), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('P2 OpenStreetMap attribution visible', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('OpenStreetMap'), findsOneWidget);
      expect(find.textContaining('CARTO'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions()));
  });

  testWidgets('B2 stops count chip after load', (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.textContaining('Stops: 2'), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions(fuelStopCount: 2)));
  });

  testWidgets('A1 no-arg flow picks closest stop and shows route info',
      (tester) async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    await http.runWithClient(() async {
      await pumpMapMaterialApp(tester, const OSMMapScreen());
      await pumpUntilMapRouteSettled(tester);
      expect(find.textContaining('Test Fuel'), findsOneWidget);
      expect(find.textContaining(' mi • '), findsOneWidget);
    }, () => createMapTestHttpClient(MapHttpStubOptions(fuelStopCount: 2)));
  });
}
