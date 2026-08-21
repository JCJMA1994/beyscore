import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ScoringService Tests (Official v12 Rules)', () {
    const service = ScoringService();
    final now = DateTime(2026, 8, 15);

    test('points mapping matches official rules', () {
      expect(service.pointsFor(FinishType.xtreme), 3);
      expect(service.pointsFor(FinishType.over), 2);
      expect(service.pointsFor(FinishType.burst), 2);
      expect(service.pointsFor(FinishType.spin), 1);
      expect(service.pointsFor(FinishType.penalty), 1);
    });

    test('computes score accurately from finishes', () {
      final match = Match(
        id: 'm1',
        playerAId: 'pA',
        playerBId: 'pB',
        format: MatchFormat.singles,
        rules: const MatchRules(targetPoints: 4),
        status: MatchStatus.inProgress,
        finishes: [
          BattleFinish(
            id: 'f1',
            matchId: 'm1',
            roundIndex: 1,
            sequence: 1,
            type: FinishType.burst, // +2 for pA
            scoringPlayerId: 'pA',
            createdAt: now,
          ),
          BattleFinish(
            id: 'f2',
            matchId: 'm1',
            roundIndex: 2,
            sequence: 2,
            type: FinishType.spin, // +1 for pB
            scoringPlayerId: 'pB',
            createdAt: now,
          ),
        ],
      );

      final score = service.scoreOf(match);
      expect(score.playerAPoints, 2);
      expect(score.playerBPoints, 1);
    });

    test('correctly excludes voided finishes in score calculation', () {
      final match = Match(
        id: 'm1',
        playerAId: 'pA',
        playerBId: 'pB',
        format: MatchFormat.singles,
        rules: const MatchRules(targetPoints: 4),
        status: MatchStatus.inProgress,
        finishes: [
          BattleFinish(
            id: 'f1',
            matchId: 'm1',
            roundIndex: 1,
            sequence: 1,
            type: FinishType.burst, // +2 for pA
            scoringPlayerId: 'pA',
            createdAt: now,
          ),
          BattleFinish(
            id: 'f2_undo',
            matchId: 'm1',
            roundIndex: 1,
            sequence: 2,
            type: FinishType.burst,
            scoringPlayerId: 'pA',
            createdAt: now,
            voidedTargetId: 'f1', // Anula f1!
          ),
        ],
      );

      final score = service.scoreOf(match);
      expect(score.playerAPoints, 0);
      expect(score.playerBPoints, 0);
    });

    test('closes match when target points reached', () {
      final match = Match(
        id: 'm1',
        playerAId: 'pA',
        playerBId: 'pB',
        format: MatchFormat.singles,
        rules: const MatchRules(targetPoints: 4),
        status: MatchStatus.inProgress,
        finishes: [
          BattleFinish(
            id: 'f1',
            matchId: 'm1',
            roundIndex: 1,
            sequence: 1,
            type: FinishType.over, // +2
            scoringPlayerId: 'pA',
            createdAt: now,
          ),
        ],
      );

      // Add Over finish (+2 -> 4 total)
      final finish2 = BattleFinish(
        id: 'f2',
        matchId: 'm1',
        roundIndex: 2,
        sequence: 2,
        type: FinishType.over,
        scoringPlayerId: 'pA',
        createdAt: now,
      );

      final result = service.applyFinish(match, finish2);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should have succeeded'),
        (updated) {
          expect(updated.status, MatchStatus.pendingConfirmation);
          final score = service.scoreOf(updated);
          expect(score.playerAPoints, 4);
        },
      );
    });
  });
}
