import '../battle/finish_type.dart';
import '../battle/match.dart';
import '../battle/scoring_service.dart';

/// Statistical head-to-head record between two competing Bladers.
class HeadToHeadRecord {
  const HeadToHeadRecord({
    required this.playerAName,
    required this.playerBName,
    required this.totalMatches,
    required this.winsA,
    required this.winsB,
    required this.finishesA,
    required this.finishesB,
    this.lastWinner,
    required this.streak,
    this.streakHolder,
    required this.isRevengeOpportunity,
  });

  final String playerAName;
  final String playerBName;
  final int totalMatches;
  final int winsA;
  final int winsB;
  final Map<FinishType, int> finishesA;
  final Map<FinishType, int> finishesB;
  final String? lastWinner;
  final int streak;
  final String? streakHolder;
  final bool isRevengeOpportunity;

  double get winRateA => totalMatches > 0 ? winsA / totalMatches : 0.0;
  double get winRateB => totalMatches > 0 ? winsB / totalMatches : 0.0;
}

/// Domain service calculating head-to-head rivalries and revenge match context.
class RivalryService {
  const RivalryService();

  HeadToHeadRecord computeHeadToHead({
    required List<Match> matches,
    required String playerA,
    required String playerB,
    ScoringService scoringService = const ScoringService(),
  }) {
    final normA = playerA.trim().toLowerCase();
    final normB = playerB.trim().toLowerCase();

    // Filter matches between these two players (regardless of order A/B)
    final h2hMatches = matches.where((m) {
      final p1 = m.playerAId.trim().toLowerCase();
      final p2 = m.playerBId.trim().toLowerCase();
      return (p1 == normA && p2 == normB) || (p1 == normB && p2 == normA);
    }).toList()
      ..sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });

    var winsA = 0;
    var winsB = 0;
    final finishesA = <FinishType, int>{for (final f in FinishType.values) f: 0};
    final finishesB = <FinishType, int>{for (final f in FinishType.values) f: 0};

    String? currentStreakHolder;
    var currentStreak = 0;
    String? lastWinner;

    for (final m in h2hMatches) {
      final isPlayer1A = m.playerAId.trim().toLowerCase() == normA;
      final matchScore = scoringService.scoreOf(m);
      final scoreA = isPlayer1A ? matchScore.playerAPoints : matchScore.playerBPoints;
      final scoreB = isPlayer1A ? matchScore.playerBPoints : matchScore.playerAPoints;

      String? matchWinner;
      if (scoreA >= m.rules.targetPoints && scoreA > scoreB) {
        matchWinner = playerA;
        winsA++;
      } else if (scoreB >= m.rules.targetPoints && scoreB > scoreA) {
        matchWinner = playerB;
        winsB++;
      }

      if (matchWinner != null) {
        lastWinner = matchWinner;
        if (currentStreakHolder == matchWinner) {
          currentStreak++;
        } else {
          currentStreakHolder = matchWinner;
          currentStreak = 1;
        }
      }

      // Aggregate finishes
      for (final f in m.finishes) {
        if (f.voidedTargetId != null) continue;
        final scoredByA = f.scoringPlayerId.trim().toLowerCase() == normA;
        if (scoredByA) {
          finishesA[f.type] = (finishesA[f.type] ?? 0) + 1;
        } else {
          finishesB[f.type] = (finishesB[f.type] ?? 0) + 1;
        }
      }
    }

    final isRevengeOpportunity = lastWinner != null && lastWinner.trim().toLowerCase() == normB;

    return HeadToHeadRecord(
      playerAName: playerA,
      playerBName: playerB,
      totalMatches: h2hMatches.length,
      winsA: winsA,
      winsB: winsB,
      finishesA: finishesA,
      finishesB: finishesB,
      lastWinner: lastWinner,
      streak: currentStreak,
      streakHolder: currentStreakHolder,
      isRevengeOpportunity: isRevengeOpportunity,
    );
  }
}
