import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Types of real-time events emitted by the LAN Hub.
enum HubEventType {
  matchAssigned,
  scoreUpdated,
  disputeFlagged,
  checkInVerified,
  checkInRejected,
  tournamentUpdated,
  heartbeat,
  unknown,
}

/// Represents a strongly typed event from the BeyScore LAN Hub.
class HubEvent {
  const HubEvent({
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  factory HubEvent.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String? ?? '';
    final type = switch (rawType) {
      'MATCH_ASSIGNED' => HubEventType.matchAssigned,
      'SCORE_UPDATED' => HubEventType.scoreUpdated,
      'DISPUTE_FLAGGED' => HubEventType.disputeFlagged,
      'CHECKIN_VERIFIED' => HubEventType.checkInVerified,
      'CHECKIN_REJECTED' => HubEventType.checkInRejected,
      'TOURNAMENT_UPDATED' => HubEventType.tournamentUpdated,
      'HEARTBEAT' => HubEventType.heartbeat,
      _ => HubEventType.unknown,
    };

    return HubEvent(
      type: type,
      payload: (json['payload'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  final HubEventType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'type': switch (type) {
          HubEventType.matchAssigned => 'MATCH_ASSIGNED',
          HubEventType.scoreUpdated => 'SCORE_UPDATED',
          HubEventType.disputeFlagged => 'DISPUTE_FLAGGED',
          HubEventType.checkInVerified => 'CHECKIN_VERIFIED',
          HubEventType.checkInRejected => 'CHECKIN_REJECTED',
          HubEventType.tournamentUpdated => 'TOURNAMENT_UPDATED',
          HubEventType.heartbeat => 'HEARTBEAT',
          HubEventType.unknown => 'UNKNOWN',
        },
        'payload': payload,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  @override
  String toString() => 'HubEvent(type: $type, payload: $payload)';
}

/// High-performance reactive WebSocket client for BeyScore LAN Hub.
///
/// Handles live events (sub-50ms latency), auto-reconnect with exponential backoff,
/// and client subscriptions (by player nickname or table number).
class HubRealtimeClient {
  HubRealtimeClient({
    this.initialBackoff = const Duration(milliseconds: 500),
    this.maxBackoff = const Duration(seconds: 5),
  });

  final Duration initialBackoff;
  final Duration maxBackoff;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  bool _isDisposed = false;
  bool _isConnected = false;
  String? _currentHubUrl;
  String? _registeredPlayer;
  int? _registeredTable;

  Duration _currentBackoff = const Duration(milliseconds: 500);

  final _eventController = StreamController<HubEvent>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  Stream<HubEvent> get events => _eventController.stream;
  Stream<bool> get connectionState => _connectionStateController.stream;
  bool get isConnected => _isConnected;

  /// Connects to the LAN Hub WebSocket server (e.g. `http://192.168.1.50:8080` or `192.168.1.50:8080`).
  void connect({
    required String hubUrl,
    String? playerNickname,
    int? tableNumber,
  }) {
    _isDisposed = false;
    _currentHubUrl = hubUrl;
    _registeredPlayer = playerNickname;
    _registeredTable = tableNumber;
    _currentBackoff = initialBackoff;

    _initiateConnection();
  }

  void _initiateConnection() {
    if (_isDisposed || _currentHubUrl == null) return;

    _reconnectTimer?.cancel();
    _cleanupChannel();

    try {
      final wsUrl = _formatWsUrl(_currentHubUrl!);
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (dynamic message) {
          if (!_isConnected) {
            _isConnected = true;
            _connectionStateController.add(true);
            _currentBackoff = initialBackoff;
            _sendRegistration();
            _startHeartbeat();
          }

          _handleIncomingMessage(message);
        },
        onError: (dynamic _) => _handleDisconnect(),
        onDone: _handleDisconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _sendRegistration() {
    if (!_isConnected || _channel == null) return;
    try {
      final regPayload = <String, dynamic>{
        'action': 'REGISTER',
        if (_registeredPlayer != null) 'player': _registeredPlayer,
        if (_registeredTable != null) 'table': _registeredTable,
      };
      _channel!.sink.add(jsonEncode(regPayload));
    } catch (_) {}
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'action': 'PING'}));
        } catch (_) {
          _handleDisconnect();
        }
      }
    });
  }

  void _handleIncomingMessage(dynamic message) {
    if (message is! String) return;
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) {
        final event = HubEvent.fromJson(decoded);
        _eventController.add(event);
      }
    } catch (_) {}
  }

  void _handleDisconnect() {
    if (_isDisposed) return;

    if (_isConnected) {
      _isConnected = false;
      _connectionStateController.add(false);
    }

    _cleanupChannel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || (_reconnectTimer != null && _reconnectTimer!.isActive)) return;

    _reconnectTimer = Timer(_currentBackoff, () {
      _currentBackoff = Duration(
        milliseconds: (_currentBackoff.inMilliseconds * 1.5).toInt().clamp(
              initialBackoff.inMilliseconds,
              maxBackoff.inMilliseconds,
            ),
      );
      _initiateConnection();
    });
  }

  void _cleanupChannel() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  String _formatWsUrl(String baseUrl) {
    var formatted = baseUrl.trim();
    if (formatted.startsWith('http://')) {
      formatted = 'ws://${formatted.substring(7)}';
    } else if (formatted.startsWith('https://')) {
      formatted = 'wss://${formatted.substring(8)}';
    } else if (!formatted.startsWith('ws://') && !formatted.startsWith('wss://')) {
      formatted = 'ws://$formatted';
    }
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (!formatted.endsWith('/ws')) {
      formatted = '$formatted/ws';
    }
    return formatted;
  }

  /// Closes connection and releases all resources.
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cleanupChannel();
    _eventController.close();
    _connectionStateController.close();
  }
}
