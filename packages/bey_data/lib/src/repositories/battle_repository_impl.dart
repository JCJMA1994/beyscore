import 'package:bey_domain/bey_domain.dart';
import 'package:rxdart/rxdart.dart';

import '../datasources/battle_local_datasource.dart';

class BattleRepositoryImpl implements BattleRepository {
  BattleRepositoryImpl([this._localDataSource]);

  final BattleLocalDataSource? _localDataSource;
  final _matchesSubject = BehaviorSubject<Map<String, Match>>.seeded({});

  @override
  Future<void> saveMatch(Match match) async {
    final current = Map<String, Match>.from(_matchesSubject.value);
    current[match.id] = match;
    _matchesSubject.add(current);

    final local = _localDataSource;
    if (local != null) {
      await local.insertOrUpdateMatch(match);
    }
  }

  @override
  Stream<Match> watchMatch(String matchId) {
    return _matchesSubject.stream
        .where((map) => map.containsKey(matchId))
        .map((map) => map[matchId]!);
  }

  @override
  Future<Match?> getMatch(String matchId) async {
    if (_matchesSubject.value.containsKey(matchId)) {
      return _matchesSubject.value[matchId];
    }
    return _localDataSource?.getMatchById(matchId);
  }

  @override
  Stream<List<Match>> watchAllMatches() {
    final local = _localDataSource;
    if (local != null) {
      return local.watchAllMatches();
    }
    return _matchesSubject.stream.map((m) => m.values.toList());
  }

  @override
  Future<List<Match>> getMatchHistory() async {
    final local = _localDataSource;
    if (local != null) {
      return local.getMatchHistory();
    }
    return _matchesSubject.value.values.toList();
  }
}
