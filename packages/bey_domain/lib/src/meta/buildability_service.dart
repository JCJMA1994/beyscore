/// Answers "what top combos can you build with what you own?"
///
/// Pure domain service. Intersection of user inventory x top combos.
class BuildabilityService {
  const BuildabilityService();

  /// Returns combo IDs that the user can fully assemble from their inventory.
  List<String> buildable({
    required Set<String> ownedPartIds,
    required Map<String, List<String>> comboPartMap,
  }) {
    return comboPartMap.entries
        .where((e) => e.value.every(ownedPartIds.contains))
        .map((e) => e.key)
        .toList();
  }
}
