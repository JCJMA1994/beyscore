import 'package:bey_hub/bey_hub.dart';
import 'package:test/test.dart';

void main() {
  group('LanDiscoveryService Tests', () {
    test('starts and stops UDP beacon cleanly', () async {
      final service = LanDiscoveryService(port: 18889);

      await service.startBeacon(
        hubUrl: 'http://192.168.1.100:8080',
        tournamentName: 'Torneo Test',
      );

      service.stopBeacon();
    });

    test('times out gracefully when no beacon is broadcasting', () async {
      final service = LanDiscoveryService(port: 18890);
      final url = await service.discoverHubUrl(timeout: const Duration(milliseconds: 300));
      expect(url, isNull);
    });
  });
}
