import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ComboStatsCalculator Tests', () {
    const calculator = ComboStatsCalculator();

    test('evaluates Shark Scale 9-60 E combo stats accurately', () {
      const blade = Part(
        id: 'shark_scale',
        name: 'Shark Scale',
        type: PartType.blade,
        system: BeySystem.bx,
        productCode: 'BX-34',
        beyType: BeyType.attack,
        attack: 82,
        defense: 42,
        stamina: 54,
        weightG: 34.3,
        metaTier: 'S+',
      );

      const ratchet = Part(
        id: '9-60',
        name: '9-60',
        code: '9-60',
        type: PartType.ratchet,
        system: BeySystem.bx,
        attack: 12,
        defense: 11,
        stamina: 10,
        weightG: 6.4,
        metaTier: 'S',
      );

      const bit = Part(
        id: 'elevate',
        name: 'Elevate',
        code: 'E',
        type: PartType.bit,
        system: BeySystem.bx,
        attack: 20,
        defense: 10,
        stamina: 15,
        weightG: 3.3,
        metaTier: 'A',
      );

      final eval = calculator.evaluate(
        blade: blade,
        ratchet: ratchet,
        bit: bit,
      );

      expect(eval.attack, equals(114));
      expect(eval.defense, equals(63));
      expect(eval.stamina, equals(79));
      expect(eval.totalStats, equals(256));
      expect(eval.weightG, equals(44.0));
      expect(eval.synergyPercentage, greaterThanOrEqualTo(50));
      expect(eval.tier, startsWith('~'));
    });

    test('identifies top official WBO meta combos', () {
      const blade = Part(
        id: 'wizard_rod',
        name: 'Wizard Rod',
        type: PartType.blade,
        system: BeySystem.ux,
        beyType: BeyType.stamina,
        attack: 22,
        defense: 70,
        stamina: 88,
        weightG: 35.5,
        metaTier: 'S+',
      );

      const ratchet = Part(
        id: '9-60',
        name: '9-60',
        code: '9-60',
        type: PartType.ratchet,
        system: BeySystem.bx,
        attack: 10,
        defense: 15,
        stamina: 18,
        weightG: 6.4,
        metaTier: 'S',
      );

      const bit = Part(
        id: 'ball',
        name: 'Ball',
        code: 'B',
        type: PartType.bit,
        system: BeySystem.bx,
        attack: 8,
        defense: 20,
        stamina: 30,
        weightG: 2.2,
        metaTier: 'S',
      );

      final eval = calculator.evaluate(
        blade: blade,
        ratchet: ratchet,
        bit: bit,
      );

      expect(eval.tier, equals('S+'));
      expect(eval.winRate, equals('72%'));
      expect(eval.dataSourceLabel, equals('DATI WBO REALI'));
      expect(eval.synergyPercentage, greaterThan(80));
    });
  });
}
