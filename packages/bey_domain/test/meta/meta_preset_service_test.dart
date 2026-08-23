import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('MetaPresetService Tests', () {
    const service = MetaPresetService();

    test('provides official popular meta presets', () {
      final presets = service.getPresets();
      expect(presets.isNotEmpty, isTrue);
      expect(presets.length, greaterThanOrEqualTo(3));

      final wizardRod = presets.firstWhere((p) => p.bladeId == 'wizard_rod');
      expect(wizardRod.ratchetId, '1-60');
      expect(wizardRod.bitId, 'hexa');
      expect(wizardRod.tier, 'S+');
      expect(wizardRod.archetype, 'Resistencia');
    });

    test('converts preset to valid Combo entity', () {
      final presets = service.getPresets();
      final phoenix = presets.firstWhere((p) => p.bladeId == 'phoenix_wing');
      final combo = phoenix.toCombo();

      expect(combo.name, phoenix.name);
      expect(combo.bladeId, 'phoenix_wing');
      expect(combo.ratchetId, '5-60');
      expect(combo.bitId, 'point');
    });
  });
}
