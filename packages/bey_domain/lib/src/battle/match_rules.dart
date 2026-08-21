/// Rules configuration for a match.
///
/// Pure Dart. The default is the official v12 rules (target: 4 points).
class MatchRules {
  const MatchRules({
    this.targetPoints = 4,
    this.allowXtreme = true,
  });

  /// Points needed to win. Default 4 per v12 rules.
  final int targetPoints;

  /// Whether Xtreme finishes are allowed in this match.
  final bool allowXtreme;
}
