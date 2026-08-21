import 'finish_type.dart';

/// A single recorded finish in a battle.
///
/// Append-only: finishes are never edited. Undo is a NEW entry
/// (FinishVoided), never a deletion. (CLAUDE.md section 7)
class BattleFinish {
  const BattleFinish({
    required this.id,
    required this.matchId,
    required this.roundIndex,
    required this.sequence,
    required this.type,
    required this.scoringPlayerId,
    required this.createdAt,
    this.isPenalty = false,
    this.voidedTargetId,
  });

  final String id;
  final String matchId;
  final int roundIndex;
  final int sequence;
  final FinishType type;

  /// The player who SCORED (received the points), not who lost.
  final String scoringPlayerId;

  final DateTime createdAt;

  /// True for penalty points. Shown differently in UI and stats.
  final bool isPenalty;

  /// If this finish voids a previous one, reference its ID.
  /// The voided finish is NOT deleted — undo is a new fact.
  final String? voidedTargetId;

  bool get isVoid => voidedTargetId != null;
}
