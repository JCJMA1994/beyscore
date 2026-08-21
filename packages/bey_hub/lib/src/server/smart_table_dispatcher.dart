import 'dart:async';
import 'package:bey_domain/bey_domain.dart';
import 'lan_hub_server.dart';
import 'table_status.dart';

/// Smart queue manager that automatically assigns pending tournament matches
/// to liberated table stations once a previous match is completed and confirmed.
class SmartTableDispatcher {
  SmartTableDispatcher({
    required this.hubServer,
    required this.getPendingMatchups,
    required this.onMatchDispatched,
  }) {
    _subscription = hubServer.tablesStream.listen(_handleTablesUpdate);
  }

  final LanHubServer hubServer;
  final List<Matchup> Function() getPendingMatchups;
  final void Function(Matchup matchup, int tableNumber) onMatchDispatched;

  StreamSubscription<Map<int, TableStatus>>? _subscription;
  final Set<int> _activeTables = {};

  void _handleTablesUpdate(Map<int, TableStatus> tables) {
    for (final entry in tables.entries) {
      final tableNumber = entry.key;
      final table = entry.value;

      final status = table.status;
      if (status == 'CONFIRMED' || status == 'IDLE') {
        if (_activeTables.contains(tableNumber) || status == 'IDLE') {
          _activeTables.remove(tableNumber);
          dispatchNextMatchToTable(tableNumber);
        }
      } else if (status == 'RUNNING' || status == 'DISPUTE') {
        _activeTables.add(tableNumber);
      }
    }
  }

  /// Finds the next ready matchup and assigns it to [tableNumber].
  bool dispatchNextMatchToTable(int tableNumber) {
    final pending = getPendingMatchups();
    if (pending.isEmpty) return false;

    // Find first matchup with both players known and not completed
    final nextMatch = pending.firstWhere(
      (m) =>
          !m.isCompleted &&
          m.playerAId != 'TBD' &&
          m.playerBId != null &&
          m.playerBId != 'TBD',
      orElse: () => const Matchup(
        matchId: '',
        playerAId: 'NONE',
        playerAName: 'NONE',
      ),
    );

    if (nextMatch.matchId.isEmpty || nextMatch.playerAId == 'NONE') {
      return false;
    }

    hubServer.assignMatchToTable(
      tableNumber: tableNumber,
      playerA: nextMatch.playerAName,
      playerB: nextMatch.playerBName ?? 'TBD',
    );

    _activeTables.add(tableNumber);
    onMatchDispatched(nextMatch, tableNumber);
    return true;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
