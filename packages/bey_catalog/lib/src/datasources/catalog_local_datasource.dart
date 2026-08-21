import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';

class CatalogLocalDataSource {
  CatalogLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<List<PartRow>> watchByType(PartType type) {
    return (_db.select(_db.parts)
          ..where((r) => r.type.equalsValue(type))
          ..orderBy([(r) => OrderingTerm(expression: r.name)]))
        .watch();
  }

  Future<List<PartRow>> getByType(PartType type) {
    return (_db.select(_db.parts)
          ..where((r) => r.type.equalsValue(type))
          ..orderBy([(r) => OrderingTerm(expression: r.name)]))
        .get();
  }

  Future<PartRow?> getById(String id) {
    return (_db.select(_db.parts)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  static Part toEntity(PartRow row) {
    return Part(
      id: row.id,
      name: row.name,
      type: row.type,
      system: row.system,
      code: row.code,
      beyType: row.beyType,
      spinDirection: row.spinDirection,
      attack: row.attack,
      defense: row.defense,
      stamina: row.stamina,
      weightG: row.weightG,
      weightMinG: row.weightMinG,
      weightMaxG: row.weightMaxG,
      weightNote: row.weightNote,
      heightMm: row.heightMm,
      widthMm: row.widthMm,
      contactPoints: row.contactPoints,
      heightDmm: row.heightDmm,
      heightDmmMax: row.heightDmmMax,
      weightClass: row.weightClass,
      tipShape: row.tipShape,
      gearTeeth: row.gearTeeth,
      shaftWidth: row.shaftWidth,
      productCode: row.productCode,
      hasbroAlias: row.hasbroAlias,
      metaTier: row.metaTier,
      imageLocal: row.imageLocal,
      imageRemote: row.imageRemote,
    );
  }

  /// Search by name, bit code, product code, or Hasbro alias.
  Stream<List<PartRow>> search(String q, {PartType? type}) {
    final term = '%${q.trim()}%';
    return (_db.select(_db.parts)
          ..where((r) {
            var cond = r.name.like(term) |
                r.code.like(term) |
                r.productCode.like(term) |
                r.hasbroAlias.like(term);
            if (type != null) cond = cond & r.type.equalsValue(type);
            return cond;
          })
          ..limit(50))
        .watch();
  }
}
