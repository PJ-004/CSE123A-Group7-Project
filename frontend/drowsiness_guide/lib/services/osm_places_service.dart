import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OSMPlacesService {
  
  static const String _endpoint = 'https://overpass-api.de/api/interpreter';

  Future<List<PlaceSummary>> fetchNearestGasStations({
    required double lat,
    required double lon,
    int limit = 5,
    int radiusMeters = 5000,
  }) async {
   
    final query = '''
[out:json][timeout:10];
(
  node["amenity"="fuel"](around:$radiusMeters,$lat,$lon);
  way["amenity"="fuel"](around:$radiusMeters,$lat,$lon);
  relation["amenity"="fuel"](around:$radiusMeters,$lat,$lon);
);
out center $limit;
''';

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) {
      throw Exception('Overpass HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List? ?? const []);

    final places = <PlaceSummary>[];

    for (final el in elements) {
      if (el is! Map<String, dynamic>) continue;

      final pLat = (el['lat'] as num?)?.toDouble() ??
          (el['center']?['lat'] as num?)?.toDouble();
      final pLon = (el['lon'] as num?)?.toDouble() ??
          (el['center']?['lon'] as num?)?.toDouble();
      if (pLat == null || pLon == null) continue;

      final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
      final name = (tags['name'] ?? 'Fuel / Gas station').toString();

      final street = tags['addr:street']?.toString();
      final housenumber = tags['addr:housenumber']?.toString();
      final city = tags['addr:city']?.toString();
      final state = tags['addr:state']?.toString();

      final parts = <String>[];
      if (street != null) {
        parts.add(housenumber == null ? street : '$housenumber $street');
      }
      if (city != null) parts.add(city);
      if (state != null) parts.add(state);

      final vicinity = parts.join(', ');

      places.add(
        PlaceSummary(
          name: name,
          vicinity: vicinity,
          lat: pLat,
          lon: pLon,
        ),
      );

      if (places.length >= limit) break;
    }

    places.sort((a, b) {
      final da = _haversineMeters(lat, lon, a.lat, a.lon);
      final db = _haversineMeters(lat, lon, b.lat, b.lon);
      return da.compareTo(db);
    });

    return places.take(limit).toList();
  }

  /// 30 miles in meters (for rest stop radius).
  static const int _restStopRadiusMeters = 48280;

  /// Fetches all rest stops (highway=rest_area) within 30 miles of the given point.
  Future<List<PlaceSummary>> fetchRestStopsWithin30Miles({
    required double lat,
    required double lon,
  }) async {
    final query = '''
[out:json][timeout:15];
(
  node["highway"="rest_area"](around:$_restStopRadiusMeters,$lat,$lon);
  way["highway"="rest_area"](around:$_restStopRadiusMeters,$lat,$lon);
  relation["highway"="rest_area"](around:$_restStopRadiusMeters,$lat,$lon);
);
out center;
''';

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 18));

    if (res.statusCode != 200) {
      throw Exception('Overpass HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List? ?? const []);

    final places = <PlaceSummary>[];

    for (final el in elements) {
      if (el is! Map<String, dynamic>) continue;

      final pLat = (el['lat'] as num?)?.toDouble() ??
          (el['center']?['lat'] as num?)?.toDouble();
      final pLon = (el['lon'] as num?)?.toDouble() ??
          (el['center']?['lon'] as num?)?.toDouble();
      if (pLat == null || pLon == null) continue;

      final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
      final name = (tags['name'] ?? 'Rest area').toString();

      final street = tags['addr:street']?.toString();
      final housenumber = tags['addr:housenumber']?.toString();
      final city = tags['addr:city']?.toString();
      final state = tags['addr:state']?.toString();

      final parts = <String>[];
      if (street != null) {
        parts.add(housenumber == null ? street : '$housenumber $street');
      }
      if (city != null) parts.add(city);
      if (state != null) parts.add(state);

      final vicinity = parts.join(', ');

      places.add(
        PlaceSummary(
          name: name,
          vicinity: vicinity,
          lat: pLat,
          lon: pLon,
        ),
      );
    }

    places.sort((a, b) {
      final da = _haversineMeters(lat, lon, a.lat, a.lon);
      final db = _haversineMeters(lat, lon, b.lat, b.lon);
      return da.compareTo(db);
    });

    return places;
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double d) => d * (3.141592653589793 / 180.0);
}

class PlaceSummary {
  final String name;
  final String vicinity;
  final double lat;
  final double lon;

  const PlaceSummary({
    required this.name,
    required this.vicinity,
    required this.lat,
    required this.lon,
  });
}