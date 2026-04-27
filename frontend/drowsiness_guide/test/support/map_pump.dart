import 'package:flutter_test/flutter_test.dart';

/// Pumps until OSRM routing populates the banner or a routing error appears.
Future<void> pumpUntilMapRouteSettled(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (tester.any(find.textContaining(' mi • ')) ||
        tester.any(find.textContaining('Route error')) ||
        tester.any(find.textContaining('Routing failed')) ||
        tester.any(find.text('No route found.'))) {
      return;
    }
  }
  fail('Map did not show route or error within timeout');
}

/// Waits for a status substring (permission / services messages).
Future<void> pumpUntilStatusContains(
  WidgetTester tester,
  Pattern pattern, {
  int maxPumps = 40,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (tester.any(find.textContaining(pattern))) return;
  }
  fail('Status did not contain $pattern');
}
