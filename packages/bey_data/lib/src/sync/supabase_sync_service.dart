import 'dart:async';
import 'dart:convert';

import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/env.dart';

class SupabaseSyncService {
  SupabaseSyncService();

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isAvailable => _client != null && Env.hasSupabaseConfig;
  String? get currentUserId => _client?.auth.currentUser?.id;

  /// Ensures user is anonymously authenticated in Supabase for cloud sync.
  Future<String?> ensureAuthenticated() async {
    final client = _client;
    if (client == null) {
      debugPrint('[SupabaseSync] Supabase client is not initialized.');
      return null;
    }

    final session = client.auth.currentSession;
    if (session != null) return session.user.id;

    try {
      final res = await client.auth.signInAnonymously();
      debugPrint('[SupabaseSync] Signed in anonymously as: ${res.user?.id}');
      return res.user?.id;
    } catch (e) {
      debugPrint('[SupabaseSync] Failed to sign in anonymously: $e');
      return null;
    }
  }

  /// Syncs user profile in Supabase, preserving original profile ID to avoid duplicate accounts.
  Future<bool> syncProfile({
    String? id,
    required String nickname,
    String? recoveryCodeHash,
    String? avatarUrl,
  }) async {
    final client = _client;
    if (client == null) return false;

    // 1. If recovery code hash exists, check if account already exists in Supabase
    var targetId = id;
    if (recoveryCodeHash != null && recoveryCodeHash.isNotEmpty) {
      try {
        final existing = await client
            .from('profiles')
            .select('id')
            .eq('recovery_code_hash', recoveryCodeHash)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          targetId = existing['id'] as String;
          debugPrint('[SupabaseSync] Reusing existing cloud profile ID: $targetId');
        }
      } catch (_) {}
    }

    targetId ??= await ensureAuthenticated();
    if (targetId == null) return false;

    try {
      await client.from('profiles').upsert({
        'id': targetId,
        'nickname': nickname,
        'recovery_code_hash': recoveryCodeHash,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('[SupabaseSync] Profile synced OK: $nickname ($targetId)');
      return true;
    } catch (e) {
      debugPrint('[SupabaseSync] Error syncing profile: $e');
      return false;
    }
  }

  /// Pushes local combos to Supabase.
  Future<bool> pushCombos(List<Combo> combos, {String? userId}) async {
    final client = _client;
    if (client == null || combos.isEmpty) return false;

    var targetUserId = userId ?? client.auth.currentSession?.user.id;
    targetUserId ??= await ensureAuthenticated();

    try {
      final rows = combos.map((c) => {
            'id': c.id,
            'user_id': targetUserId ?? 'anon',
            'name': c.name,
            'blade_id': c.bladeId,
            'ratchet_id': c.ratchetId,
            'bit_id': c.bitId,
            'lock_chip_id': c.lockChipId,
            'assist_blade_id': c.assistBladeId,
            'system': c.system.index,
            'calculated_weight': c.calculatedWeight,
            'updated_at': DateTime.now().toIso8601String(),
          }).toList();

      await client.from('combos').upsert(rows);
      debugPrint('[SupabaseSync] Pushed ${rows.length} combos to Supabase.');
      return true;
    } catch (e) {
      debugPrint('[SupabaseSync] Error pushing combos: $e');
      return false;
    }
  }

  /// Pushes local decks to Supabase.
  Future<bool> pushDecks(List<Deck> decks, {String? userId}) async {
    final client = _client;
    if (client == null || decks.isEmpty) return false;

    var targetUserId = userId ?? client.auth.currentSession?.user.id;
    targetUserId ??= await ensureAuthenticated();

    try {
      final rows = decks.map((d) => {
            'id': d.id,
            'user_id': targetUserId ?? 'anon',
            'name': d.name,
            'combo_ids': d.comboIds,
            'updated_at': DateTime.now().toIso8601String(),
          }).toList();

      await client.from('decks').upsert(rows);
      debugPrint('[SupabaseSync] Pushed ${rows.length} decks to Supabase.');
      return true;
    } catch (e) {
      debugPrint('[SupabaseSync] Error pushing decks: $e');
      return false;
    }
  }

  /// Fetches a profile matching a recovery code hash.
  Future<Map<String, dynamic>?> fetchProfileByRecoveryHash(String recoveryCodeHash) async {
    final client = _client;
    if (client == null) return null;

    try {
      final res = await client
          .from('profiles')
          .select()
          .eq('recovery_code_hash', recoveryCodeHash)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  /// Pulls all cloud combos for a user.
  Future<List<Map<String, dynamic>>> pullCombos(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('combos')
          .select()
          .eq('user_id', userId);
      return (res as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Pulls all cloud decks for a user.
  Future<List<Map<String, dynamic>>> pullDecks(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('decks')
          .select()
          .eq('user_id', userId);
      return (res as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Pushes local tournaments to Supabase.
  Future<bool> pushTournaments(List<Tournament> tournaments, {String? userId}) async {
    final completedTournaments = tournaments.where((t) => t.status == TournamentStatus.completed).toList();
    if (completedTournaments.isEmpty) return true;

    final client = _client;
    if (client == null) return false;

    try {
      final rows = completedTournaments.map((t) {
        return {
          'id': t.id,
          'name': t.name,
          'organizer_id': userId ?? (t.organizerIds.isNotEmpty ? t.organizerIds.first : null),
          'tier': t.tier.name.toUpperCase(),
          'age_division': t.ageDivision.name,
          'status': t.status.name,
          'participants': t.participants,
          'seed': t.seed,
          'rounds': t.rounds
              .map((r) => {
                    'roundNumber': r.roundIndex,
                    'name': r.name,
                    'matchups': r.matchups
                        .map((m) => {
                              'id': m.matchId,
                              'tableNumber': m.tableNumber,
                              'playerA': m.playerAName,
                              'playerB': m.playerBName,
                              'winner': m.winnerId,
                              'scoreA': m.scoreA,
                              'scoreB': m.scoreB,
                              'isCompleted': m.isCompleted,
                              'status': m.status.name,
                            })
                        .toList(),
                  })
              .toList(),
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await client.from('tournaments').upsert(rows);
      debugPrint('[SupabaseSync] Pushed ${rows.length} completed tournaments to Supabase.');
      return true;
    } catch (e) {
      debugPrint('[SupabaseSync] Error pushing tournaments: $e');
      return false;
    }
  }

  /// Deletes a tournament from Supabase.
  Future<bool> deleteTournament(String id) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client.from('tournaments').delete().eq('id', id);
      debugPrint('[SupabaseSync] Deleted tournament $id from Supabase.');
      return true;
    } catch (e) {
      debugPrint('[SupabaseSync] Error deleting tournament: $e');
      return false;
    }
  }

  /// Pulls completed tournaments for a user / organizer from Supabase.
  Future<List<Tournament>> pullTournaments(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('tournaments')
          .select()
          .eq('organizer_id', userId)
          .eq('status', 'completed');

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map((r) => _mapRowToTournament(r, fallbackUserId: userId)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Pulls completed tournaments from Supabase (for match history and global rankings).
  Future<List<Tournament>> pullActiveTournaments() async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('tournaments')
          .select()
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(50);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map(_mapRowToTournament).toList();
    } catch (e) {
      debugPrint('[SupabaseSync] Error pulling active tournaments: $e');
      return [];
    }
  }

  Tournament _mapRowToTournament(Map<String, dynamic> row, {String? fallbackUserId}) {
    final tierStr = row['tier'] as String? ?? 'G3';
    final tier = TournamentTier.values.firstWhere(
      (e) => e.name.toUpperCase() == tierStr.toUpperCase(),
      orElse: () => TournamentTier.g3,
    );

    final ageStr = row['age_division'] as String? ?? 'OPEN';
    final age = AgeDivision.values.firstWhere(
      (e) => e.name.toUpperCase() == ageStr.toUpperCase(),
      orElse: () => AgeDivision.open,
    );

    final statusStr = row['status'] as String? ?? 'REGISTRATION';
    final status = TournamentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == statusStr.toUpperCase(),
      orElse: () => TournamentStatus.registration,
    );

    final participants = (row['participants'] as List?)?.cast<String>() ?? [];

    final rawRounds = (row['rounds'] as List?) ?? [];
    final rounds = <BracketRound>[];
    for (final r in rawRounds) {
      if (r is Map) {
        final rawMatchups = (r['matchups'] as List?) ?? [];
        final matchups = <Matchup>[];
        for (final m in rawMatchups) {
          if (m is Map) {
            final statusMatchupStr = m['status'] as String? ?? 'pending';
            final mStatus = MatchupStatus.values.firstWhere(
              (s) => s.name == statusMatchupStr,
              orElse: () => MatchupStatus.pending,
            );
            matchups.add(
              Matchup(
                matchId: m['matchId'] as String? ?? '',
                playerAId: m['playerAId'] as String? ?? '',
                playerAName: m['playerAName'] as String? ?? '',
                playerBId: m['playerBId'] as String?,
                playerBName: m['playerBName'] as String?,
                tableNumber: m['tableNumber'] as int?,
                winnerId: m['winnerId'] as String?,
                scoreA: (m['scoreA'] as int?) ?? 0,
                scoreB: (m['scoreB'] as int?) ?? 0,
                isCompleted: (m['isCompleted'] as bool?) ?? false,
                status: mStatus,
              ),
            );
          }
        }
        rounds.add(
          BracketRound(
            roundIndex: (r['roundIndex'] as int?) ?? 0,
            name: r['name'] as String? ?? '',
            matchups: matchups,
          ),
        );
      }
    }

    final orgId = (row['organizer_id'] as String?) ?? fallbackUserId ?? 'organizer-cloud';
    return Tournament(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Torneo BeyScore',
      organizerIds: [orgId],
      tier: tier,
      ageDivision: age,
      status: status,
      seed: row['seed'] as int?,
      championName: row['champion_name'] as String?,
      participants: participants,
      rounds: rounds,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Publishes a tournament to Supabase for multi-player cloud joining.
  Future<bool> publishTournament({
    required Tournament tournament,
    required String code,
  }) async {
    final client = _client;
    if (client == null) return false;

    final userId = await ensureAuthenticated();
    if (userId == null) return false;

    try {
      await client.from('tournaments').upsert({
        'id': tournament.id,
        'organizer_id': userId,
        'code': code.toUpperCase().trim(),
        'name': tournament.name,
        'tier': tournament.tier.name.toUpperCase(),
        'age_division': tournament.ageDivision.name.toUpperCase(),
        'status': tournament.status.name.toUpperCase(),
        'seed': tournament.seed,
        'rounds': jsonDecode(jsonEncode(tournament.rounds)),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Joins a remote tournament using an access code.
  Future<bool> joinTournament({
    required String code,
    required String nickname,
    String? deckId,
  }) async {
    final client = _client;
    if (client == null) return false;

    final userId = await ensureAuthenticated();
    if (userId == null) return false;

    try {
      final res = await client
          .from('tournaments')
          .select('id')
          .eq('code', code.toUpperCase().trim())
          .maybeSingle();

      if (res == null) return false;
      final tournamentId = res['id'] as String;

      await client.from('tournament_participants').upsert({
        'tournament_id': tournamentId,
        'user_id': userId,
        'nickname': nickname,
        'deck_id': deckId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Realtime stream of tournament participants.
  Stream<List<Map<String, dynamic>>> watchTournamentParticipants(
    String tournamentId,
  ) {
    final client = _client;
    if (client == null) return const Stream.empty();

    return client
        .from('tournament_participants')
        .stream(primaryKey: ['id'])
        .eq('tournament_id', tournamentId);
  }

  /// Pushes local owned parts inventory to Supabase.
  Future<bool> pushUserInventory(List<String> partIds) async {
    final client = _client;
    if (client == null) return false;

    final userId = await ensureAuthenticated();
    if (userId == null) return false;

    try {
      final rows = partIds
          .map((id) => {
                'user_id': userId,
                'part_id': id,
                'is_owned': true,
                'quantity': 1,
                'updated_at': DateTime.now().toIso8601String(),
              })
          .toList();

      if (rows.isNotEmpty) {
        await client.from('user_inventory').upsert(rows);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pulls owned parts inventory for a user from Supabase.
  Future<List<String>> pullUserInventory(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('user_inventory')
          .select('part_id')
          .eq('user_id', userId)
          .eq('is_owned', true);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map((row) => row['part_id'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  /// Pushes spin stamina benchmarks to Supabase.
  Future<bool> pushSpinBenchmarks(List<SpinTestRecord> records) async {
    final client = _client;
    if (client == null || records.isEmpty) return false;

    final userId = await ensureAuthenticated();
    if (userId == null) return false;

    try {
      final rows = records
          .map((r) => {
                'id': r.id,
                'user_id': userId,
                'combo_name': r.comboName,
                'duration_ms': r.durationMs,
                'launcher_type': r.launcherType,
                'recorded_at': r.recordedAt.toIso8601String(),
              })
          .toList();

      await client.from('spin_benchmarks').upsert(rows);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pulls spin stamina benchmarks for a user from Supabase.
  Future<List<SpinTestRecord>> pullSpinBenchmarks(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('spin_benchmarks')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false);

      final rows = (res as List).cast<Map<String, dynamic>>();
      return rows.map((row) {
        return SpinTestRecord(
          id: row['id'] as String,
          comboName: row['combo_name'] as String,
          durationMs: (row['duration_ms'] as num).toInt(),
          launcherType: row['launcher_type'] as String? ?? 'Winder Launcher',
          recordedAt: DateTime.tryParse(row['recorded_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Pushes user tactical preferences to Supabase.
  Future<bool> pushPreferences({
    required String announcerLanguage,
    required String handedness,
    bool hapticsEnabled = true,
    bool audioEnabled = true,
  }) async {
    final client = _client;
    if (client == null) return false;

    final userId = await ensureAuthenticated();
    if (userId == null) return false;

    try {
      await client.from('player_preferences').upsert({
        'user_id': userId,
        'announcer_language': announcerLanguage,
        'preferred_handedness': handedness,
        'haptics_enabled': hapticsEnabled,
        'audio_enabled': audioEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pulls user tactical preferences from Supabase.
  Future<Map<String, dynamic>?> pullPreferences(String userId) async {
    final client = _client;
    if (client == null) return null;

    try {
      final res = await client
          .from('player_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return res;
    } catch (_) {
      return null;
    }
  }

  /// Pushes tournament trophies and podium finishes to Supabase.
  Future<bool> pushTrophies(List<Map<String, dynamic>> trophies) async {
    final client = _client;
    if (client == null || trophies.isEmpty) return false;

    final userId = await ensureAuthenticated();
    if (userId == null) return false;

    try {
      final rows = trophies
          .map((t) => {
                'id': t['id'],
                'user_id': userId,
                'tournament_name': t['tournament_name'],
                'tier': t['tier'] ?? 'G3',
                'rank_position': t['rank_position'],
                'total_participants': t['total_participants'] ?? 0,
                'awarded_at': t['awarded_at'] ?? DateTime.now().toIso8601String(),
              })
          .toList();

      await client.from('tournament_trophies').upsert(rows);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pulls tournament trophies for a user from Supabase.
  Future<List<Map<String, dynamic>>> pullTrophies(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final res = await client
          .from('tournament_trophies')
          .select()
          .eq('user_id', userId)
          .order('awarded_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
