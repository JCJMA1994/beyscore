import 'dart:convert';

import 'package:bey_data/bey_data.dart';
import 'package:bey_domain/bey_domain.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

class CatalogSeeder {
  CatalogSeeder(this._db);
  final AppDatabase _db;

  static const _assetPath = 'packages/bey_catalog/assets/data/beyblade_x_parts.json';
  static const _fallbackAssetPath = 'assets/data/beyblade_x_parts.json';

  /// Idempotent: safe to call on every app start.
  Future<void> seedIfNeeded({required int currentVersion}) async {
    String raw;
    try {
      raw = await rootBundle.loadString(_assetPath);
    } catch (_) {
      raw = await rootBundle.loadString(_fallbackAssetPath);
    }
    final doc = json.decode(raw) as Map<String, dynamic>;
    final version = doc['schemaVersion'] as int;

    if (version <= currentVersion) return;

    final rows = (doc['parts'] as List)
        .cast<Map<String, dynamic>>()
        .map(toCompanion)
        .toList();

    // Single transaction: 239 batch inserts ~40ms on a budget phone.
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.parts, rows);
    });
  }

  static PartsCompanion toCompanion(Map<String, dynamic> p) {
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
      contactPoints: Value(asInt(p['contactPoints'])),
      heightDmm: Value(asInt(p['heightDmm'])),
      heightDmmMax: Value(asInt(p['heightDmmMax'])),
      weightClass: Value(p['weightClass'] as String?),
      code: Value(p['code'] as String?),
      tipShape: Value(p['tipShape'] as String?),
      gearTeeth: Value(asInt(p['gearTeeth'])),
      shaftWidth: Value(asInt(p['shaftWidth'])),
      productCode: Value(p['productCode'] as String?),
      hasbroAlias: Value(p['hasbroAlias'] as String?),
      metaTier: Value(p['metaTier'] as String?),
      imageLocal: Value(
        p['imageThumbLocal'] != null
            ? 'assets/parts/${p['imageThumbLocal']}'
            : null,
      ),
      imageRemote: Value(
        p['imageThumb'] as String? ?? p['image'] as String?,
      ),
    );
  }

  static PartType _partType(String s) => switch (s) {
        'BLADE' => PartType.blade,
        'RATCHET' => PartType.ratchet,
        'BIT' => PartType.bit,
        'LOCK_CHIP' => PartType.lockChip,
        'MAIN_BLADE' => PartType.mainBlade,
        'ASSIST_BLADE' => PartType.assistBlade,
        'OVER_BLADE' => PartType.overBlade,
        'METAL_BLADE' => PartType.metalBlade,
        'ACCESSORY' => PartType.accessory,
        _ => throw ArgumentError('Unknown part type: $s'),
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
