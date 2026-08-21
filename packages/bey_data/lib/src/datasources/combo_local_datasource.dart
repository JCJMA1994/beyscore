import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';

@DataClassName('ComboRow')
class Combos extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bladeId => text()();
  TextColumn get ratchetId => text()();
  TextColumn get bitId => text()();
  TextColumn get lockChipId => text().nullable()();
  TextColumn get assistBladeId => text().nullable()();
  IntColumn get system => intEnum<BeySystem>().withDefault(const Constant(0))();
  RealColumn get calculatedWeight => real().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ComboLocalDataSource {
  ComboLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<List<Combo>> watchCombos() {
    return (_db.select(_db.combos)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch()
        .map((rows) => rows.map(toEntity).toList());
  }

  Future<List<Combo>> getCombos() async {
    final rows = await (_db.select(_db.combos)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
    return rows.map(toEntity).toList();
  }

  Future<Combo?> getComboById(String id) async {
    final row = await (_db.select(_db.combos)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row != null ? toEntity(row) : null;
  }

  Future<void> insertOrUpdateCombo(Combo combo) {
    return _db.into(_db.combos).insertOnConflictUpdate(toCompanion(combo));
  }

  Future<void> deleteCombo(String id) {
    return (_db.delete(_db.combos)..where((r) => r.id.equals(id))).go();
  }

  static Combo toEntity(ComboRow row) {
    return Combo(
      id: row.id,
      name: row.name,
      bladeId: row.bladeId,
      ratchetId: row.ratchetId,
      bitId: row.bitId,
      lockChipId: row.lockChipId,
      assistBladeId: row.assistBladeId,
      system: row.system,
      calculatedWeight: row.calculatedWeight,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static CombosCompanion toCompanion(Combo combo) {
    return CombosCompanion.insert(
      id: combo.id,
      name: combo.name,
      bladeId: combo.bladeId,
      ratchetId: combo.ratchetId,
      bitId: combo.bitId,
      lockChipId: Value(combo.lockChipId),
      assistBladeId: Value(combo.assistBladeId),
      system: Value(combo.system),
      calculatedWeight: Value(combo.calculatedWeight),
      createdAt: Value(combo.createdAt ?? DateTime.now()),
      updatedAt: Value(combo.updatedAt ?? DateTime.now()),
    );
  }
}
