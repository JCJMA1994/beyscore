/// A combo's position in the competitive meta tier list.
class TierEntry {
  const TierEntry({
    required this.comboId,
    required this.tier,
    this.notes,
  });

  final String comboId;

  /// S/A/B or null (null = no data, not "bad").
  final String? tier;
  final String? notes;
}
