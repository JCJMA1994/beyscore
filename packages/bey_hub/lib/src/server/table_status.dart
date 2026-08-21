class TableStatus {
  const TableStatus({
    required this.tableNumber,
    required this.playerA,
    required this.playerB,
    required this.scoreA,
    required this.scoreB,
    required this.status, // IDLE, RUNNING, DISPUTE, CONFIRMED
    required this.lastSeen,
    this.lastFinishType,
    this.isPenalty = false,
  });

  final int tableNumber;
  final String playerA;
  final String playerB;
  final int scoreA;
  final int scoreB;
  final String status;
  final DateTime lastSeen;
  final String? lastFinishType;
  final bool isPenalty;

  TableStatus copyWith({
    int? tableNumber,
    String? playerA,
    String? playerB,
    int? scoreA,
    int? scoreB,
    String? status,
    DateTime? lastSeen,
    String? lastFinishType,
    bool? isPenalty,
  }) {
    return TableStatus(
      tableNumber: tableNumber ?? this.tableNumber,
      playerA: playerA ?? this.playerA,
      playerB: playerB ?? this.playerB,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      lastFinishType: lastFinishType ?? this.lastFinishType,
      isPenalty: isPenalty ?? this.isPenalty,
    );
  }
}
