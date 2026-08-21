import 'bracket.dart';
import 'seeded_shuffle.dart';

/// Pure domain service for generating and progressing tournament brackets.
///
/// No I/O. 100% test coverage target.
class BracketGenerator {
  const BracketGenerator();

  /// Generates the complete single-elimination bracket tree from player names.
  List<BracketRound> generateBracketTree({
    required List<String> playerNames,
    required int seed,
    BracketMethod method = BracketMethod.random,
    bool hasThirdPlaceMatch = true,
  }) {
    if (playerNames.isEmpty) return [];

    final players = switch (method) {
      BracketMethod.random => SeededShuffle.shuffle(List.of(playerNames), seed),
      BracketMethod.seeded => List.of(playerNames),
      BracketMethod.manual => List.of(playerNames),
    };

    // Calculate next power of 2
    var size = 1;
    var totalRounds = 0;
    while (size < players.length) {
      size *= 2;
      totalRounds++;
    }
    if (size == 1) {
      size = 2;
      totalRounds = 1;
    }

    final padded = List<String?>.from(players);
    while (padded.length < size) {
      padded.add(null);
    }

    // Build Round 1 Matchups
    final round1Matchups = <Matchup>[];
    for (var i = 0; i < size ~/ 2; i++) {
      final pA = padded[i]!;
      final pB = padded[size - 1 - i];
      final isBye = pB == null;

      round1Matchups.add(
        Matchup(
          matchId: 'R1-M${i + 1}',
          playerAId: pA,
          playerAName: pA,
          playerBId: pB,
          playerBName: pB,
          tableNumber: i + 1,
          winnerId: isBye ? pA : null,
          isCompleted: isBye,
          status: isBye ? MatchupStatus.completed : MatchupStatus.pending,
        ),
      );
    }

    final rounds = <BracketRound>[
      BracketRound(
        roundIndex: 0,
        name: _getRoundName(0, totalRounds),
        matchups: round1Matchups,
      ),
    ];

    // Build subsequent empty/TBD rounds
    var matchesInRound = size ~/ 4;
    for (var r = 1; r < totalRounds; r++) {
      final matchups = <Matchup>[];
      final isFinalRound = (r == totalRounds - 1);

      for (var m = 0; m < matchesInRound; m++) {
        // Check if predecessors are already decided by byes
        final prevM1 = rounds[r - 1].matchups[m * 2];
        final prevM2 = rounds[r - 1].matchups[m * 2 + 1];

        final pAName = prevM1.winnerId ?? 'Ganador M${m * 2 + 1}';
        final pBName = prevM2.winnerId ?? 'Ganador M${m * 2 + 2}';
        final isPAKnown = prevM1.winnerId != null;
        final isPBKnown = prevM2.winnerId != null;

        matchups.add(
          Matchup(
            matchId: isFinalRound && m == 0 ? 'R${r + 1}-FINAL' : 'R${r + 1}-M${m + 1}',
            playerAId: isPAKnown ? prevM1.winnerId! : 'TBD',
            playerAName: pAName,
            playerBId: isPBKnown ? prevM2.winnerId! : 'TBD',
            playerBName: pBName,
            tableNumber: m + 1,
            status: MatchupStatus.pending,
          ),
        );
      }

      // Add 3rd Place Match in the final round if bracket has semifinals (4+ players) and requested
      if (hasThirdPlaceMatch && isFinalRound && totalRounds >= 2) {
        matchups.add(
          const Matchup(
            matchId: 'BRONZE-3RD',
            playerAId: 'TBD',
            playerAName: 'Perdedor Semifinal 1',
            playerBId: 'TBD',
            playerBName: 'Perdedor Semifinal 2',
            tableNumber: 2,
            status: MatchupStatus.pending,
          ),
        );
      }

      rounds.add(
        BracketRound(
          roundIndex: r,
          name: _getRoundName(r, totalRounds),
          matchups: matchups,
        ),
      );
      matchesInRound ~/= 2;
    }

    return rounds;
  }

  /// Sets a matchup to in-progress (called to the stadium).
  List<BracketRound> startMatchup({
    required List<BracketRound> currentRounds,
    required int roundIndex,
    required int matchupIndex,
    int? tableNumber,
  }) {
    if (roundIndex < 0 || roundIndex >= currentRounds.length) return currentRounds;
    if (matchupIndex < 0 || matchupIndex >= currentRounds[roundIndex].matchups.length) return currentRounds;

    final updatedRounds = currentRounds.map((r) {
      return r.copyWith(matchups: List.of(r.matchups));
    }).toList();

    final target = updatedRounds[roundIndex].matchups[matchupIndex];
    if (target.isCompleted || target.isBye) return currentRounds;

    updatedRounds[roundIndex].matchups[matchupIndex] = target.copyWith(
      status: MatchupStatus.inProgress,
      tableNumber: tableNumber ?? target.tableNumber,
    );

    return updatedRounds;
  }

  /// Declares a Walkover (W.O.) for an unplayed match.
  List<BracketRound> declareWalkover({
    required List<BracketRound> currentRounds,
    required int roundIndex,
    required int matchupIndex,
    required String winnerName,
  }) {
    return advanceWinner(
      currentRounds: currentRounds,
      roundIndex: roundIndex,
      matchupIndex: matchupIndex,
      winnerName: winnerName,
      scoreA: 0,
      scoreB: 0,
      status: MatchupStatus.walkover,
    );
  }

  /// Advances a match winner to the next round in the bracket.
  ///
  /// Returns the updated list of bracket rounds.
  List<BracketRound> advanceWinner({
    required List<BracketRound> currentRounds,
    required int roundIndex,
    required int matchupIndex,
    required String winnerName,
    int scoreA = 0,
    int scoreB = 0,
    MatchupStatus status = MatchupStatus.completed,
  }) {
    if (roundIndex < 0 || roundIndex >= currentRounds.length) return currentRounds;
    if (matchupIndex < 0 || matchupIndex >= currentRounds[roundIndex].matchups.length) return currentRounds;

    final updatedRounds = currentRounds.map((r) {
      return r.copyWith(matchups: List.of(r.matchups));
    }).toList();

    final targetMatchup = updatedRounds[roundIndex].matchups[matchupIndex];
    updatedRounds[roundIndex].matchups[matchupIndex] = targetMatchup.copyWith(
      winnerId: winnerName,
      scoreA: scoreA,
      scoreB: scoreB,
      isCompleted: true,
      status: status,
    );

    // Determine loser
    final loserName = targetMatchup.playerAName == winnerName
        ? targetMatchup.playerBName
        : targetMatchup.playerAName;

    // If there is a next round, propagate winner to the next round matchup
    if (roundIndex + 1 < updatedRounds.length) {
      final nextRoundIndex = roundIndex + 1;
      final isSemifinals = (roundIndex == currentRounds.length - 2);

      if (isSemifinals && updatedRounds[nextRoundIndex].matchups.length >= 2) {
        // Semifinals -> Grand Final (matchup 0) and 3rd Place Match (matchup 1)
        final isSemiA = (matchupIndex == 0);
        final finalMatch = updatedRounds[nextRoundIndex].matchups[0];
        final bronzeMatch = updatedRounds[nextRoundIndex].matchups[1];

        // Propagate winner to Grand Final
        if (isSemiA) {
          updatedRounds[nextRoundIndex].matchups[0] = finalMatch.copyWith(
            playerAId: winnerName,
            playerAName: winnerName,
          );
          if (loserName != null && loserName != 'TBD') {
            updatedRounds[nextRoundIndex].matchups[1] = bronzeMatch.copyWith(
              playerAId: loserName,
              playerAName: loserName,
            );
          }
        } else {
          updatedRounds[nextRoundIndex].matchups[0] = finalMatch.copyWith(
            playerBId: winnerName,
            playerBName: winnerName,
          );
          if (loserName != null && loserName != 'TBD') {
            updatedRounds[nextRoundIndex].matchups[1] = bronzeMatch.copyWith(
              playerBId: loserName,
              playerBName: loserName,
            );
          }
        }
      } else {
        final nextMatchupIndex = matchupIndex ~/ 2;
        final isPlayerA = (matchupIndex % 2) == 0;

        if (nextMatchupIndex < updatedRounds[nextRoundIndex].matchups.length) {
          final nextMatchup = updatedRounds[nextRoundIndex].matchups[nextMatchupIndex];
          if (isPlayerA) {
            updatedRounds[nextRoundIndex].matchups[nextMatchupIndex] = nextMatchup.copyWith(
              playerAId: winnerName,
              playerAName: winnerName,
            );
          } else {
            updatedRounds[nextRoundIndex].matchups[nextMatchupIndex] = nextMatchup.copyWith(
              playerBId: winnerName,
              playerBName: winnerName,
            );
          }
        }
      }
    }

    return updatedRounds;
  }

  String _getRoundName(int roundIndex, int totalRounds) {
    final remaining = totalRounds - roundIndex;
    return switch (remaining) {
      1 => 'Gran Final',
      2 => 'Semifinales',
      3 => 'Cuartos de Final',
      4 => 'Octavos de Final',
      _ => 'Ronda ${roundIndex + 1}',
    };
  }

  /// Legacy list generation for raw pair testing
  List<List<String?>> generate({
    required List<String> playerIds,
    required int seed,
    BracketMethod method = BracketMethod.random,
  }) {
    final tree = generateBracketTree(
      playerNames: playerIds,
      seed: seed,
      method: method,
    );
    if (tree.isEmpty) return [];
    return tree.first.matchups.map((m) => [m.playerAId, m.playerBId]).toList();
  }
}

enum BracketMethod { random, seeded, manual }
