import 'dart:async';

import 'package:bey_domain/bey_domain.dart';
import 'package:rxdart/rxdart.dart';

import '../datasources/combo_local_datasource.dart';
import '../datasources/deck_local_datasource.dart';
import '../datasources/identity_local_datasource.dart';
import '../datasources/tournament_local_datasource.dart';
import 'connectivity_monitor.dart';
import 'supabase_sync_service.dart';

/// Drives the offline-first sync loop between local Drift/SQLite storage and Supabase.
///
/// Fires on: app startup, network reconnect, and every 30s.
/// Uses BehaviorSubject so late subscribers get the last known state.
class SyncEngine {
  SyncEngine({
    required ConnectivityMonitor connectivity,
    required SupabaseSyncService supabaseSync,
    required ComboLocalDataSource comboDataSource,
    required DeckLocalDataSource deckDataSource,
    required IdentityLocalDataSource identityDataSource,
    TournamentLocalDataSource? tournamentDataSource,
  })  : _connectivity = connectivity,
        _supabaseSync = supabaseSync,
        _comboDataSource = comboDataSource,
        _deckDataSource = deckDataSource,
        _identityDataSource = identityDataSource,
        _tournamentDataSource = tournamentDataSource;

  final ConnectivityMonitor _connectivity;
  final SupabaseSyncService _supabaseSync;
  final ComboLocalDataSource _comboDataSource;
  final DeckLocalDataSource _deckDataSource;
  final IdentityLocalDataSource _identityDataSource;
  final TournamentLocalDataSource? _tournamentDataSource;

  final _isRunning = BehaviorSubject<bool>.seeded(false);
  Timer? _periodicTimer;

  Stream<bool> get isRunningStream => _isRunning.stream;
  bool get isRunning => _isRunning.value;

  /// Start the periodic sync loop (every 30 seconds) + on reconnect + on start.
  void start() {
    _periodicTimer?.cancel();

    // Immediate initial sync pass
    _syncPending();

    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _syncPending(),
    );

    // Also sync on connectivity changes.
    _connectivity.stream
        .where((online) => online)
        .listen((_) => _syncPending());
  }

  void dispose() {
    _periodicTimer?.cancel();
    _isRunning.close();
  }

  /// Manually triggers an immediate cloud sync pass.
  Future<void> syncNow() => _syncPending();

  Future<void> _syncPending() async {
    if (_isRunning.value || !_supabaseSync.isAvailable) return;
    _isRunning.add(true);

    try {
      // 1. Sync User Profile if exists
      final profile = await _identityDataSource.getActiveProfile();
      if (profile != null) {
        await _supabaseSync.syncProfile(
          id: profile.id,
          nickname: profile.nickname,
          recoveryCodeHash: profile.recoveryCodeHash,
        );
      }

      // 2. Sync Combos
      final combos = await _comboDataSource.getCombos();
      if (combos.isNotEmpty) {
        await _supabaseSync.pushCombos(combos, userId: profile?.id);
      }

      // 3. Sync Decks
      final decks = await _deckDataSource.getDecks();
      if (decks.isNotEmpty) {
        await _supabaseSync.pushDecks(decks, userId: profile?.id);
      }

      // 4. Sync Tournaments: ONLY completed tournaments sync with the cloud (for global rankings & history)
      final tournamentSource = _tournamentDataSource;
      if (tournamentSource != null) {
        final tournaments = await tournamentSource.getTournaments();
        final completedTournaments = tournaments.where((t) => t.status == TournamentStatus.completed).toList();
        if (completedTournaments.isNotEmpty) {
          await _supabaseSync.pushTournaments(completedTournaments, userId: profile?.id);
        }
      }
    } catch (_) {
      // Offline fallback: silence background sync network errors
    } finally {
      _isRunning.add(false);
    }
  }
}
