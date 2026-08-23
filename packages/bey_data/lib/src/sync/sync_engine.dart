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
      // 1. Ensure authenticated session with Supabase
      final authUserId = await _supabaseSync.ensureAuthenticated();

      // 2. Sync User Profile if exists, and resolve cloud auth ID
      final profile = await _identityDataSource.getActiveProfile();
      if (profile != null) {
        await _supabaseSync.syncProfile(
          id: authUserId ?? profile.id,
          nickname: profile.nickname,
          recoveryCodeHash: profile.recoveryCodeHash,
        );

        // If local profile ID differed from cloud auth ID, update local profile
        if (authUserId != null && authUserId != profile.id) {
          final updated = profile.copyWith(id: authUserId);
          await _identityDataSource.saveActiveProfile(updated);
        }
      }

      final activeUserId = authUserId ?? profile?.id;
      if (activeUserId != null) {
        // 2. Bidirectional Sync Combos: Pull from cloud first, merge to SQLite, then push
        final cloudCombos = await _supabaseSync.pullCombos(activeUserId);
        final localCombos = await _comboDataSource.getCombos();
        final localCombosMap = {for (final c in localCombos) c.id: c};

        for (final c in cloudCombos) {
          final id = c['id'] as String;
          final cloudUpdatedAt = DateTime.tryParse(c['updated_at'] as String? ?? '');
          final local = localCombosMap[id];

          if (local == null || (cloudUpdatedAt != null && (local.updatedAt == null || cloudUpdatedAt.isAfter(local.updatedAt!)))) {
            final combo = Combo(
              id: id,
              name: c['name'] as String? ?? 'Combo',
              bladeId: c['blade_id'] as String? ?? '',
              ratchetId: c['ratchet_id'] as String? ?? '',
              bitId: c['bit_id'] as String? ?? '',
              lockChipId: c['lock_chip_id'] as String?,
              assistBladeId: c['assist_blade_id'] as String?,
              system: BeySystem.values[(c['system'] as int?) ?? 0],
              calculatedWeight: (c['calculated_weight'] as num?)?.toDouble(),
              updatedAt: cloudUpdatedAt,
            );
            await _comboDataSource.insertOrUpdateCombo(combo);
          }
        }

        final allCombos = await _comboDataSource.getCombos();
        if (allCombos.isNotEmpty) {
          await _supabaseSync.pushCombos(allCombos, userId: activeUserId);
        }

        // 3. Bidirectional Sync Decks: Pull from cloud first, merge to SQLite, then push
        final cloudDecks = await _supabaseSync.pullDecks(activeUserId);
        final localDecks = await _deckDataSource.getDecks();
        final localDecksMap = {for (final d in localDecks) d.id: d};

        for (final d in cloudDecks) {
          final id = d['id'] as String;
          final cloudUpdatedAt = DateTime.tryParse(d['updated_at'] as String? ?? '');
          final local = localDecksMap[id];

          if (local == null || (cloudUpdatedAt != null && (local.updatedAt == null || cloudUpdatedAt.isAfter(local.updatedAt!)))) {
            final comboIds = (d['combo_ids'] as List?)?.cast<String>() ?? [];
            final deck = Deck(
              id: id,
              name: d['name'] as String? ?? 'Deck 3on3',
              comboIds: comboIds,
              updatedAt: cloudUpdatedAt,
            );
            await _deckDataSource.insertOrUpdateDeck(deck);
          }
        }

        final allDecks = await _deckDataSource.getDecks();
        if (allDecks.isNotEmpty) {
          await _supabaseSync.pushDecks(allDecks, userId: activeUserId);
        }
      }

      // 4. Bidirectional Sync Tournaments: Pull from cloud first, then push local
      final tournamentSource = _tournamentDataSource;
      if (tournamentSource != null) {
        // Pull active & completed cloud tournaments
        final cloudTournaments = await _supabaseSync.pullActiveTournaments();
        final localTournaments = await tournamentSource.getTournaments();
        final localMap = {for (final t in localTournaments) t.id: t};

        for (final cloud in cloudTournaments) {
          final local = localMap[cloud.id];
          if (local == null || cloud.status == TournamentStatus.completed || cloud.rounds.length >= local.rounds.length) {
            await tournamentSource.saveTournament(cloud);
          }
        }

        final allLocal = await tournamentSource.getTournaments();
        if (allLocal.isNotEmpty) {
          await _supabaseSync.pushTournaments(allLocal, userId: activeUserId);
        }
      }
    } catch (_) {
      // Offline fallback: silence background sync network errors
    } finally {
      _isRunning.add(false);
    }
  }
}
