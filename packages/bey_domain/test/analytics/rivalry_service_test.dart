import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RivalryService Tests', () {
    const service = RivalryService();
    const rules = MatchRules(targetPoints: 4);

    final now = DateTime.now();
    final matches = [
      Match(
        id: 'm1',
        playerAId: 'BladerA',
        playerBId: 'BladerB',
        format: MatchFormat.singles,
        rules: rules,
        status: MatchStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 3)),
        finishes: [
          BattleFinish(
            id: 'f1',
            matchId: 'm1',
            roundIndex: 0,
            sequence: 0,
            type: FinishType.burst,
            scoringPlayerId: 'BladerA',
            createdAt: now,
          ),
          BattleFinish(
            id: 'f2',
            matchId: 'm1',
            roundIndex: 1,
            sequence: 1,
            type: FinishType.over,
            scoringPlayerId: 'BladerA',
            createdAt: now,
          ),
        ],
      ),
      Match(
        id: 'm2',
        playerAId: 'BladerB',
        playerBId: 'BladerA',
        format: MatchFormat.singles,
        rules: rules,
        status: MatchStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 2)),
        finishes: [
          BattleFinish(
            id: 'f3',
            matchId: 'm2',
            roundIndex: 0,
            sequence: 0,
            type: FinishType.xtreme,
            scoringPlayerId: 'BladerB',
            createdAt: now,
          ),
          BattleFinish(
            id: 'f4',
            matchId: 'm2',
            roundIndex: 1,
            sequence: 1,
            type: FinishType.spin,
            scoringPlayerId: 'BladerB',
            createdAt: now,
          ),
        ],
      ),
      Match(
        id: 'm3',
        playerAId: 'BladerA',
        playerBId: 'BladerB',
        format: MatchFormat.singles,
        rules: rules,
        status: MatchStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 1)),
        finishes: [
          BattleFinish(
            id: 'f5',
            matchId: 'm3',
            roundIndex: 0,
            sequence: 0,
            type: FinishType.burst,
            scoringPlayerId: 'BladerB',
            createdAt: now,
          ),
          BattleFinish(
            id: 'f6',
            matchId: 'm3',
            roundIndex: 1,
            sequence: 1,
            type: FinishType.burst,
            scoringPlayerId: 'BladerB',
            createdAt: now,
          ),
        ],
      ),
    ];

    test('computes head-to-head record accurately across reversed matchups', () {
      final h2h = service.computeHeadToHead(
        matches: matches,
        playerA: 'BladerA',
        playerB: 'BladerB',
      );

      expect(h2h.totalMatches, 3);
      expect(h2h.winsA, 1);
      expect(h2h.winsB, 2);
      expect(h2h.lastWinner, 'BladerB');
      expect(h2h.streak, 2);
      expect(h2h.streakHolder, 'BladerB');
      expect(h2h.isRevengeOpportunity, isTrue);
      expect(h2h.finishesB[FinishType.burst], 2);
      expect(h2h.finishesB[FinishType.xtreme], 1);
    });
  });
}
