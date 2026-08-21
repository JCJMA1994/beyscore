/// A 3on3 deck: 3 beys in combat order.
///
/// Pure Dart domain entity.
class Deck {
  const Deck({
    required this.id,
    required this.name,
    required this.comboIds,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;

  /// Exactly 3 combo IDs in combat order.
  final List<String> comboIds;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Deck copyWith({
    String? id,
    String? name,
    List<String>? comboIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      comboIds: comboIds ?? this.comboIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
