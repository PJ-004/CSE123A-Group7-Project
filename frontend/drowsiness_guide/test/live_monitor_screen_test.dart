import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drowsiness_guide/screens/live_monitor_screen.dart';
import 'package:drowsiness_guide/services/ble_service.dart';
import 'package:drowsiness_guide/services/jetson_websocket_service.dart';

class FakeBleService extends BleService {
  final StreamController<String> _stateCtrl = StreamController<String>.broadcast();
  final StreamController<BleAlert> _alertCtrl = StreamController<BleAlert>.broadcast();

  @override
  Stream<String> get connectionState => _stateCtrl.stream;

  @override
  Stream<BleAlert> get alerts => _alertCtrl.stream;

  void emitState(String state) => _stateCtrl.add(state);

  @override
  Future<void> scanAndConnect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  void dispose() {
    _stateCtrl.close();
    _alertCtrl.close();
  }
}

class FakeJetsonWebSocketService extends JetsonWebSocketService {
  FakeJetsonWebSocketService()
    : super(uri: Uri.parse('ws://localhost:8080/ws/alerts?replay=0'));

  final StreamController<String> _stateCtrl = StreamController<String>.broadcast();
  final StreamController<JetsonAlert> _alertCtrl =
      StreamController<JetsonAlert>.broadcast();
  final StreamController<JetsonPresence> _presenceCtrl =
      StreamController<JetsonPresence>.broadcast();

  @override
  Stream<String> get connectionState => _stateCtrl.stream;

  @override
  Stream<JetsonAlert> get alerts => _alertCtrl.stream;

  @override
  Stream<JetsonPresence> get presence => _presenceCtrl.stream;

  void emitState(String state) => _stateCtrl.add(state);

  void emitAlert({required int level, required String message}) {
    _alertCtrl.add(
      JetsonAlert(deviceId: 'jetson-1', level: level, message: message),
    );
  }

  @override
  Future<void> connect() async {
    _stateCtrl.add('Connected');
  }

  @override
  Future<void> disconnect() async {
    _stateCtrl.add('Disconnected');
  }

  @override
  void dispose() {
    _stateCtrl.close();
    _alertCtrl.close();
    _presenceCtrl.close();
  }
}

Future<void> pumpLiveMonitor(
  WidgetTester tester, {
  required FakeBleService ble,
  required FakeJetsonWebSocketService jetson,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LiveMonitorScreen(
        bleService: ble,
        jetsonWsService: jetson,
        locationLoader: () async => (lat: 36.97410, lon: -122.03080),
        weatherLoader: (lat, lon) async => (condition: 'Clear', tempText: '72F'),
      ),
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('BLE label updates when BLE state changes', (tester) async {
    final ble = FakeBleService();
    final jetson = FakeJetsonWebSocketService();

    await pumpLiveMonitor(tester, ble: ble, jetson: jetson);

    expect(find.text('Disconnected'), findsWidgets);

    ble.emitState('Connected');
    await tester.pump();

    expect(find.text('Connected'), findsWidgets);
  });

  testWidgets('Jetson WS label updates when websocket state changes', (
    tester,
  ) async {
    final ble = FakeBleService();
    final jetson = FakeJetsonWebSocketService();

    await pumpLiveMonitor(tester, ble: ble, jetson: jetson);

    jetson.emitState('Reconnecting...');
    await tester.pump();

    expect(find.text('Reconnecting...'), findsWidgets);
  });

  testWidgets('Alert label updates when an alert is received', (tester) async {
    final ble = FakeBleService();
    final jetson = FakeJetsonWebSocketService();

    await pumpLiveMonitor(tester, ble: ble, jetson: jetson);

    expect(find.text('None'), findsOneWidget);

    jetson.emitAlert(level: 2, message: 'Eyes closed too long');
    await tester.pump();

    expect(find.text('DANGER'), findsWidgets);
  });

  testWidgets('Lat and Lon labels render injected location values', (
    tester,
  ) async {
    final ble = FakeBleService();
    final jetson = FakeJetsonWebSocketService();

    await pumpLiveMonitor(tester, ble: ble, jetson: jetson);

    expect(find.text('36.97410'), findsOneWidget);
    expect(find.text('-122.03080'), findsOneWidget);
  });
}
