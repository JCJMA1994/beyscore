import 'dart:async';

import 'package:bey_domain/bey_domain.dart';

import '../datasources/combo_local_datasource.dart';
import '../datasources/identity_local_datasource.dart';
import '../sync/supabase_sync_service.dart';

/// Persistent repository for combos backed by Drift SQLite database + Supabase cloud sync.
class ComboRepositoryImpl implements ComboRepository {
  ComboRepositoryImpl(this._dataSource, [this._syncService, this._identitySource]);

  final ComboLocalDataSource _dataSource;
  final SupabaseSyncService? _syncService;
  final IdentityLocalDataSource? _identitySource;

  @override
  Stream<List<Combo>> watchAll() => _dataSource.watchCombos();

  @override
  Future<void> save(Combo combo) async {
    await _dataSource.insertOrUpdateCombo(combo);
    final service = _syncService;
    if (service != null && service.isAvailable) {
      final active = await _identitySource?.getActiveProfile();
      try {
        await service.pushCombos([combo], userId: active?.id);
      } catch (_) {}
    }
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.deleteCombo(id);
    final service = _syncService;
    if (service != null && service.isAvailable) {
      try {
        await service.deleteCombo(id);
      } catch (_) {}
    }
  }
}
