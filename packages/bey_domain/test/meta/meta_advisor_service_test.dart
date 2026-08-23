import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('MetaAdvisorService Tests', () {
    const advisor = MetaAdvisorService();

    test('advises top meta configuration for Wizard Rod', () {
      const blade = Part(
        id: 'blade-wizardrod',
        name: 'Wizard Rod',
        type: PartType.blade,
        system: BeySystem.ux,
        beyType: BeyType.stamina,
        weightG: 35.5,
      );

      final advice = advisor.adviseForBlade(blade);
      expect(advice.bladeName, 'Wizard Rod');
      expect(advice.archetype, BeyType.stamina);
      expect(advice.estimatedTier, 'S+');
      expect(advice.estimatedWinrate, greaterThanOrEqualTo(70));
      expect(advice.recommendedRatchets.any((r) => r.partCode == '1-60'), isTrue);
      expect(advice.recommendedBits.any((b) => b.partCode == 'H'), isTrue);
    });

    test('advises top meta configuration for Shark Scale', () {
      const blade = Part(
        id: 'blade-sharkscale',
        name: 'Shark Scale',
        type: PartType.blade,
        system: BeySystem.ux,
        beyType: BeyType.attack,
        weightG: 36.2,
      );

      final advice = advisor.adviseForBlade(blade);
      expect(advice.bladeName, 'Shark Scale');
      expect(advice.archetype, BeyType.attack);
      expect(advice.estimatedTier, 'S+');
      expect(advice.recommendedRatchets.any((r) => r.partCode == '1-70'), isTrue);
      expect(advice.recommendedBits.any((b) => b.partCode == 'LR'), isTrue);
    });

    test('advises fallback archetype config for general blade', () {
      const blade = Part(
        id: 'blade-generic-attack',
        name: 'Custom Strike',
        type: PartType.blade,
        system: BeySystem.bx,
        beyType: BeyType.attack,
      );

      final advice = advisor.adviseForBlade(blade);
      expect(advice.archetype, BeyType.attack);
      expect(advice.recommendedRatchets.isNotEmpty, isTrue);
      expect(advice.recommendedBits.isNotEmpty, isTrue);
    });
  });
}
