import 'dart:math';

/// Deterministic Fisher-Yates shuffle with a saved seed.
///
/// Pure function. The seed is stored so the bracket can be
/// regenerated identically for verification.
class SeededShuffle {
  const SeededShuffle._();

  /// Shuffles [list] in-place using the given [seed] and returns it.
  static List<T> shuffle<T>(List<T> list, int seed) {
    final rng = Random(seed);
    for (var i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }
}
