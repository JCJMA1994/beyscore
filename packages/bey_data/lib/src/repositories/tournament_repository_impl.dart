import 'dart:async';

import 'package:bey_domain/bey_domain.dart';
import 'package:rxdart/rxdart.dart';

import '../datasources/tournament_local_datasource.dart';
import '../sync/supabase_sync_service.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  TournamentRepositoryImpl([
    this._localDataSource,
    this._syncService,
  ]);

  final TournamentLocalDataSource? _localDataSource;
  final SupabaseSyncService? _syncService;
  final _tournamentsSubject = BehaviorSubject<List<Tournament>>.seeded([]);

  @override
  Stream<List<Tournament>> watchAll() {
    final local = _localDataSource;
    if (local != null) {
      return local.watchTournaments();
    }
    return _tournamentsSubject.stream;
  }

  @override
  Future<void> save(Tournament tournament) async {
    final current = List<Tournament>.from(_tournamentsSubject.value);
    final index = current.indexWhere((t) => t.id == tournament.id);
    if (index >= 0) {
      current[index] = tournament;
    } else {
      current.add(tournament);
    }
    _tournamentsSubject.add(current);

    final local = _localDataSource;
    if (local != null) {
      await local.saveTournament(tournament);
    }

    final service = _syncService;
    if (service != null && service.isAvailable) {
      try {
        unawaited(service.pushTournaments([tournament]));
      } catch (_) {}
    }
  }

  @override
  Future<void> delete(String id) async {
    final current = List<Tournament>.from(_tournamentsSubject.value)
      ..removeWhere((t) => t.id == id);
    _tournamentsSubject.add(current);

    final local = _localDataSource;
    if (local != null) {
      await local.deleteTournament(id);
    }

    final service = _syncService;
    if (service != null && service.isAvailable) {
      unawaited(service.deleteTournament(id));
    }
  }

  @override
  Stream<Tournament> watchById(String id) {
    final local = _localDataSource;
    if (local != null) {
      return local.watchTournamentById(id);
    }
    return _tournamentsSubject.stream
        .map((list) => list.firstWhere((t) => t.id == id));
  }
}
