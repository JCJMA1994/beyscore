import 'dart:convert';

import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

@DataClassName('DeckRow')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get comboIdsJson => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DeckLocalDataSource {
  DeckLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<List<Deck>> watchDecks() {
    return (_db.select(_db.decks)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch()
        .map((rows) => rows.map(toEntity).toList());
  }

  Future<List<Deck>> getDecks() async {
    final rows = await (_db.select(_db.decks)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
    return rows.map(toEntity).toList();
  }

  Future<Deck?> getDeckById(String id) async {
    final row = await (_db.select(_db.decks)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row != null ? toEntity(row) : null;
  }

  Future<void> insertOrUpdateDeck(Deck deck) {
    return _db.into(_db.decks).insertOnConflictUpdate(toCompanion(deck));
  }

  Future<void> deleteDeck(String id) {
    return (_db.delete(_db.decks)..where((r) => r.id.equals(id))).go();
  }

  static Deck toEntity(DeckRow row) {
    var parsedComboIds = <String>[];
    try {
      final decoded = jsonDecode(row.comboIdsJson);
      if (decoded is List) {
        parsedComboIds = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      parsedComboIds = [];
    }

    return Deck(
      id: row.id,
      name: row.name,
      comboIds: parsedComboIds,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static DecksCompanion toCompanion(Deck deck) {
    return DecksCompanion.insert(
      id: deck.id,
      name: deck.name,
      comboIdsJson: jsonEncode(deck.comboIds),
      createdAt: Value(deck.createdAt ?? DateTime.now()),
      updatedAt: Value(deck.updatedAt ?? DateTime.now()),
    );
  }
}
