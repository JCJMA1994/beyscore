import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Broadcast beacon and discovery service over local UDP broadcast.
///
/// Enables table tablets and spectator devices to find the tournament Hub
/// automatically on the same Wi-Fi subnet without manual IP entry.
class LanDiscoveryService {
  LanDiscoveryService({this.port = 8889});

  final int port;
  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _listenSocket;
  Timer? _beaconTimer;

  /// Starts broadcasting the Hub URL periodically over UDP broadcast.
  Future<void> startBeacon({
    required String hubUrl,
    required String tournamentName,
  }) async {
    stopBeacon();

    try {
      _broadcastSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
      );
      _broadcastSocket!.broadcastEnabled = true;

      final payload = utf8.encode(
        jsonEncode({
          'service': 'beyscore-hub',
          'hubUrl': hubUrl,
          'tournament': tournamentName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      _beaconTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        try {
          _broadcastSocket?.send(
            payload,
            InternetAddress('255.255.255.255'),
            port,
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  /// Stops the broadcast beacon.
  void stopBeacon() {
    _beaconTimer?.cancel();
    _beaconTimer = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
  }

  /// Listens for a Hub beacon broadcast on the local network.
  ///
  /// Returns the discovered Hub URL, or null if timed out.
  Future<String?> discoverHubUrl({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final completer = Completer<String?>();

    try {
      _listenSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        port,
        reuseAddress: true,
      );

      final timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.complete(null);
          _listenSocket?.close();
          _listenSocket = null;
        }
      });

      _listenSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _listenSocket?.receive();
          if (datagram != null) {
            try {
              final raw = utf8.decode(datagram.data);
              final map = jsonDecode(raw) as Map<String, dynamic>;
              if (map['service'] == 'beyscore-hub' && map['hubUrl'] != null) {
                timer.cancel();
                if (!completer.isCompleted) {
                  completer.complete(map['hubUrl'] as String);
                }
                _listenSocket?.close();
                _listenSocket = null;
              }
            } catch (_) {}
          }
        }
      });
    } catch (_) {
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future;
  }
}
