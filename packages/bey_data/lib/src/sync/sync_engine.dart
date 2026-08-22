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

        // 2. Bidirectional Sync Combos: Pull from cloud first, merge to SQLite, then push
        final cloudCombos = await _supabaseSync.pullCombos(profile.id);
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
          await _supabaseSync.pushCombos(allCombos, userId: profile.id);
        }

        // 3. Bidirectional Sync Decks: Pull from cloud first, merge to SQLite, then push
        final cloudDecks = await _supabaseSync.pullDecks(profile.id);
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
          await _supabaseSync.pushDecks(allDecks, userId: profile.id);
        }
      } else {
        // Guest mode fallback: push whatever is local if client authenticated
        final combos = await _comboDataSource.getCombos();
        if (combos.isNotEmpty) {
          await _supabaseSync.pushCombos(combos);
        }
        final decks = await _deckDataSource.getDecks();
        if (decks.isNotEmpty) {
          await _supabaseSync.pushDecks(decks);
        }
      }

      // 4. Sync Tournaments: ONLY completed tournaments sync with the cloud
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
