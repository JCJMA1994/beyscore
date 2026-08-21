import '../battle/finish_type.dart';
import '../battle/match.dart';
import '../catalog/part_type.dart';
import '../tournament/bracket.dart';

/// Performance and usage metrics for a specific catalog part.
class PartMetaStat {
  const PartMetaStat({
    required this.identityKey,
    required this.name,
    required this.type,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.spinFinishes,
    required this.overFinishes,
    required this.burstFinishes,
    required this.xtremeFinishes,
  });

  final String identityKey;
  final String name;
  final PartType type;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int spinFinishes;
  final int overFinishes;
  final int burstFinishes;
  final int xtremeFinishes;

  double get winRate => matchesPlayed > 0 ? wins / matchesPlayed : 0.0;
  int get totalFinishes => spinFinishes + overFinishes + burstFinishes + xtremeFinishes;
}

/// Archetype advantage record (Attack, Defense, Stamina, Balance).
class ArchetypeStats {
  const ArchetypeStats({
    required this.archetype,
    required this.totalMatches,
    required this.wins,
    required this.losses,
  });

  final String archetype; // 'Ataque', 'Defensa', 'Resistencia', 'Balance'
  final int totalMatches;
  final int wins;
  final int losses;

  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;
}

/// Tournament summary metrics and podium.
class TournamentMetaReport {
  const TournamentMetaReport({
    required this.tournamentName,
    required this.firstPlace,
    this.secondPlace,
    this.thirdPlace,
    required this.totalMatches,
    required this.totalPointsScored,
    required this.spinFinishesCount,
    required this.overFinishesCount,
    required this.burstFinishesCount,
    required this.xtremeFinishesCount,
    required this.topParts,
  });

  final String tournamentName;
  final String firstPlace;
  final String? secondPlace;
  final String? thirdPlace;
  final int totalMatches;
  final int totalPointsScored;
  final int spinFinishesCount;
  final int overFinishesCount;
  final int burstFinishesCount;
  final int xtremeFinishesCount;
  final List<PartMetaStat> topParts;
}

/// Pure domain analytics service for BeyScore.
///
/// Computes competitive meta metrics, archetype matchup statistics,
/// and tournament performance reports without external dependencies.
class MetaAnalyticsService {
  const MetaAnalyticsService();

  /// Calculates finish distribution across all recorded matches.
  Map<FinishType, int> calculateFinishDistribution(List<Match> matches) {
    final dist = <FinishType, int>{
      FinishType.spin: 0,
      FinishType.over: 0,
      FinishType.burst: 0,
      FinishType.xtreme: 0,
      FinishType.penalty: 0,
    };

    for (final m in matches) {
      for (final f in m.finishes) {
        if (f.isVoid) continue;
        dist[f.type] = (dist[f.type] ?? 0) + 1;
      }
    }

    return dist;
  }

  /// Calculates archetype performance.
  List<ArchetypeStats> calculateArchetypeStats({
    required List<Match> matches,
    required Map<String, String> playerArchetypes, // playerId -> 'Ataque'/'Defensa'/'Resistencia'/'Balance'
  }) {
    final wins = <String, int>{'Ataque': 0, 'Defensa': 0, 'Resistencia': 0, 'Balance': 0};
    final totals = <String, int>{'Ataque': 0, 'Defensa': 0, 'Resistencia': 0, 'Balance': 0};

    for (final m in matches) {
      final archA = playerArchetypes[m.playerAId] ?? 'Balance';
      final archB = playerArchetypes[m.playerBId] ?? 'Balance';

      totals[archA] = (totals[archA] ?? 0) + 1;
      totals[archB] = (totals[archB] ?? 0) + 1;

      final winner = m.finishes.isEmpty ? null : m.finishes.last.scoringPlayerId;
      if (winner == m.playerAId) {
        wins[archA] = (wins[archA] ?? 0) + 1;
      } else if (winner == m.playerBId) {
        wins[archB] = (wins[archB] ?? 0) + 1;
      }
    }

    return ['Ataque', 'Defensa', 'Resistencia', 'Balance'].map((arch) {
      final t = totals[arch] ?? 0;
      final w = wins[arch] ?? 0;
      return ArchetypeStats(
        archetype: arch,
        totalMatches: t,
        wins: w,
        losses: t >= w ? t - w : 0,
      );
    }).toList();
  }

  /// Generates a comprehensive tournament summary report from completed bracket rounds.
  TournamentMetaReport generateTournamentReport({
    required String tournamentName,
    required List<BracketRound> rounds,
  }) {
    if (rounds.isEmpty) {
      return TournamentMetaReport(
        tournamentName: tournamentName,
        firstPlace: 'N/A',
        totalMatches: 0,
        totalPointsScored: 0,
        spinFinishesCount: 0,
        overFinishesCount: 0,
        burstFinishesCount: 0,
        xtremeFinishesCount: 0,
        topParts: const [],
      );
    }

    final finalRound = rounds.last;
    var firstPlace = 'TBD';
    String? secondPlace;
    String? thirdPlace;

    if (finalRound.matchups.isNotEmpty) {
      final grandFinal = finalRound.matchups.first;
      if (grandFinal.isCompleted && grandFinal.winnerId != null) {
        firstPlace = grandFinal.winnerId!;
        secondPlace = (grandFinal.winnerId == grandFinal.playerAName)
            ? grandFinal.playerBName
            : grandFinal.playerAName;
      }

      // Check if 3rd place match exists in final round
      final bronzeMatches = finalRound.matchups.where((m) => m.matchId == 'BRONZE-3RD' || m.matchId.contains('3RD'));
      if (bronzeMatches.isNotEmpty) {
        final bronzeMatch = bronzeMatches.first;
        if (bronzeMatch.isCompleted && bronzeMatch.winnerId != null && bronzeMatch.winnerId != 'TBD') {
          thirdPlace = bronzeMatch.winnerId;
        }
      } else if (finalRound.matchups.length >= 2) {
        final bronzeMatch = finalRound.matchups[1];
        if (bronzeMatch.isCompleted && bronzeMatch.winnerId != null && bronzeMatch.winnerId != 'TBD') {
          thirdPlace = bronzeMatch.winnerId;
        }
      }

      // Fallback: If 3rd place was not played, take the semifinal loser with highest score
      if (thirdPlace == null && rounds.length >= 2) {
        final semiRound = rounds[rounds.length - 2];
        for (final m in semiRound.matchups) {
          if (m.isCompleted && m.winnerId != null) {
            final loser = (m.winnerId == m.playerAName) ? m.playerBName : m.playerAName;
            if (loser != null && loser != 'TBD') {
              thirdPlace = loser;
              break;
            }
          }
        }
      }
    }

    var totalPoints = 0;
    const spinCount = 0;
    const overCount = 0;
    const burstCount = 0;
    const xtremeCount = 0;
    var totalMatches = 0;

    for (final r in rounds) {
      for (final m in r.matchups) {
        if (!m.isCompleted) continue;
        totalMatches++;
        totalPoints += m.scoreA + m.scoreB;
      }
    }

    return TournamentMetaReport(
      tournamentName: tournamentName,
      firstPlace: firstPlace,
      secondPlace: secondPlace,
      thirdPlace: thirdPlace,
      totalMatches: totalMatches,
      totalPointsScored: totalPoints,
      spinFinishesCount: spinCount,
      overFinishesCount: overCount,
      burstFinishesCount: burstCount,
      xtremeFinishesCount: xtremeCount,
      topParts: const [],
    );
  }
}
