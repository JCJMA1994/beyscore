import 'part_type.dart';

/// Domain entity for a Beyblade X part.
///
/// Pure Dart. All stats are nullable: 15 parts still have no published data.
/// A null means "no data", not "zero". The UI must show absence explicitly
/// (CLAUDE.md section 10 — trap: "don't show 0 where data is missing").
class Part {
  const Part({
    required this.id,
    required this.name,
    required this.type,
    required this.system,
    this.code,
    this.beyType,
    this.spinDirection,
    this.attack,
    this.defense,
    this.stamina,
    this.weightG,
    this.weightMinG,
    this.weightMaxG,
    this.weightNote,
    this.heightMm,
    this.widthMm,
    this.contactPoints,
    this.heightDmm,
    this.heightDmmMax,
    this.weightClass,
    this.tipShape,
    this.gearTeeth,
    this.shaftWidth,
    this.productCode,
    this.hasbroAlias,
    this.metaTier,
    this.imageLocal,
    this.imageRemote,
    this.sets = const [],
  });

  final String id;
  final String name;
  final PartType type;
  final BeySystem system;
  final String? code; // bit short code: B, F, HN...

  /// NEVER derived from name. Always from the source. (section 11)
  final BeyType? beyType;

  /// Only 2 blades spin left; they require an L-marked launcher.
  final SpinDirection? spinDirection;

  // Stats — all nullable by design.
  final int? attack;
  final int? defense;
  final int? stamina;

  /// Exact weight when the source provides a single number.
  final double? weightG;

  /// Weight range for parts that vary by mold (e.g. Phoenix Wing).
  final double? weightMinG;
  final double? weightMaxG;
  final String? weightNote;

  final double? heightMm;
  final double? widthMm;
  final int? contactPoints;

  /// Height in tenths of mm. 60 = 6.0 mm. Divide by 10 to display.
  final int? heightDmm;
  final int? heightDmmMax; // switchable-height bits

  /// Weight class notation: "7-" light, "7=" medium, "7+" heavy.
  final String? weightClass;

  final String? tipShape; // flat | round | sharp | multi
  final int? gearTeeth; // more teeth = stronger X-Dash, less stamina
  final int? shaftWidth; // shaft diameter = burst resistance

  final String? productCode; // BX-03, UX-01...
  final String? hasbroAlias; // western name, included in search
  final String? metaTier; // S/A/B or null (null = no data, not "bad")

  final String? imageLocal;
  final String? imageRemote;
  final List<String> sets; // which products include this part
}
