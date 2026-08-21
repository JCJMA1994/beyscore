import 'package:bey_domain/bey_domain.dart';
import 'package:bey_hub/bey_hub.dart';
import 'package:test/test.dart';

void main() {
  group('SmartTableDispatcher Tests', () {
    late LanHubServer server;

    setUp(() {
      server = LanHubServer();
    });

    tearDown(() async {
      await server.stop();
    });

    test('dispatches next ready matchup to liberated table', () {
      final pendingMatchups = [
        const Matchup(
          matchId: 'R1-M1',
          playerAId: 'BladerA',
          playerAName: 'BladerA',
          playerBId: 'BladerB',
          playerBName: 'BladerB',
          isCompleted: false,
        ),
      ];

      Matchup? dispatchedMatch;
      int? dispatchedTable;

      final dispatcher = SmartTableDispatcher(
        hubServer: server,
        getPendingMatchups: () => pendingMatchups,
        onMatchDispatched: (m, table) {
          dispatchedMatch = m;
          dispatchedTable = table;
        },
      );

      final success = dispatcher.dispatchNextMatchToTable(1);

      expect(success, isTrue);
      expect(dispatchedMatch?.matchId, 'R1-M1');
      expect(dispatchedTable, 1);

      final status = server.currentTables[1];
      expect(status?.playerA, 'BladerA');
      expect(status?.playerB, 'BladerB');
      expect(status?.status, 'RUNNING');

      dispatcher.dispose();
    });

    test('returns false when no ready matchups exist', () {
      final dispatcher = SmartTableDispatcher(
        hubServer: server,
        getPendingMatchups: () => [],
        onMatchDispatched: (_, _) {},
      );

      final success = dispatcher.dispatchNextMatchToTable(2);
      expect(success, isFalse);

      dispatcher.dispose();
    });
  });
}
