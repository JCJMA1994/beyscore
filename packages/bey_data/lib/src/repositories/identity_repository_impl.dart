import 'dart:async';

import 'package:bey_domain/bey_domain.dart';

import '../datasources/combo_local_datasource.dart';
import '../datasources/deck_local_datasource.dart';
import '../datasources/identity_local_datasource.dart';
import '../datasources/tournament_local_datasource.dart';
import '../sync/supabase_sync_service.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  IdentityRepositoryImpl({
    IdentityLocalDataSource? localDataSource,
    IdentityService? identityService,
    SupabaseSyncService? syncService,
    ComboLocalDataSource? comboLocalDataSource,
    DeckLocalDataSource? deckLocalDataSource,
    TournamentLocalDataSource? tournamentLocalDataSource,
  })  : _localDataSource = localDataSource ?? IdentityLocalDataSourceImpl(),
        _identityService = identityService ?? IdentityService(),
        _syncService = syncService,
        _comboLocalDataSource = comboLocalDataSource,
        _deckLocalDataSource = deckLocalDataSource,
        _tournamentLocalDataSource = tournamentLocalDataSource;

  final IdentityLocalDataSource _localDataSource;
  final IdentityService _identityService;
  final SupabaseSyncService? _syncService;
  final ComboLocalDataSource? _comboLocalDataSource;
  final DeckLocalDataSource? _deckLocalDataSource;
  final TournamentLocalDataSource? _tournamentLocalDataSource;

  @override
  Future<UserProfile?> getActiveProfile() => _localDataSource.getActiveProfile();

  @override
  Future<({UserProfile profile, String formattedRecoveryCode})> createProfile(String nickname) async {
    final existing = await _localDataSource.getActiveProfile();
    final result = _identityService.createAnonymousProfile(
      nickname: nickname,
      existingDeviceId: existing?.deviceId,
    );

    var finalProfile = result.profile;

    // Sync profile with Supabase cloud
    final service = _syncService;
    if (service != null && service.isAvailable) {
      try {
        final authUserId = await service.ensureAuthenticated();
        if (authUserId != null && authUserId.isNotEmpty) {
          finalProfile = finalProfile.copyWith(id: authUserId);
        }
        await service.syncProfile(
          id: finalProfile.id,
          nickname: finalProfile.nickname,
          recoveryCodeHash: finalProfile.recoveryCodeHash,
        );
      } catch (_) {
        // Safe offline fallback: SyncEngine will retry when connection is restored
      }
    }

    await _localDataSource.saveActiveProfile(finalProfile);

    return (profile: finalProfile, formattedRecoveryCode: result.formattedRecoveryCode);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _localDataSource.saveActiveProfile(profile);

    final service = _syncService;
    if (service != null && service.isAvailable) {
      try {
        await service.syncProfile(
          id: profile.id,
          nickname: profile.nickname,
          recoveryCodeHash: profile.recoveryCodeHash,
        );
      } catch (_) {
        // Safe offline fallback
      }
    }
  }

  @override
  Future<bool> restoreWithRecoveryCode(String code, {required String nickname}) async {
    final normalized = _identityService.normalizeRecoveryCode(code);
    if (normalized.length != 12) return false;

    final hash = _identityService.hashRecoveryCode(normalized);
    final existing = await _localDataSource.getActiveProfile();

    var resolvedNickname = nickname.trim().isNotEmpty ? nickname.trim() : 'BLADER';
    var resolvedUserId = existing?.id ?? 'BLADER-${hash.substring(0, 8).toUpperCase()}';

    // Query Supabase for existing cloud profile matching this recovery hash
    final service = _syncService;
    if (service != null && service.isAvailable) {
      final cloudProfile = await service.fetchProfileByRecoveryHash(hash);
      if (cloudProfile != null) {
        final cloudUserId = cloudProfile['id'] as String?;
        if (cloudUserId != null && cloudUserId.isNotEmpty) {
          resolvedUserId = cloudUserId;
        }

        final cloudName = cloudProfile['nickname'] as String?;
        if (cloudName != null && cloudName.trim().isNotEmpty && nickname.trim().isEmpty) {
          resolvedNickname = cloudName.trim();
        }

        // Pull and restore combos
        final comboSource = _comboLocalDataSource;
        if (comboSource != null) {
          final cloudCombos = await service.pullCombos(resolvedUserId);
          for (final c in cloudCombos) {
            try {
              final combo = Combo(
                id: c['id'] as String,
                name: c['name'] as String,
                bladeId: c['blade_id'] as String,
                ratchetId: c['ratchet_id'] as String,
                bitId: c['bit_id'] as String,
                lockChipId: c['lock_chip_id'] as String?,
                assistBladeId: c['assist_blade_id'] as String?,
                system: BeySystem.values[(c['system'] as int?) ?? 0],
                calculatedWeight: (c['calculated_weight'] as num?)?.toDouble(),
                updatedAt: DateTime.tryParse(c['updated_at'] as String? ?? ''),
              );
              await comboSource.insertOrUpdateCombo(combo);
            } catch (_) {}
          }
        }

        // Pull and restore decks
        final deckSource = _deckLocalDataSource;
        if (deckSource != null) {
          final cloudDecks = await service.pullDecks(resolvedUserId);
          for (final d in cloudDecks) {
            try {
              final comboIds = (d['combo_ids'] as List?)?.cast<String>() ?? [];
              final deck = Deck(
                id: d['id'] as String,
                name: d['name'] as String,
                comboIds: comboIds,
                updatedAt: DateTime.tryParse(d['updated_at'] as String? ?? ''),
              );
              await deckSource.insertOrUpdateDeck(deck);
            } catch (_) {}
          }
        }

        // Pull and restore cloud tournaments
        final tournamentSource = _tournamentLocalDataSource;
        if (tournamentSource != null) {
          final cloudTournaments = await service.pullTournaments(resolvedUserId);
          for (final t in cloudTournaments) {
            try {
              await tournamentSource.saveTournament(t);
            } catch (_) {}
          }
        }
      }
    }

    final restoredProfile = UserProfile(
      id: resolvedUserId,
      deviceId: existing?.deviceId ?? _identityService.generateRawRecoveryCode(),
      nickname: resolvedNickname,
      recoveryCodeHash: hash,
      createdAt: DateTime.now().toUtc(),
      isGuest: false,
    );

    await _localDataSource.saveActiveProfile(restoredProfile);

    // Sync profile state
    if (service != null && service.isAvailable) {
      unawaited(
        service.syncProfile(
          id: restoredProfile.id,
          nickname: restoredProfile.nickname,
          recoveryCodeHash: restoredProfile.recoveryCodeHash,
        ),
      );
    }

    return true;
  }

  @override
  Future<void> logoutOrReset() => _localDataSource.clearActiveProfile();
}
