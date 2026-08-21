import 'match.dart';

/// Abstract battle repository with match observation and history persistence.
abstract class BattleRepository {
  Future<void> saveMatch(Match match);
  Stream<Match> watchMatch(String matchId);
  Future<Match?> getMatch(String matchId);
  Stream<List<Match>> watchAllMatches();
  Future<List<Match>> getMatchHistory();
}
