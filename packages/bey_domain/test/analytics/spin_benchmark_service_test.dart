import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('SpinBenchmarkService Tests', () {
    const service = SpinBenchmarkService();

    final now = DateTime.now();
    final records = [
      SpinTestRecord(
        id: 'r1',
        comboName: 'WizardRod 9-60B',
        durationMs: 78500, // 78.5s
        launcherType: 'Winder Launcher',
        recordedAt: now.subtract(const Duration(days: 2)),
      ),
      SpinTestRecord(
        id: 'r2',
        comboName: 'WizardRod 9-60B',
        durationMs: 82100, // 82.1s
        launcherType: 'Winder Launcher',
        recordedAt: now.subtract(const Duration(days: 1)),
      ),
      SpinTestRecord(
        id: 'r3',
        comboName: 'WizardRod 9-60B',
        durationMs: 80000, // 80.0s
        launcherType: 'String Launcher',
        recordedAt: now,
      ),
    ];

    test('calculates personal best and average accurately', () {
      final summary = service.summarizeComboTests(
        comboName: 'WizardRod 9-60B',
        records: records,
      );

      expect(summary.totalTests, 3);
      expect(summary.bestDurationMs, 82100);
      expect(summary.averageDurationMs, 80200);
      expect(summary.bestSeconds, 82.1);
      expect(summary.consistencyPercentage, greaterThan(90.0));
    });

    test('detects personal best condition correctly', () {
      final isNewPb = service.isPersonalBest(
        comboName: 'WizardRod 9-60B',
        newDurationMs: 85000,
        existingRecords: records,
      );
      expect(isNewPb, isTrue);

      final notPb = service.isPersonalBest(
        comboName: 'WizardRod 9-60B',
        newDurationMs: 81000,
        existingRecords: records,
      );
      expect(notPb, isFalse);
    });
  });
}
