import 'battle_finish.dart';
import 'match_outcome.dart';
import 'match_rules.dart';

/// Format of the match.
enum MatchFormat { singles, threeOnThree, team }

/// Status of a match.
enum MatchStatus { setup, inProgress, pendingConfirmation, disputed, confirmed }

/// A single match between two players.
///
/// `tournamentId` is nullable: same engine for quick play and tournament
/// (decision #4 from CLAUDE.md).
///
/// In 3on3: a Match contains rounds, each round is lineup[i] vs lineup[i].
class Match {
  const Match({
    required this.id,
    required this.playerAId,
    required this.playerBId,
    this.tournamentId,
    required this.format,
    required this.rules,
    required this.status,
    this.finishes = const [],
    this.outcome,
    this.createdAt,
  });

  final String id;
  final String playerAId;
  final String playerBId;

  /// Null for quick play, set for tournament matches.
  final String? tournamentId;

  final MatchFormat format;
  final MatchRules rules;
  final MatchStatus status;
  final List<BattleFinish> finishes;
  final MatchOutcome? outcome;
  final DateTime? createdAt;

  bool get isOpen => status == MatchStatus.inProgress;
  bool get isClosed =>
      status == MatchStatus.confirmed ||
      status == MatchStatus.pendingConfirmation ||
      outcome != null;

  Match copyWith({
    MatchStatus? status,
    List<BattleFinish>? finishes,
    MatchOutcome? outcome,
  }) {
    return Match(
      id: id,
      playerAId: playerAId,
      playerBId: playerBId,
      tournamentId: tournamentId,
      format: format,
      rules: rules,
      status: status ?? this.status,
      finishes: finishes ?? this.finishes,
      outcome: outcome ?? this.outcome,
      createdAt: createdAt,
    );
  }
}

/// Derived score. Never stored — always computed from finishes.
class MatchScore {
  const MatchScore({required this.playerAPoints, required this.playerBPoints});
  final int playerAPoints;
  final int playerBPoints;
}
