/// Materialized stats snapshot.
///
/// Recalculated by event when a match is CONFIRMED, not on every read.
/// The heavy computation runs in an Isolate (compute).
/// Incremental updates apply only the delta of the last match.
/// Full reconstruction is available from the admin panel as a repair op.
/// (arquitectura.md section 8)
class PlayerStatsSnapshot {
  const PlayerStatsSnapshot({
    required this.playerId,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.xtremeFinishes,
    required this.overFinishes,
    required this.burstFinishes,
    required this.spinFinishes,
    required this.penaltyPoints,
    this.lastUpdated,
  });

  final String playerId;
  final int totalMatches;
  final int wins;
  final int losses;
  final int xtremeFinishes;
  final int overFinishes;
  final int burstFinishes;
  final int spinFinishes;

  /// Tracked separately: high penalty rate = bad launcher technique.
  final int penaltyPoints;

  final DateTime? lastUpdated;

  double get winRate =>
      totalMatches > 0 ? wins / totalMatches : 0;
}
