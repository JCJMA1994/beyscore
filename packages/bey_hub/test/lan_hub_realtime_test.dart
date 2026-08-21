import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bey_hub/bey_hub.dart';
import 'package:test/test.dart';

void main() {
  group('LanHubServer Realtime WebSocket & SSE', () {
    late LanHubServer server;
    const testPort = 19999;

    setUp(() async {
      server = LanHubServer();
      await server.start(port: testPort);
    });

    tearDown(() async {
      await server.stop();
    });

    test('client connects to WebSocket and receives live MATCH_ASSIGNED and SCORE_UPDATED events', () async {
      final client = HubRealtimeClient();
      final receivedEvents = <HubEvent>[];
      final eventCompleter = Completer<void>();

      final sub = client.events.listen((event) {
        receivedEvents.add(event);
        if (receivedEvents.any((e) => e.type == HubEventType.scoreUpdated)) {
          if (!eventCompleter.isCompleted) {
            eventCompleter.complete();
          }
        }
      });

      client.connect(
        hubUrl: 'http://127.0.0.1:$testPort',
        playerNickname: 'Tyson',
      );

      // Wait until connection is fully established
      await client.connectionState.firstWhere((c) => c).timeout(const Duration(seconds: 3));
      expect(server.connectedWebSocketCount, greaterThanOrEqualTo(1));

      // 1. Assign match
      server
        ..assignMatchToTable(
          tableNumber: 4,
          playerA: 'Tyson',
          playerB: 'Kai',
        )
        // 2. Resolve dispute / update score
        ..resolveDispute(
          tableNumber: 4,
          scoreA: 3,
          scoreB: 1,
        );

      await eventCompleter.future.timeout(const Duration(seconds: 4));

      expect(receivedEvents.any((e) => e.type == HubEventType.matchAssigned), isTrue);
      final matchEvent = receivedEvents.firstWhere((e) => e.type == HubEventType.matchAssigned);
      expect(matchEvent.payload['tableNumber'], 4);
      expect(matchEvent.payload['playerA'], 'Tyson');
      expect(matchEvent.payload['playerB'], 'Kai');

      expect(receivedEvents.any((e) => e.type == HubEventType.scoreUpdated), isTrue);
      final scoreEvent = receivedEvents.firstWhere((e) => e.type == HubEventType.scoreUpdated);
      expect(scoreEvent.payload['scoreA'], 3);
      expect(scoreEvent.payload['scoreB'], 1);

      await sub.cancel();
      client.dispose();
    });

    test('SSE endpoint /api/events streams live events to HTTP clients', () async {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/api/events'));
      final response = await request.close();

      expect(response.statusCode, 200);
      expect(response.headers.contentType?.mimeType, 'text/event-stream');

      final lines = <String>[];
      final completer = Completer<void>();

      final sub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.startsWith('data: ')) {
          lines.add(line);
          if (lines.any((l) => l.contains('CHECKIN_VERIFIED'))) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        }
      });

      // Allow SSE subscription to register
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify checkin on server
      server.verifyBladerCheckIn('Max');

      await completer.future.timeout(const Duration(seconds: 4));
      expect(lines.any((l) => l.contains('CHECKIN_VERIFIED') && l.contains('Max')), isTrue);

      await sub.cancel();
      client.close();
    });
  });
}
