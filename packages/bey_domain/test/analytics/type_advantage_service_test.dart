import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('TypeAdvantageService Tests', () {
    const service = TypeAdvantageService();

    test('calculates rock-paper-scissors advantage correctly', () {
      final attackVsStamina = service.evaluateMatchup(BeyType.attack, BeyType.stamina);
      expect(attackVsStamina.outcome, AdvantageOutcome.advantage);

      final staminaVsDefense = service.evaluateMatchup(BeyType.stamina, BeyType.defense);
      expect(staminaVsDefense.outcome, AdvantageOutcome.advantage);

      final defenseVsAttack = service.evaluateMatchup(BeyType.defense, BeyType.attack);
      expect(defenseVsAttack.outcome, AdvantageOutcome.advantage);
    });

    test('calculates disadvantage scenarios correctly', () {
      final staminaVsAttack = service.evaluateMatchup(BeyType.stamina, BeyType.attack);
      expect(staminaVsAttack.outcome, AdvantageOutcome.disadvantage);

      final attackVsDefense = service.evaluateMatchup(BeyType.attack, BeyType.defense);
      expect(attackVsDefense.outcome, AdvantageOutcome.disadvantage);
    });

    test('calculates mirror and balance matchups as neutral', () {
      final mirror = service.evaluateMatchup(BeyType.attack, BeyType.attack);
      expect(mirror.outcome, AdvantageOutcome.neutral);

      final balance = service.evaluateMatchup(BeyType.balance, BeyType.stamina);
      expect(balance.outcome, AdvantageOutcome.neutral);
    });
  });
}
