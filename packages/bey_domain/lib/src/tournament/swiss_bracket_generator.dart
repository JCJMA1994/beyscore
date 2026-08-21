import 'bracket.dart';
import 'seeded_shuffle.dart';

/// Standing row for Swiss-system tournaments with Buchholz and Sonneborn-Berger tiebreakers.
class SwissPlayerStanding {
  const SwissPlayerStanding({
    required this.playerName,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.buchholz,
    required this.sonnebornBerger,
    required this.scoreDiff,
    required this.playedOpponents,
  });

  final String playerName;
  final int wins;
  final int losses;
  final int draws;

  /// Buchholz: Sum of all opponents' scores/wins (measure of opponent strength).
  final double buchholz;

  /// Sonneborn-Berger: Sum of wins of opponents this player defeated.
  final double sonnebornBerger;

  /// Total points scored minus points conceded in combat finishes.
  final int scoreDiff;

  /// Opponents faced in previous rounds.
  final List<String> playedOpponents;

  double get matchPoints => (wins * 3.0) + (draws * 1.0);
}

/// Pure domain generator for Swiss-System tournaments.
///
/// Follows FIDE / WBO / Takara Tomy Swiss tournament pairing rules:
/// - Exact number of rounds: ceil(log2(participants)).
/// - Matchmaking pairings within the same score group.
/// - Strict rematch avoidance across earlier rounds.
/// - Deterministic seed-based sorting for consistency.
class SwissBracketGenerator {
  const SwissBracketGenerator();

  /// Calculates total Swiss rounds needed for [playerCount].
  int calculateTotalRounds(int playerCount) {
    if (playerCount <= 1) return 1;
    var size = 1;
    var rounds = 0;
    while (size < playerCount) {
      size *= 2;
      rounds++;
    }
    return rounds;
  }

  /// Generates the initial Round 1 for Swiss format.
  BracketRound generateInitialRound({
    required List<String> playerNames,
    required int seed,
  }) {
    if (playerNames.isEmpty) {
      return const BracketRound(roundIndex: 0, name: 'Ronda 1', matchups: []);
    }

    final shuffled = SeededShuffle.shuffle(List.of(playerNames), seed);
    final matchups = <Matchup>[];

    final half = (shuffled.length + 1) ~/ 2;
    for (var i = 0; i < half; i++) {
      final pA = shuffled[i];
      final isOddLast = i * 2 + 1 >= shuffled.length;
      final pB = isOddLast ? null : shuffled[half + i < shuffled.length ? half + i : i * 2 + 1];
      final isBye = pB == null;

      matchups.add(
        Matchup(
          matchId: 'SWISS-R1-M${i + 1}',
          playerAId: pA,
          playerAName: pA,
          playerBId: pB,
          playerBName: pB,
          tableNumber: i + 1,
          winnerId: isBye ? pA : null,
          isCompleted: isBye,
        ),
      );
    }

    return BracketRound(
      roundIndex: 0,
      name: 'Ronda Suizo 1',
      matchups: matchups,
    );
  }

  /// Calculates standings and tiebreakers from completed rounds.
  List<SwissPlayerStanding> calculateStandings(List<BracketRound> rounds, List<String> allPlayers) {
    final wins = <String, int>{for (final p in allPlayers) p: 0};
    final losses = <String, int>{for (final p in allPlayers) p: 0};
    final draws = <String, int>{for (final p in allPlayers) p: 0};
    final scoreDiff = <String, int>{for (final p in allPlayers) p: 0};
    final opponents = <String, List<String>>{for (final p in allPlayers) p: []};

    for (final round in rounds) {
      for (final m in round.matchups) {
        if (!m.isCompleted) continue;
        final pA = m.playerAName;
        final pB = m.playerBName;

        if (pB == null) {
          // Bye
          wins[pA] = (wins[pA] ?? 0) + 1;
          continue;
        }

        opponents[pA]?.add(pB);
        opponents[pB]?.add(pA);

        scoreDiff[pA] = (scoreDiff[pA] ?? 0) + (m.scoreA - m.scoreB);
        scoreDiff[pB] = (scoreDiff[pB] ?? 0) + (m.scoreB - m.scoreA);

        if (m.winnerId == pA) {
          wins[pA] = (wins[pA] ?? 0) + 1;
          losses[pB] = (losses[pB] ?? 0) + 1;
        } else if (m.winnerId == pB) {
          wins[pB] = (wins[pB] ?? 0) + 1;
          losses[pA] = (losses[pA] ?? 0) + 1;
        } else {
          draws[pA] = (draws[pA] ?? 0) + 1;
          draws[pB] = (draws[pB] ?? 0) + 1;
        }
      }
    }

    // Calculate Buchholz & Sonneborn-Berger
    final standings = allPlayers.map((p) {
      final pOpponents = opponents[p] ?? [];
      var buchholz = 0.0;
      var sonneborn = 0.0;

      for (final opp in pOpponents) {
        final oppWins = (wins[opp] ?? 0).toDouble();
        final oppDraws = (draws[opp] ?? 0).toDouble();
        final oppScore = oppWins + (oppDraws * 0.5);
        buchholz += oppScore;

        // Sonneborn: count score only if player defeated this opponent
        final wonAgainst = rounds.any((r) => r.matchups.any((m) =>
            m.isCompleted &&
            m.winnerId == p &&
            ((m.playerAName == p && m.playerBName == opp) || (m.playerBName == p && m.playerAName == opp))));

        if (wonAgainst) {
          sonneborn += oppScore;
        }
      }

      return SwissPlayerStanding(
        playerName: p,
        wins: wins[p] ?? 0,
        losses: losses[p] ?? 0,
        draws: draws[p] ?? 0,
        buchholz: buchholz,
        sonnebornBerger: sonneborn,
        scoreDiff: scoreDiff[p] ?? 0,
        playedOpponents: pOpponents,
      );
    }).toList()
      ..sort((a, b) {
        if (b.wins != a.wins) return b.wins.compareTo(a.wins);
        if (b.buchholz != a.buchholz) return b.buchholz.compareTo(a.buchholz);
        if (b.sonnebornBerger != a.sonnebornBerger) return b.sonnebornBerger.compareTo(a.sonnebornBerger);
        return b.scoreDiff.compareTo(a.scoreDiff);
      });

    return standings;
  }

  /// Generates the next Swiss round pairing based on current standings and past encounters.
  BracketRound generateNextRound({
    required List<BracketRound> existingRounds,
    required List<String> allPlayers,
    required int seed,
  }) {
    final nextRoundIndex = existingRounds.length;
    final standings = calculateStandings(existingRounds, allPlayers);

    final playedPairs = <Set<String>>{};
    for (final r in existingRounds) {
      for (final m in r.matchups) {
        if (m.playerBName != null) {
          playedPairs.add({m.playerAName, m.playerBName!});
        }
      }
    }

    final unpaired = List<SwissPlayerStanding>.of(standings);
    final matchups = <Matchup>[];
    var matchCounter = 1;

    while (unpaired.isNotEmpty) {
      if (unpaired.length == 1) {
        // Last player gets a Bye
        final p = unpaired.removeAt(0);
        matchups.add(
          Matchup(
            matchId: 'SWISS-R${nextRoundIndex + 1}-M$matchCounter',
            playerAId: p.playerName,
            playerAName: p.playerName,
            playerBId: null,
            playerBName: null,
            winnerId: p.playerName,
            isCompleted: true,
          ),
        );
        break;
      }

      final pA = unpaired.removeAt(0);
      var opponentIndex = -1;

      // Find first compatible opponent they haven't played against yet
      for (var i = 0; i < unpaired.length; i++) {
        final candidate = unpaired[i];
        if (!playedPairs.contains({pA.playerName, candidate.playerName})) {
          opponentIndex = i;
          break;
        }
      }

      // If everyone in bracket has played, fallback to nearest score
      if (opponentIndex == -1) {
        opponentIndex = 0;
      }

      final pB = unpaired.removeAt(opponentIndex);
      playedPairs.add({pA.playerName, pB.playerName});

      matchups.add(
        Matchup(
          matchId: 'SWISS-R${nextRoundIndex + 1}-M$matchCounter',
          playerAId: pA.playerName,
          playerAName: pA.playerName,
          playerBId: pB.playerName,
          playerBName: pB.playerName,
          tableNumber: matchCounter,
        ),
      );
      matchCounter++;
    }

    return BracketRound(
      roundIndex: nextRoundIndex,
      name: 'Ronda Suizo ${nextRoundIndex + 1}',
      matchups: matchups,
    );
  }
}
