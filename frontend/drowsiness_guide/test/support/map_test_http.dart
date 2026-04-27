import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Valid 1×1 PNG for stubbing map tile requests under [http.runWithClient].
final Uint8List kStubMapTilePng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

/// Options for [createMapTestHttpClient].
class MapHttpStubOptions {
  MapHttpStubOptions({
    this.overpassFail = false,
    this.routeGet500 = false,
    this.tableFail = false,
    this.fuelStopCount = 2,
  });

  /// When true, Overpass POST returns HTTP 500 (all mirrors fail in one hop).
  bool overpassFail;

  /// OSRM route GET returns 500.
  bool routeGet500;

  /// OSRM table GET throws / fails (non-200) so driving distances fall back to 0.
  bool tableFail;

  /// Number of fuel nodes in the Overpass JSON (>= 1).
  int fuelStopCount;
}

/// Minimal OpenWeather JSON for [WeatherService.fetchCurrent].
String _openWeatherBody() => jsonEncode({
      'weather': [
        {'main': 'Clear'},
      ],
      'main': {'temp': 70.0},
    });

/// Overpass-style elements for fuel stops near the default test coordinates.
String _overpassFuelBody(int count) {
  final elements = <Map<String, Object?>>[];
  for (var i = 0; i < count; i++) {
    elements.add({
      'type': 'node',
      'lat': 37.001 + i * 0.002,
      'lon': -122.051 - i * 0.002,
      'tags': {
        'amenity': 'fuel',
        'name': 'Test Fuel $i',
      },
    });
  }
  return jsonEncode({'elements': elements});
}

/// Valid OSRM route GeoJSON for driving between two nearby points.
String _osrmRouteBody() {
  return jsonEncode({
    'routes': [
      {
        'distance': 8046.7,
        'duration': 720.0,
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [-122.05, 37.0],
            [-122.051, 37.001],
            [-122.052, 37.002],
          ],
        },
      },
    ],
  });
}

/// OSRM table matrix: one row from user (source 0) to each coordinate.
String _osrmTableBody(int stopCount) {
  final n = stopCount + 1;
  final distances = List<num>.generate(n, (i) => i * 1000.0);
  final durations = List<num>.generate(n, (i) => i * 60.0);
  return jsonEncode({
    'code': 'Ok',
    'distances': [distances],
    'durations': [durations],
  });
}

http.Client createMapTestHttpClient([MapHttpStubOptions? options]) {
  final o = options ?? MapHttpStubOptions();

  return MockClient((request) async {
    final u = request.url;

    if (u.host.contains('cartocdn.com')) {
      return http.Response.bytes(
        kStubMapTilePng,
        200,
        headers: {'content-type': 'image/png'},
      );
    }

    if (u.host == 'api.openweathermap.org') {
      return http.Response(_openWeatherBody(), 200);
    }

    if (u.host == 'router.project-osrm.org') {
      if (u.path.contains('/table/')) {
        if (o.tableFail) {
          return http.Response('', 503);
        }
        var stopCount = o.fuelStopCount;
        final drivingIdx = u.path.indexOf('/driving/');
        if (drivingIdx >= 0) {
          var tail = u.path.substring(drivingIdx + '/driving/'.length);
          final q = tail.indexOf('?');
          if (q >= 0) tail = tail.substring(0, q);
          final coordCount = tail.split(';').length;
          if (coordCount > 1) stopCount = coordCount - 1;
        }
        return http.Response(_osrmTableBody(stopCount), 200);
      }
      if (u.path.contains('/route/')) {
        if (o.routeGet500) {
          return http.Response('err', 500);
        }
        return http.Response(_osrmRouteBody(), 200);
      }
    }

    final isOverpass = u.host.contains('overpass') &&
        (u.path.contains('interpreter') || u.path.endsWith('/api/interpreter'));
    if (isOverpass && request.method == 'POST') {
      if (o.overpassFail) {
        return http.Response('fail', 500);
      }
      return http.Response(_overpassFuelBody(o.fuelStopCount), 200);
    }

    return http.Response('unstubbed: ${request.method} $u', 404);
  });
}
