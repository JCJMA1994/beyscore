import 'package:bey_hub/bey_hub.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('LanHubServer & TableClientService Integration', () {
    late LanHubServer server;
    late TableClientService client;
    const testPort = 18888;

    setUp(() async {
      server = LanHubServer();
      await server.start(port: testPort);
      client = TableClientService();
    });

    tearDown(() async {
      await server.stop();
    });

    test('starts server and serves live spectator page', () async {
      final res = await http.get(Uri.parse('http://127.0.0.1:$testPort/live'));
      expect(res.statusCode, 200);
      expect(res.body, contains('BEYSCORE · LAN HUB'));
    });

    test('assigns match to table and table client reads status', () async {
      server.assignMatchToTable(
        tableNumber: 1,
        playerA: 'Blader Red',
        playerB: 'Blader Blue',
      );

      final status = await client.fetchTableStatus(
        hubUrl: 'http://127.0.0.1:$testPort',
        tableNumber: 1,
      );

      expect(status, isNotNull);
      expect(status!.playerA, 'Blader Red');
      expect(status.playerB, 'Blader Blue');
      expect(status.status, 'RUNNING');
    });

    test('sends score and dispute updates from table device', () async {
      server.assignMatchToTable(
        tableNumber: 2,
        playerA: 'Alice',
        playerB: 'Bob',
      );

      final scoreOk = await client.sendScore(
        hubUrl: 'http://127.0.0.1:$testPort',
        tableNumber: 2,
        scoreA: 2,
        scoreB: 1,
      );
      expect(scoreOk, isTrue);

      final disputeOk = await client.sendDispute(
        hubUrl: 'http://127.0.0.1:$testPort',
        tableNumber: 2,
      );
      expect(disputeOk, isTrue);

      final status = await client.fetchTableStatus(
        hubUrl: 'http://127.0.0.1:$testPort',
        tableNumber: 2,
      );
      expect(status!.scoreA, 2);
      expect(status.scoreB, 1);
      expect(status.status, 'DISPUTE');
    });

    test('tracks player registration, check-in verification, rejection, and assigned table', () async {
      server.currentTournamentJson = {
        'id': 'tourn-123',
        'name': 'Torneo Chimbote',
        'status': 'inProgress',
        'participants': ['Tyson', 'Kai'],
      };

      // 1. Check initial state for registered player
      var playerStatus = await client.fetchPlayerStatus(
        hubUrl: 'http://127.0.0.1:$testPort',
        nickname: 'Tyson',
      );
      expect(playerStatus, isNotNull);
      expect(playerStatus!.isRegistered, isTrue);
      expect(playerStatus.checkInVerified, isFalse);
      expect(playerStatus.isRejected, isFalse);
      expect(playerStatus.assignedTable, isNull);

      // 2. Verify check-in
      server.verifyBladerCheckIn('Tyson');
      playerStatus = await client.fetchPlayerStatus(
        hubUrl: 'http://127.0.0.1:$testPort',
        nickname: 'Tyson',
      );
      expect(playerStatus!.checkInVerified, isTrue);

      // 3. Reject check-in
      server.rejectBladerCheckIn('Kai', 'Pieza duplicada: DranSword');
      final kaiStatus = await client.fetchPlayerStatus(
        hubUrl: 'http://127.0.0.1:$testPort',
        nickname: 'Kai',
      );
      expect(kaiStatus!.isRejected, isTrue);
      expect(kaiStatus.rejectionReason, contains('Pieza duplicada'));

      // 4. Assign match and verify table assignment in player status
      server.assignMatchToTable(
        tableNumber: 3,
        playerA: 'Tyson',
        playerB: 'Ray',
      );
      playerStatus = await client.fetchPlayerStatus(
        hubUrl: 'http://127.0.0.1:$testPort',
        nickname: 'Tyson',
      );
      expect(playerStatus!.assignedTable, 3);
      expect(playerStatus.opponent, 'Ray');
      expect(playerStatus.tableStatus, 'RUNNING');
    });
  });
}
