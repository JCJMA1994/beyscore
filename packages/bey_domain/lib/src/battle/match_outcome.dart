/// How a match ends. Not always by points.
///
/// (CLAUDE.md section 4 — conduct rules)
sealed class MatchOutcome {
  const MatchOutcome();
}

/// Normal ending: a player reached the target points.
class PointsReached extends MatchOutcome {
  const PointsReached();
}

/// Instant loss: touching a bey before the judge declares (or similar).
/// Only the judge can apply this; never from a player's phone.
class InstantLoss extends MatchOutcome {
  const InstantLoss({required this.reason});
  final String reason;
}

/// Player forfeits (no-show).
class Forfeit extends MatchOutcome {
  const Forfeit();
}
