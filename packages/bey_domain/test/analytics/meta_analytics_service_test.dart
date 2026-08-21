import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('MetaAnalyticsService Tests', () {
    const service = MetaAnalyticsService();

    test('calculates finish distribution correctly', () {
      final matches = [
        Match(
          id: 'm1',
          playerAId: 'P1',
          playerBId: 'P2',
          format: MatchFormat.singles,
          rules: const MatchRules(),
          status: MatchStatus.confirmed,
          finishes: [
            BattleFinish(
              id: 'f1',
              matchId: 'm1',
              roundIndex: 1,
              sequence: 1,
              type: FinishType.spin,
              scoringPlayerId: 'P1',
              createdAt: DateTime.now(),
            ),
            BattleFinish(
              id: 'f2',
              matchId: 'm1',
              roundIndex: 2,
              sequence: 2,
              type: FinishType.xtreme,
              scoringPlayerId: 'P1',
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
        ),
      ];

      final dist = service.calculateFinishDistribution(matches);
      expect(dist[FinishType.spin], 1);
      expect(dist[FinishType.xtreme], 1);
      expect(dist[FinishType.over], 0);
      expect(dist[FinishType.burst], 0);
    });

    test('generates accurate tournament summary report', () {
      final rounds = [
        const BracketRound(
          roundIndex: 0,
          name: 'Semifinales',
          matchups: [
            Matchup(
              matchId: 'R1-M1',
              playerAId: 'A',
              playerAName: 'A',
              playerBId: 'B',
              playerBName: 'B',
              scoreA: 4,
              scoreB: 1,
              winnerId: 'A',
              isCompleted: true,
            ),
            Matchup(
              matchId: 'R1-M2',
              playerAId: 'C',
              playerAName: 'C',
              playerBId: 'D',
              playerBName: 'D',
              scoreA: 4,
              scoreB: 2,
              winnerId: 'C',
              isCompleted: true,
            ),
          ],
        ),
        const BracketRound(
          roundIndex: 1,
          name: 'Gran Final',
          matchups: [
            Matchup(
              matchId: 'R2-FINAL',
              playerAId: 'A',
              playerAName: 'A',
              playerBId: 'C',
              playerBName: 'C',
              scoreA: 4,
              scoreB: 2,
              winnerId: 'A',
              isCompleted: true,
            ),
            Matchup(
              matchId: 'BRONZE-3RD',
              playerAId: 'B',
              playerAName: 'B',
              playerBId: 'D',
              playerBName: 'D',
              scoreA: 4,
              scoreB: 3,
              winnerId: 'B',
              isCompleted: true,
            ),
          ],
        ),
      ];

      final report = service.generateTournamentReport(
        tournamentName: 'G1 Chimbote Championship',
        rounds: rounds,
      );

      expect(report.firstPlace, 'A');
      expect(report.secondPlace, 'C');
      expect(report.thirdPlace, 'B');
      expect(report.totalMatches, 4);
      expect(report.totalPointsScored, 24); // (4+1) + (4+2) + (4+2) + (4+3) = 24
    });
  });
}
