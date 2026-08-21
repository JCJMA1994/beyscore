import '../catalog/part_type.dart';

/// A user-assembled combo: blade + ratchet + bit (or CX parts).
///
/// Pure Dart domain entity. The combo weight is a calculation that
/// returns null if any piece is missing weight data — never sums zeros.
class Combo {
  const Combo({
    required this.id,
    required this.name,
    required this.bladeId,
    required this.ratchetId,
    required this.bitId,
    this.lockChipId,
    this.assistBladeId,
    this.system = BeySystem.bx,
    this.calculatedWeight,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String bladeId;
  final String ratchetId;
  final String bitId;
  final String? lockChipId; // CX combos have lock chips
  final String? assistBladeId; // CX assist blades
  final BeySystem system;
  final double? calculatedWeight;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Combo copyWith({
    String? id,
    String? name,
    String? bladeId,
    String? ratchetId,
    String? bitId,
    String? lockChipId,
    String? assistBladeId,
    BeySystem? system,
    double? calculatedWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Combo(
      id: id ?? this.id,
      name: name ?? this.name,
      bladeId: bladeId ?? this.bladeId,
      ratchetId: ratchetId ?? this.ratchetId,
      bitId: bitId ?? this.bitId,
      lockChipId: lockChipId ?? this.lockChipId,
      assistBladeId: assistBladeId ?? this.assistBladeId,
      system: system ?? this.system,
      calculatedWeight: calculatedWeight ?? this.calculatedWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
