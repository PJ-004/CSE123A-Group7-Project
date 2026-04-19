import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class JetsonAlert {
  final int level;
  final String levelLabel;
  final String message;
  final DateTime timestamp;

  const JetsonAlert({
    required this.level,
    required this.levelLabel,
    required this.message,
    required this.timestamp,
  });
}

class JetsonPresence {
  final String sourceId;
  final bool online;
  final DateTime timestamp;
  final String? eyeState;

  const JetsonPresence({
    required this.sourceId,
    required this.online,
    required this.timestamp,
    this.eyeState,
  });
}

class JetsonWebSocketService {
  JetsonWebSocketService({required this.uri});

  final Uri uri;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _manualDisconnect = false;
  String _state = 'Disconnected';

  final _alertsCtrl = StreamController<JetsonAlert>.broadcast();
  final _presenceCtrl = StreamController<JetsonPresence>.broadcast();
  final _stateCtrl = StreamController<String>.broadcast();

  Stream<JetsonAlert> get alerts => _alertsCtrl.stream;
  Stream<JetsonPresence> get presence => _presenceCtrl.stream;
  Stream<String> get connectionState => _stateCtrl.stream;
  String get currentState => _state;

  void _setState(String next) {
    _state = next;
    if (!_stateCtrl.isClosed) {
      _stateCtrl.add(next);
    }
  }

  Future<void> connect() async {
    if (_disposed) return;
    if (_state == 'Connected' ||
        _state.startsWith('Connecting') ||
        _state.startsWith('Reconnecting')) {
      return;
    }

    _manualDisconnect = false;
    _reconnectTimer?.cancel();
    _setState(_channel == null ? 'Connecting...' : 'Reconnecting...');

    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      _channelSub = channel.stream.listen(
        _onMessage,
        onDone: _handleSocketClosed,
        onError: _handleSocketError,
        cancelOnError: true,
      );
      _setState('Connected');
    } catch (_) {
      _handleSocketError(null);
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    await _closeChannel();
    _setState('Disconnected');
  }

  Future<void> _closeChannel() async {
    await _channelSub?.cancel();
    _channelSub = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _onMessage(dynamic raw) {
    final text = raw is String ? raw : utf8.decode(raw as List<int>);
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) return;

    final type = (decoded['type'] ?? '').toString();
    final data = decoded['data'];
    if (type == 'ping') {
      return;
    }
    if (data is! Map<String, dynamic>) {
      return;
    }

    if (type == 'alert') {
      final level = _coerceLevel(data['level']);
      final timestamp = _parseTimestamp(data['event_ts'] ?? data['received_ts']);
      _alertsCtrl.add(
        JetsonAlert(
          level: level,
          levelLabel: (data['level_label'] ?? _labelForLevel(level)).toString(),
          message: (data['message'] ?? 'Alert').toString(),
          timestamp: timestamp,
        ),
      );
      return;
    }

    if (type == 'jetson_presence') {
      final metadata = data['metadata'];
      _presenceCtrl.add(
        JetsonPresence(
          sourceId: (data['source_id'] ?? data['device_id'] ?? 'jetson')
              .toString(),
          online: _coerceOnline(data['online'] ?? data['status']),
          timestamp: _parseTimestamp(
            data['event_ts'] ?? data['timestamp'] ?? data['ts'],
          ),
          eyeState: metadata is Map
              ? _normalizeEyeState(metadata['eye_state'])
              : null,
        ),
      );
    }
  }

  String? _normalizeEyeState(dynamic raw) {
    final text = (raw ?? '').toString().trim().toLowerCase();
    switch (text) {
      case 'open':
        return 'Open';
      case 'closed':
        return 'Closed';
      case 'unknown':
        return 'Unknown';
      default:
        return null;
    }
  }

  int _coerceLevel(dynamic raw) {
    if (raw is int) {
      return raw.clamp(0, 2);
    }

    final text = (raw ?? '').toString().trim().toLowerCase();
    switch (text) {
      case '0':
      case 'safe':
      case 'normal':
      case 'info':
        return 0;
      case '2':
      case 'danger':
      case 'critical':
      case 'alert':
        return 2;
      case '1':
      case 'warning':
      case 'warn':
      case 'caution':
      default:
        return 1;
    }
  }

  bool _coerceOnline(dynamic raw) {
    if (raw is bool) return raw;
    final text = (raw ?? '').toString().trim().toLowerCase();
    return const {
      '1',
      'true',
      'yes',
      'on',
      'online',
      'up',
      'connected',
    }.contains(text);
  }

  DateTime _parseTimestamp(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      final normalized = raw.endsWith('Z') ? '${raw.substring(0, raw.length - 1)}+00:00' : raw;
      final parsed = DateTime.tryParse(normalized);
      if (parsed != null) {
        return parsed.toLocal();
      }
    }
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        (raw * 1000).round(),
        isUtc: true,
      ).toLocal();
    }
    return DateTime.now();
  }

  String _labelForLevel(int level) {
    switch (level) {
      case 0:
        return 'SAFE';
      case 2:
        return 'DANGER';
      default:
        return 'WARNING';
    }
  }

  void _handleSocketClosed() {
    _channel = null;
    _channelSub = null;
    if (_disposed || _manualDisconnect) {
      _setState('Disconnected');
      return;
    }
    _scheduleReconnect();
  }

  void _handleSocketError(Object? _) {
    _channel = null;
    _channelSub = null;
    if (_disposed || _manualDisconnect) {
      _setState('Disconnected');
      return;
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _setState('Reconnecting...');
    _reconnectTimer = Timer(const Duration(seconds: 3), connect);
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channelSub?.cancel();
    _channel?.sink.close();
    _alertsCtrl.close();
    _presenceCtrl.close();
    _stateCtrl.close();
  }
}
