/// A single recorded solo spin benchmark test.
class SpinTestRecord {
  const SpinTestRecord({
    required this.id,
    required this.comboName,
    required this.durationMs,
    required this.launcherType,
    required this.recordedAt,
  });

  final String id;
  final String comboName;
  final int durationMs; // Duration in milliseconds
  final String launcherType; // e.g., 'Winder', 'String Launcher', 'Ripcord'
  final DateTime recordedAt;

  double get durationSeconds => durationMs / 1000.0;
}

/// Statistical summary of a Beyblade combo's stamina performance.
class SpinBenchmarkSummary {
  const SpinBenchmarkSummary({
    required this.comboName,
    required this.totalTests,
    required this.bestDurationMs,
    required this.averageDurationMs,
    required this.consistencyPercentage,
  });

  final String comboName;
  final int totalTests;
  final int bestDurationMs;
  final int averageDurationMs;
  final double consistencyPercentage; // 0.0 to 100.0%

  double get bestSeconds => bestDurationMs / 1000.0;
  double get averageSeconds => averageDurationMs / 1000.0;
}

/// Pure domain service calculating stamina benchmarks and personal bests.
class SpinBenchmarkService {
  const SpinBenchmarkService();

  SpinBenchmarkSummary summarizeComboTests({
    required String comboName,
    required List<SpinTestRecord> records,
  }) {
    final comboRecords = records.where((r) => r.comboName.trim().toLowerCase() == comboName.trim().toLowerCase()).toList();

    if (comboRecords.isEmpty) {
      return SpinBenchmarkSummary(
        comboName: comboName,
        totalTests: 0,
        bestDurationMs: 0,
        averageDurationMs: 0,
        consistencyPercentage: 0,
      );
    }

    var bestMs = 0;
    var sumMs = 0;

    for (final r in comboRecords) {
      sumMs += r.durationMs;
      if (r.durationMs > bestMs) {
        bestMs = r.durationMs;
      }
    }

    final avgMs = (sumMs / comboRecords.length).round();

    // Approximate consistency: ratio of avg to best
    final consistency = bestMs > 0 ? (avgMs / bestMs) * 100.0 : 100.0;

    return SpinBenchmarkSummary(
      comboName: comboName,
      totalTests: comboRecords.length,
      bestDurationMs: bestMs,
      averageDurationMs: avgMs,
      consistencyPercentage: consistency.clamp(0.0, 100.0),
    );
  }

  bool isPersonalBest({
    required String comboName,
    required int newDurationMs,
    required List<SpinTestRecord> existingRecords,
  }) {
    final comboRecords = existingRecords.where((r) => r.comboName.trim().toLowerCase() == comboName.trim().toLowerCase()).toList();
    if (comboRecords.isEmpty) return true;

    for (final r in comboRecords) {
      if (r.durationMs >= newDurationMs) {
        return false;
      }
    }
    return true;
  }
}
