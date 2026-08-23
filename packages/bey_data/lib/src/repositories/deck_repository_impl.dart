import 'dart:async';

import 'package:bey_domain/bey_domain.dart';

import '../datasources/deck_local_datasource.dart';
import '../datasources/identity_local_datasource.dart';
import '../sync/supabase_sync_service.dart';

/// Persistent repository for decks backed by Drift SQLite database + Supabase cloud sync.
class DeckRepositoryImpl implements DeckRepository {
  DeckRepositoryImpl(this._dataSource, [this._syncService, this._identitySource]);

  final DeckLocalDataSource _dataSource;
  final SupabaseSyncService? _syncService;
  final IdentityLocalDataSource? _identitySource;

  @override
  Stream<List<Deck>> watchAll() => _dataSource.watchDecks();

  @override
  Future<void> save(Deck deck) async {
    await _dataSource.insertOrUpdateDeck(deck);
    final service = _syncService;
    if (service != null && service.isAvailable) {
      final active = await _identitySource?.getActiveProfile();
      try {
        await service.pushDecks([deck], userId: active?.id);
      } catch (_) {}
    }
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.deleteDeck(id);
    final service = _syncService;
    if (service != null && service.isAvailable) {
      try {
        await service.deleteDeck(id);
      } catch (_) {}
    }
  }
}
