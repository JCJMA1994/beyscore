import 'player_stats_snapshot.dart';

abstract class StatsRepository {
  Stream<PlayerStatsSnapshot?> watchForPlayer(String playerId);
  Future<void> recalculate(String playerId);
}
