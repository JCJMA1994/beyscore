import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('SwissBracketGenerator Tests', () {
    const generator = SwissBracketGenerator();

    test('calculates correct total rounds for participant counts', () {
      expect(generator.calculateTotalRounds(2), 1);
      expect(generator.calculateTotalRounds(4), 2);
      expect(generator.calculateTotalRounds(8), 3);
      expect(generator.calculateTotalRounds(16), 4);
      expect(generator.calculateTotalRounds(32), 5);
      expect(generator.calculateTotalRounds(5), 3); // 5 players -> 3 rounds
    });

    test('generates balanced Round 1 pairings and handles byes', () {
      final players = ['Blader1', 'Blader2', 'Blader3', 'Blader4', 'Blader5'];
      final r1 = generator.generateInitialRound(
        playerNames: players,
        seed: 42,
      );

      expect(r1.matchups.length, 3); // 5 players -> 3 matchups (one is bye)
      expect(r1.matchups.any((m) => m.isBye), isTrue);
    });

    test('calculates accurate Buchholz and Sonneborn-Berger standings', () {
      final players = ['A', 'B', 'C', 'D'];

      // Round 1: A beats B, C beats D
      const r1 = BracketRound(
        roundIndex: 0,
        name: 'Ronda Suizo 1',
        matchups: [
          Matchup(
            matchId: 'SWISS-R1-M1',
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
            matchId: 'SWISS-R1-M2',
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
      );

      final standings = generator.calculateStandings([r1], players);

      expect(standings.first.playerName, 'A'); // A has +3 diff, C has +2 diff
      expect(standings[0].wins, 1);
      expect(standings[1].playerName, 'C');
      expect(standings[1].wins, 1);
      expect(standings[2].wins, 0);
      expect(standings[3].wins, 0);
    });

    test('generates next round avoiding rematches', () {
      final players = ['A', 'B', 'C', 'D'];

      // Round 1: A vs B, C vs D
      const r1 = BracketRound(
        roundIndex: 0,
        name: 'Ronda Suizo 1',
        matchups: [
          Matchup(
            matchId: 'SWISS-R1-M1',
            playerAId: 'A',
            playerAName: 'A',
            playerBId: 'B',
            playerBName: 'B',
            scoreA: 4,
            scoreB: 0,
            winnerId: 'A',
            isCompleted: true,
          ),
          Matchup(
            matchId: 'SWISS-R1-M2',
            playerAId: 'C',
            playerAName: 'C',
            playerBId: 'D',
            playerBName: 'D',
            scoreA: 4,
            scoreB: 1,
            winnerId: 'C',
            isCompleted: true,
          ),
        ],
      );

      // Round 2 must pair winners A vs C, and losers B vs D (no rematches)
      final r2 = generator.generateNextRound(
        existingRounds: [r1],
        allPlayers: players,
        seed: 42,
      );

      expect(r2.matchups.length, 2);
      final m1 = r2.matchups[0];
      final m2 = r2.matchups[1];

      // Winners paired together
      expect({m1.playerAName, m1.playerBName}, containsAll(['A', 'C']));
      // Losers paired together
      expect({m2.playerAName, m2.playerBName}, containsAll(['B', 'D']));
    });
  });
}
