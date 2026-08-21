import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cryptographically signed QR pairing token for tablet devices mounted on stadiums.
///
/// Ensures tables pair ONLY with the organizer's legitimate tournament hub.
class TablePairingToken {
  const TablePairingToken({
    required this.tournamentId,
    required this.tableNumber,
    required this.hubIp,
    required this.port,
    required this.expiresAt,
    required this.signature,
  });

  /// Generates a signed token with HMAC-SHA256.
  factory TablePairingToken.generate({
    required String tournamentId,
    required int tableNumber,
    required String hubIp,
    required int port,
    required String secretKey,
    Duration validDuration = const Duration(hours: 12),
  }) {
    final expiresAt = DateTime.now().add(validDuration).toUtc();
    final payload = '$tournamentId:$tableNumber:$hubIp:$port:${expiresAt.millisecondsSinceEpoch}';
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signature = hmac.convert(utf8.encode(payload)).toString();

    return TablePairingToken(
      tournamentId: tournamentId,
      tableNumber: tableNumber,
      hubIp: hubIp,
      port: port,
      expiresAt: expiresAt,
      signature: signature,
    );
  }

  /// Parses a QR string back into a [TablePairingToken].
  static TablePairingToken? fromQrString(String qrString) {
    try {
      final uri = Uri.parse(qrString);
      final rawData = uri.queryParameters['data'];
      if (rawData == null) return null;

      final decoded = jsonDecode(utf8.decode(base64Url.decode(rawData))) as Map<String, dynamic>;
      return TablePairingToken(
        tournamentId: decoded['t'] as String,
        tableNumber: decoded['n'] as int,
        hubIp: decoded['ip'] as String,
        port: decoded['p'] as int,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(decoded['e'] as int, isUtc: true),
        signature: decoded['s'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  final String tournamentId;
  final int tableNumber;
  final String hubIp;
  final int port;
  final DateTime expiresAt;
  final String signature;

  String get hubUrl => 'http://$hubIp:$port';

  /// Verifies if the token signature is valid and has not expired.
  bool isValid(String secretKey) {
    if (DateTime.now().toUtc().isAfter(expiresAt)) return false;
    final payload = '$tournamentId:$tableNumber:$hubIp:$port:${expiresAt.millisecondsSinceEpoch}';
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final expectedSignature = hmac.convert(utf8.encode(payload)).toString();
    return signature == expectedSignature;
  }

  /// Formats the token into a URI / string for QR generation.
  String toQrString() {
    final map = {
      't': tournamentId,
      'n': tableNumber,
      'ip': hubIp,
      'p': port,
      'e': expiresAt.millisecondsSinceEpoch,
      's': signature,
    };
    return 'beyscore://pair?data=${base64Url.encode(utf8.encode(jsonEncode(map)))}';
  }
}
