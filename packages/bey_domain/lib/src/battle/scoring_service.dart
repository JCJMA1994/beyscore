import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';
import 'battle_finish.dart';
import 'finish_type.dart';
import 'match.dart';

/// Pure domain service for scoring logic.
///
/// No I/O, no Flutter, no mocks needed. 100% test coverage target.
/// (CLAUDE.md section 6)
class ScoringService {
  const ScoringService();

  /// Points awarded for each finish type.
  int pointsFor(FinishType type) => switch (type) {
        FinishType.xtreme => 3,
        FinishType.over => 2,
        FinishType.burst => 2,
        FinishType.spin => 1,
        FinishType.penalty => 1,
      };

  /// Compute the current score from the list of finishes.
  MatchScore scoreOf(Match match) {
    var a = 0;
    var b = 0;

    // Collect voided finish IDs to exclude them.
    final voided = match.finishes
        .where((f) => f.voidedTargetId != null)
        .map((f) => f.voidedTargetId!)
        .toSet();

    for (final f in match.finishes) {
      if (f.isVoid || voided.contains(f.id)) continue;

      final pts = pointsFor(f.type);
      if (f.scoringPlayerId == match.playerAId) {
        a += pts;
      } else {
        b += pts;
      }
    }

    return MatchScore(playerAPoints: a, playerBPoints: b);
  }

  /// Apply a finish to the match. Returns failure if the match is closed
  /// or the finish type is not allowed.
  Either<Failure, Match> applyFinish(Match match, BattleFinish finish) {
    if (match.isClosed) {
      return const Left(MatchAlreadyClosedFailure());
    }

    if (!match.rules.allowXtreme && finish.type == FinishType.xtreme) {
      return const Left(FinishNotAllowedFailure());
    }

    final updated = match.copyWith(
      finishes: [...match.finishes, finish],
    );

    return Right(_closeIfTargetReached(updated));
  }

  Match _closeIfTargetReached(Match match) {
    final score = scoreOf(match);
    final target = match.rules.targetPoints;

    if (score.playerAPoints >= target || score.playerBPoints >= target) {
      return match.copyWith(status: MatchStatus.pendingConfirmation);
    }

    return match;
  }
}
