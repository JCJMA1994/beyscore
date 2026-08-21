/// Lifecycle status for a single tournament matchup.
enum MatchupStatus {
  /// Scheduled and waiting to be called to the stadium.
  pending('Pendiente'),

  /// Officially called to arena / actively battling.
  inProgress('En Combate'),

  /// Concluded with a verified official score.
  completed('Finalizado'),

  /// Concluded via Walkover (no-show / forfeiture).
  walkover('W.O.');

  const MatchupStatus(this.label);
  final String label;
}

/// Bracket structure for single-elimination tournaments.
class Bracket {
  const Bracket({
    required this.tournamentId,
    required this.rounds,
  });

  final String tournamentId;
  final List<BracketRound> rounds;
}

class BracketRound {
  const BracketRound({
    required this.roundIndex,
    required this.name,
    required this.matchups,
  });

  final int roundIndex;
  final String name; // e.g. "Ronda 1", "Cuartos de Final", "Semifinales", "Gran Final"
  final List<Matchup> matchups;

  BracketRound copyWith({
    int? roundIndex,
    String? name,
    List<Matchup>? matchups,
  }) {
    return BracketRound(
      roundIndex: roundIndex ?? this.roundIndex,
      name: name ?? this.name,
      matchups: matchups ?? this.matchups,
    );
  }
}

class Matchup {
  const Matchup({
    required this.matchId,
    required this.playerAId,
    required this.playerAName,
    this.playerBId, // null = bye
    this.playerBName,
    this.tableNumber,
    this.winnerId,
    this.scoreA = 0,
    this.scoreB = 0,
    this.isCompleted = false,
    this.status = MatchupStatus.pending,
  });

  static const _sentinel = Object();

  final String matchId;
  final String playerAId;
  final String playerAName;
  final String? playerBId;
  final String? playerBName;
  final int? tableNumber;
  final String? winnerId;
  final int scoreA;
  final int scoreB;
  final bool isCompleted;
  final MatchupStatus status;

  bool get isBye => playerBId == null;
  bool get isReadyToCall => !isCompleted && !isBye && playerAName != 'TBD' && playerBName != 'TBD' && playerBName != null && playerBName!.isNotEmpty;
  bool get isInProgress => status == MatchupStatus.inProgress;
  bool get isPending => status == MatchupStatus.pending;

  Matchup copyWith({
    String? matchId,
    String? playerAId,
    String? playerAName,
    Object? playerBId = _sentinel,
    Object? playerBName = _sentinel,
    int? tableNumber,
    String? winnerId,
    int? scoreA,
    int? scoreB,
    bool? isCompleted,
    MatchupStatus? status,
  }) {
    return Matchup(
      matchId: matchId ?? this.matchId,
      playerAId: playerAId ?? this.playerAId,
      playerAName: playerAName ?? this.playerAName,
      playerBId: playerBId == _sentinel ? this.playerBId : playerBId as String?,
      playerBName: playerBName == _sentinel ? this.playerBName : playerBName as String?,
      tableNumber: tableNumber ?? this.tableNumber,
      winnerId: winnerId ?? this.winnerId,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
    );
  }
}
