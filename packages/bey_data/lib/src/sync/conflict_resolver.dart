/// Strategy interface for resolving sync conflicts.
///
/// Each entity type picks its own strategy (CLAUDE.md section 7):
/// - Catalog: server wins always
/// - Combos/decks: last write wins (single owner)
/// - BattleFinish: append-only, set union by (matchId, roundIndex, sequence)
/// - Bracket/tournament: organizer device is authoritative
/// - Disputed result: escalate to human
abstract class ConflictResolver<T> {
  const ConflictResolver();

  /// Returns the winning version after resolving a conflict.
  /// May return null to signal "escalate to human".
  T? resolve({required T local, required T remote});
}
