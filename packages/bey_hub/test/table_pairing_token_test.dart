import 'package:bey_hub/bey_hub.dart';
import 'package:test/test.dart';

void main() {
  group('TablePairingToken Tests', () {
    const secretKey = 'test-organizer-secret-key';

    test('generates and verifies HMAC-SHA256 signature correctly', () {
      final token = TablePairingToken.generate(
        tournamentId: 'tour-123',
        tableNumber: 3,
        hubIp: '192.168.1.50',
        port: 8080,
        secretKey: secretKey,
      );

      expect(token.isValid(secretKey), isTrue);
      expect(token.isValid('wrong-secret-key'), isFalse);
    });

    test('serializes to and deserializes from QR URI string', () {
      final token = TablePairingToken.generate(
        tournamentId: 'tour-999',
        tableNumber: 7,
        hubIp: '192.168.1.100',
        port: 9090,
        secretKey: secretKey,
      );

      final qrString = token.toQrString();
      expect(qrString, startsWith('beyscore://pair?data='));

      final parsed = TablePairingToken.fromQrString(qrString);
      expect(parsed, isNotNull);
      expect(parsed!.tournamentId, 'tour-999');
      expect(parsed.tableNumber, 7);
      expect(parsed.hubIp, '192.168.1.100');
      expect(parsed.port, 9090);
      expect(parsed.isValid(secretKey), isTrue);
    });

    test('detects expired tokens', () {
      final token = TablePairingToken(
        tournamentId: 'tour-1',
        tableNumber: 1,
        hubIp: '127.0.0.1',
        port: 8080,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        signature: 'some-sig',
      );

      expect(token.isValid(secretKey), isFalse);
    });
  });
}
