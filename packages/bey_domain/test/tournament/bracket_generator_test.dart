import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('BracketGenerator Tests', () {
    const generator = BracketGenerator();

    test('generates power of 2 bracket for 4 players with 3rd place match (2 rounds)', () {
      final players = ['Tyson', 'Kai', 'Ray', 'Max'];
      final rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 12345,
        hasThirdPlaceMatch: true,
      );

      expect(rounds.length, 2);
      expect(rounds[0].name, 'Semifinales');
      expect(rounds[0].matchups.length, 2);
      expect(rounds[1].name, 'Gran Final');
      expect(rounds[1].matchups.length, 2); // Grand Final + 3rd Place Bronze Match
      expect(rounds[1].matchups[0].matchId, 'R2-FINAL');
      expect(rounds[1].matchups[1].matchId, 'BRONZE-3RD');
    });

    test('generates 8 players bracket (3 rounds: Cuartos, Semis, Final + Bronce)', () {
      final players = [
        'Tyson',
        'Kai',
        'Ray',
        'Max',
        'Bird',
        'Ekusu',
        'Multi',
        'Robin',
      ];
      final rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 42,
        hasThirdPlaceMatch: true,
      );

      expect(rounds.length, 3);
      expect(rounds[0].name, 'Cuartos de Final');
      expect(rounds[0].matchups.length, 4);
      expect(rounds[1].name, 'Semifinales');
      expect(rounds[1].matchups.length, 2);
      expect(rounds[2].name, 'Gran Final');
      expect(rounds[2].matchups.length, 2); // Final + 3rd Place
    });

    test('allocates byes when player count is not a power of 2 (e.g. 3 players -> 4 slots, 1 bye)', () {
      final players = ['Tyson', 'Kai', 'Ray'];
      final rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 999,
      );

      expect(rounds.length, 2);
      final r1 = rounds[0];
      expect(r1.matchups.length, 2);

      // One match must be a Bye and marked completed automatically
      final byes = r1.matchups.where((m) => m.isBye).toList();
      expect(byes.length, 1);
      expect(byes.first.isCompleted, isTrue);
      expect(byes.first.winnerId, isNotNull);
    });

    test('advances winners from Round 1 into Semifinals and Final', () {
      final players = ['Tyson', 'Kai', 'Ray', 'Max'];
      var rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 100,
        method: BracketMethod.seeded,
      );

      // Match 1: Tyson vs Max -> Tyson wins
      final m1PA = rounds[0].matchups[0].playerAName;
      rounds = generator.advanceWinner(
        currentRounds: rounds,
        roundIndex: 0,
        matchupIndex: 0,
        winnerName: m1PA,
        scoreA: 4,
        scoreB: 1,
      );
      expect(rounds[0].matchups[0].isCompleted, isTrue);
      expect(rounds[0].matchups[0].winnerId, m1PA);
      expect(rounds[1].matchups[0].playerAName, m1PA);

      // Match 2: Kai vs Ray -> Kai wins
      final m2PA = rounds[0].matchups[1].playerAName;
      rounds = generator.advanceWinner(
        currentRounds: rounds,
        roundIndex: 0,
        matchupIndex: 1,
        winnerName: m2PA,
        scoreA: 4,
        scoreB: 2,
      );
      expect(rounds[1].matchups[0].playerBName, m2PA);

      // Final Match: Tyson vs Kai -> Tyson wins champion
      rounds = generator.advanceWinner(
        currentRounds: rounds,
        roundIndex: 1,
        matchupIndex: 0,
        winnerName: m1PA,
        scoreA: 4,
        scoreB: 3,
      );
      expect(rounds[1].matchups[0].isCompleted, isTrue);
      expect(rounds[1].matchups[0].winnerId, m1PA);
    });

    test('deterministic bracket generation produces identical matchups for same seed', () {
      final players = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
      final rounds1 = generator.generateBracketTree(playerNames: players, seed: 777);
      final rounds2 = generator.generateBracketTree(playerNames: players, seed: 777);

      for (var i = 0; i < rounds1.length; i++) {
        for (var j = 0; j < rounds1[i].matchups.length; j++) {
          expect(rounds1[i].matchups[j].playerAName, rounds2[i].matchups[j].playerAName);
          expect(rounds1[i].matchups[j].playerBName, rounds2[i].matchups[j].playerBName);
        }
      }
    });

    test('generates 16 players bracket (4 rounds: Octavos, Cuartos, Semis, Final)', () {
      final players = List.generate(16, (i) => 'Blader ${i + 1}');
      final rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 1234,
      );

      expect(rounds.length, 4);
      expect(rounds[0].name, 'Octavos de Final');
      expect(rounds[0].matchups.length, 8);
      expect(rounds[1].name, 'Cuartos de Final');
      expect(rounds[1].matchups.length, 4);
      expect(rounds[2].name, 'Semifinales');
      expect(rounds[2].matchups.length, 2);
      expect(rounds[3].name, 'Gran Final');
      expect(rounds[3].matchups.length, 2); // Final + 3rd Place Match
    });

    test('handles single player bracket gracefully (auto-completed bye final)', () {
      final players = ['Solo Blader'];
      final rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 1,
      );

      expect(rounds.length, 1);
      expect(rounds[0].matchups.length, 1);
      expect(rounds[0].matchups[0].isBye, isTrue);
      expect(rounds[0].matchups[0].winnerId, 'Solo Blader');
    });

    test('startMatchup transitions status from pending to inProgress', () {
      final players = ['Tyson', 'Kai', 'Ray', 'Max'];
      var rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 123,
      );

      expect(rounds[0].matchups[0].status, MatchupStatus.pending);
      expect(rounds[0].matchups[0].isInProgress, isFalse);

      rounds = generator.startMatchup(
        currentRounds: rounds,
        roundIndex: 0,
        matchupIndex: 0,
        tableNumber: 3,
      );

      expect(rounds[0].matchups[0].status, MatchupStatus.inProgress);
      expect(rounds[0].matchups[0].isInProgress, isTrue);
      expect(rounds[0].matchups[0].tableNumber, 3);
    });

    test('declareWalkover advances winner with status walkover and score 0-0', () {
      final players = ['Tyson', 'Kai', 'Ray', 'Max'];
      var rounds = generator.generateBracketTree(
        playerNames: players,
        seed: 100,
        method: BracketMethod.seeded,
      );

      final pA = rounds[0].matchups[0].playerAName;
      rounds = generator.declareWalkover(
        currentRounds: rounds,
        roundIndex: 0,
        matchupIndex: 0,
        winnerName: pA,
      );

      final m0 = rounds[0].matchups[0];
      expect(m0.isCompleted, isTrue);
      expect(m0.status, MatchupStatus.walkover);
      expect(m0.winnerId, pA);
      expect(m0.scoreA, 0);
      expect(m0.scoreB, 0);
      expect(rounds[1].matchups[0].playerAName, pA);
    });
  });
}
