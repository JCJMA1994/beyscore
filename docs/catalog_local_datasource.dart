// features/catalog/data/datasources/catalog_local_datasource.dart
//
// Carga el catalogo de piezas a Drift en el primer arranque.
// El JSON va empaquetado en el APK: la app nunca pide la red para esto,
// coherente con la decision offline-first de la arquitectura.
//
// pubspec.yaml:
//   flutter:
//     assets:
//       - assets/data/beyblade_x_parts.json
//       - assets/parts/          # imagenes descargadas por el scraper

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

// ---------------------------------------------------------------- tablas

// CX tiene mas subtipos de los que parecia: ademas de lock chip, main y assist,
// existen over blade y metal blade.
enum PartType { blade, ratchet, bit, lockChip, mainBlade, assistBlade, overBlade, metalBlade }
enum BeySystem { bx, ux, cx }
enum SpinDirection { right, left }
enum BeyType { attack, defense, stamina, balance }

@DataClassName('PartRow')
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<PartType>()();
  IntColumn get system => intEnum<BeySystem>()();

  // stats — nullable a proposito: 15 piezas del catalogo aun no tienen datos
  // publicados. Un 0 mentiria; un null se puede mostrar como "sin datos".
  IntColumn get attack => integer().nullable()();
  IntColumn get defense => integer().nullable()();
  IntColumn get stamina => integer().nullable()();
  // El peso NO es un numero: Phoenix Wing pesa 37.9-38.45 g en molde 1/2 y
  // 38.95-39.1 g en molde 3. Guardar un escalar seria inventar precision.
  RealColumn get weightG => real().nullable()();      // exacto, si la fuente lo da
  RealColumn get weightMinG => real().nullable()();   // rango, si varia por molde
  RealColumn get weightMaxG => real().nullable()();
  TextColumn get weightNote => text().nullable()();
  RealColumn get heightMm => real().nullable()();
  RealColumn get widthMm => real().nullable()();

  IntColumn get beyType => intEnum<BeyType>().nullable()();
  IntColumn get spinDirection => intEnum<SpinDirection>().nullable()();

  // Puntos de contacto. En ratchets se puede leer del codigo (3-60 -> 3), pero
  // M-85 es metal y no tiene numero, asi que el dato viene de la fuente.
  IntColumn get contactPoints => integer().nullable()();
  BoolColumn get isMetal => boolean().withDefault(const Constant(false))();

  // Altura en decimas de milimetro. 60 dmm = 6.0 mm.
  IntColumn get heightDmm => integer().nullable()();
  IntColumn get heightDmmMax => integer().nullable()();   // bits de altura conmutable
  TextColumn get weightClass => text().nullable()();      // "7-" / "7=" / "7+"
  BoolColumn get isSimplified => boolean().withDefault(const Constant(false))();

  // especificos de bit
  TextColumn get code => text().nullable()();          // F, GN, HN...
  TextColumn get tipShape => text().nullable()();      // flat | round | sharp | multi

  // El compromiso central de Beyblade X: mas dientes = Xtreme Dash mas fuerte,
  // pero gasta mas stamina.
  IntColumn get gearTeeth => integer().nullable()();
  IntColumn get shaftWidth => integer().nullable()();  // resistencia al burst

  // NO se deduce del nombre. Ver seccion 11 de la arquitectura: adivinarlo
  // por el nombre acertaba el 32% de las veces.
  IntColumn get beyTypeCol => intEnum<BeyType>().nullable()();

  IntColumn get contactPointsBlade => integer().nullable()();
  TextColumn get productCode => text().nullable()();
  TextColumn get hasbroAlias => text().nullable()();   // "Scythe Incendio"

  // tier competitivo segun torneos WBO. Null = sin datos, no "malo".
  TextColumn get metaTier => text().nullable()();

  // imagen: preferimos la copia local; la URL remota es solo respaldo
  TextColumn get imageLocal => text().nullable()();
  TextColumn get imageRemote => text().nullable()();

  // el catalogo lo manda el servidor, no el usuario -> no lleva outbox
  IntColumn get catalogVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------- carga

class CatalogSeeder {
  CatalogSeeder(this._db);
  final GeneratedDatabase _db;

  static const _assetPath = 'assets/data/beyblade_x_parts.json';

  /// Idempotente: se puede llamar en cada arranque sin costo.
  /// Solo reescribe si cambio schemaVersion del JSON.
  Future<void> seedIfNeeded({required int currentVersion}) async {
    final raw = await rootBundle.loadString(_assetPath);
    final doc = json.decode(raw) as Map<String, dynamic>;
    final version = doc['schemaVersion'] as int;

    if (version <= currentVersion) return;

    final filas = (doc['parts'] as List)
        .cast<Map<String, dynamic>>()
        .map(_toCompanion)
        .toList();

    // Una sola transaccion. 138 inserts sueltos tardan ~2 s en un telefono
    // barato; en batch son ~40 ms.
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.parts as TableInfo, filas);
    });
  }

  static PartsCompanion _toCompanion(Map<String, dynamic> p) {
    double? asDouble(Object? v) => v == null ? null : (v as num).toDouble();
    int? asInt(Object? v) => v == null ? null : (v as num).toInt();

    return PartsCompanion.insert(
      id: p['id'] as String,
      name: p['name'] as String,
      type: _partType(p['type'] as String),
      system: _system(p['system'] as String?),
      attack: Value(asInt(p['attack'])),
      defense: Value(asInt(p['defense'])),
      stamina: Value(asInt(p['stamina'])),
      weightG: Value(asDouble(p['weightG'])),
      weightMinG: Value(asDouble(p['weightMinG'])),
      weightMaxG: Value(asDouble(p['weightMaxG'])),
      weightNote: Value(p['note'] as String?),
      heightMm: Value(asDouble(p['heightMm'])),
      widthMm: Value(asDouble(p['widthMm'])),
      beyType: Value(_beyType(p['beyType'] as String?)),
      spinDirection: Value(_spin(p['spinDirection'] as String?)),
      spikes: Value(asInt(p['spikes'])),
      code: Value(p['code'] as String?),
      movement: Value(p['movement'] as String?),
      hasGear: Value(p['hasGear'] as bool? ?? false),
      burstResistance: Value(asInt(p['burstResistance'])),
      metaTier: Value(p['metaTier'] as String?),
      // el scraper escribe imageThumbLocal cuando descarga; si no, cae al remoto
      imageLocal: Value(_local(p['imageThumbLocal'] as String?)),
      imageRemote: Value(p['imageThumb'] as String?),
    );
  }

  static String? _local(String? rel) => rel == null ? null : 'assets/parts/$rel';

  static PartType _partType(String s) => switch (s) {
        'BLADE' => PartType.blade,
        'RATCHET' => PartType.ratchet,
        'BIT' => PartType.bit,
        'LOCK_CHIP' => PartType.lockChip,
        'MAIN_BLADE' => PartType.mainBlade,
        'ASSIST_BLADE' => PartType.assistBlade,
        _ => throw ArgumentError('tipo de pieza desconocido: $s'),
      };

  static BeySystem _system(String? s) => switch (s) {
        'UX' => BeySystem.ux,
        'CX' => BeySystem.cx,
        _ => BeySystem.bx,
      };

  static BeyType? _beyType(String? s) => switch (s) {
        'attack' => BeyType.attack,
        'defense' => BeyType.defense,
        'stamina' => BeyType.stamina,
        'balance' => BeyType.balance,
        _ => null,
      };

  static SpinDirection? _spin(String? s) => switch (s) {
        'LEFT' => SpinDirection.left,
        'RIGHT' => SpinDirection.right,
        _ => null,
      };
}

// ---------------------------------------------------------------- consultas

class CatalogLocalDataSource {
  CatalogLocalDataSource(this._db);
  final GeneratedDatabase _db;

  /// Stream: la UI se suscribe y Drift le avisa. Nunca un future suelto.
  Stream<List<PartRow>> watchByType(PartType type) {
    final t = _db.parts as Parts;
    return (_db.select(t)
          ..where((r) => r.type.equalsValue(type))
          ..orderBy([(r) => OrderingTerm(expression: r.name)]))
        .watch();
  }

  /// Busqueda por nombre, codigo de bit ("HN"), codigo de producto ("BX-23")
  /// o nombre occidental de Hasbro ("Scythe Incendio" encuentra HellsScythe).
  ///
  /// Ese ultimo campo importa mas de lo que parece: quien compra cajas de
  /// Hasbro solo conoce ese nombre, y sin el la busqueda le devuelve vacio.
  Stream<List<PartRow>> search(String q, {PartType? type}) {
    final t = _db.parts as Parts;
    final term = '%${q.trim()}%';
    return (_db.select(t)
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

  /// Peso de un combo, como RANGO.
  ///
  /// Devuelve null si alguna pieza no tiene peso publicado. Sumar ceros
  /// mostraria "34.2 g" para un combo cuyo peso real se desconoce, y el
  /// usuario no tendria como saber que el numero es falso.
  Future<WeightRange?> comboWeight(List<String> partIds) async {
    final t = _db.parts as Parts;
    final filas = await (_db.select(t)..where((r) => r.id.isIn(partIds))).get();
    if (filas.length != partIds.length) return null;

    var min = 0.0, max = 0.0;
    var exacto = true;
    for (final f in filas) {
      final lo = f.weightG ?? f.weightMinG;
      final hi = f.weightG ?? f.weightMaxG;
      if (lo == null || hi == null) return null;   // dato faltante -> sin resultado
      if (f.weightG == null) exacto = false;
      min += lo;
      max += hi;
    }
    return WeightRange(min: min, max: max, isExact: exacto);
  }

  /// Combos top que el usuario YA puede armar con su inventario.
  /// La interseccion vive en domain/services/buildability_service.dart;
  /// aqui solo se leen las piezas que posee.
  Stream<List<PartRow>> watchOwned() {
    final t = _db.parts as Parts;
    return (_db.select(t)..where((r) => r.metaTier.isNotNull())).watch();
  }
}

class WeightRange {
  const WeightRange({required this.min, required this.max, required this.isExact});
  final double min;
  final double max;

  /// false = alguna pieza solo publica rango (varia por molde).
  final bool isExact;

  /// "34.67 g" o "37.9 - 39.1 g". Nunca un promedio: promediar un rango
  /// vuelve a inventar la precision que el rango existia para evitar.
  String format() => isExact || min == max
      ? '${min.toStringAsFixed(2)} g'
      : '${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)} g';
}
