import 'package:bey_domain/bey_domain.dart';
import 'package:test/test.dart';

void main() {
  group('DeckValidator Tests (Official Rules v12)', () {
    const validator = DeckValidator();

    test('validates legal 3on3 deck with 9 distinct parts', () {
      const bey1 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-dransword', name: 'DranSword', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-3-60', name: '3-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-flat', name: 'Flat', type: PartKind.bit),
        ],
      );

      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-hellsscythe', name: 'HellsScythe', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      const bey3 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-wizardrod', name: 'WizardRod', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-5-60', name: '5-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-point', name: 'Point', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [bey1, bey2, bey3],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: true,
      );

      expect(result.isRight(), isTrue);
    });

    test('detects duplicate blade even if user calls it different color', () {
      const bey1 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-dransword', name: 'DranSword', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-3-60', name: '3-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-flat', name: 'Flat', type: PartKind.bit),
        ],
      );

      // Bey 2 uses DranSword black version (same identityKey!)
      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-dransword', name: 'DranSword', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      const bey3 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-wizardrod', name: 'WizardRod', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-5-60', name: '5-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-point', name: 'Point', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [bey1, bey2, bey3],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (violations) {
          expect(violations.any((v) => v.kind == DeckViolationKind.duplicatePart), isTrue);
          final dup = violations.firstWhere((v) => v.kind == DeckViolationKind.duplicatePart);
          expect(dup.partId, 'blade-dransword');
          expect(dup.beyIndexes, [0, 1]);
        },
        (_) => fail('Should have failed duplicate check'),
      );
    });

    test('detects missing left launcher when a bey spins left', () {
      const beyLeft = BeyBuild(
        spinsLeft: true, // Left Spin Blade (e.g. Cobalt Dragoon)
        parts: [
          PartRef(identityKey: 'blade-cobaltdragoon', name: 'CobaltDragoon', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-2-60', name: '2-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-cyclone', name: 'Cyclone', type: PartKind.bit),
        ],
      );

      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-hellsscythe', name: 'HellsScythe', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      const bey3 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-wizardrod', name: 'WizardRod', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-5-60', name: '5-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-point', name: 'Point', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [beyLeft, bey2, bey3],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: false, // User does NOT have L launcher
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (violations) {
          expect(violations.any((v) => v.kind == DeckViolationKind.missingLeftLauncher), isTrue);
        },
        (_) => fail('Should have failed left launcher check'),
      );
    });

    test('detects wrong bey count in 3on3 format', () {
      const bey1 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-dransword', name: 'DranSword', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-3-60', name: '3-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-flat', name: 'Flat', type: PartKind.bit),
        ],
      );

      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-hellsscythe', name: 'HellsScythe', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      // Only 2 beys provided for 3on3
      final result = validator.validate(
        [bey1, bey2],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (violations) {
          expect(violations.any((v) => v.kind == DeckViolationKind.wrongBeyCount), isTrue);
        },
        (_) => fail('Should fail with wrongBeyCount'),
      );
    });

    test('detects incomplete bey missing required part', () {
      const incompleteBey = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-dransword', name: 'DranSword', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-3-60', name: '3-60', type: PartKind.ratchet),
          // Missing bit!
        ],
      );

      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-hellsscythe', name: 'HellsScythe', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      const bey3 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-wizardrod', name: 'WizardRod', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-5-60', name: '5-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-point', name: 'Point', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [incompleteBey, bey2, bey3],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (violations) {
          expect(violations.any((v) => v.kind == DeckViolationKind.incompleteBey), isTrue);
        },
        (_) => fail('Should fail with incompleteBey'),
      );
    });

    test('allows official v12 exception for CX LockChips Ares and Emperor up to twice', () {
      const bey1 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'lockchip-ares', name: 'LockChip Ares', type: PartKind.lockChip),
          PartRef(identityKey: 'mainblade-dran', name: 'MainBlade Dran', type: PartKind.mainBlade),
          PartRef(identityKey: 'assistblade-jaggy', name: 'AssistBlade Jaggy', type: PartKind.assistBlade),
          PartRef(identityKey: 'ratchet-3-60', name: '3-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-flat', name: 'Flat', type: PartKind.bit),
        ],
      );

      // Bey 2 repeats LockChip Ares (allowed by official v12 rule!)
      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'lockchip-ares', name: 'LockChip Ares', type: PartKind.lockChip),
          PartRef(identityKey: 'mainblade-hells', name: 'MainBlade Hells', type: PartKind.mainBlade),
          PartRef(identityKey: 'assistblade-bumper', name: 'AssistBlade Bumper', type: PartKind.assistBlade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      const bey3 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-wizardrod', name: 'WizardRod', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-5-60', name: '5-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-point', name: 'Point', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [bey1, bey2, bey3],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: true,
      );

      expect(result.isRight(), isTrue);
    });

    test('rejects 3 repetitions of Ares lockchip (max allowed is 2)', () {
      const bey1 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'lockchip-ares', name: 'LockChip Ares', type: PartKind.lockChip),
          PartRef(identityKey: 'mainblade-dran', name: 'MainBlade Dran', type: PartKind.mainBlade),
          PartRef(identityKey: 'assistblade-jaggy', name: 'AssistBlade Jaggy', type: PartKind.assistBlade),
          PartRef(identityKey: 'ratchet-3-60', name: '3-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-flat', name: 'Flat', type: PartKind.bit),
        ],
      );

      const bey2 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'lockchip-ares', name: 'LockChip Ares', type: PartKind.lockChip),
          PartRef(identityKey: 'mainblade-hells', name: 'MainBlade Hells', type: PartKind.mainBlade),
          PartRef(identityKey: 'assistblade-bumper', name: 'AssistBlade Bumper', type: PartKind.assistBlade),
          PartRef(identityKey: 'ratchet-4-60', name: '4-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      const bey3 = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'lockchip-ares', name: 'LockChip Ares', type: PartKind.lockChip),
          PartRef(identityKey: 'mainblade-wizard', name: 'MainBlade Wizard', type: PartKind.mainBlade),
          PartRef(identityKey: 'assistblade-wheel', name: 'AssistBlade Wheel', type: PartKind.assistBlade),
          PartRef(identityKey: 'ratchet-5-60', name: '5-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-point', name: 'Point', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [bey1, bey2, bey3],
        isSingles: false,
        hallOfFamePartIds: {},
        ownsLeftLauncher: true,
      );

      expect(result.isLeft(), isTrue);
    });

    test('detects Hall of Fame banned part in singles format', () {
      const bey = BeyBuild(
        spinsLeft: false,
        parts: [
          PartRef(identityKey: 'blade-wizardrod', name: 'WizardRod', type: PartKind.blade),
          PartRef(identityKey: 'ratchet-9-60', name: '9-60', type: PartKind.ratchet),
          PartRef(identityKey: 'bit-ball', name: 'Ball', type: PartKind.bit),
        ],
      );

      final result = validator.validate(
        [bey],
        isSingles: true,
        hallOfFamePartIds: {'blade-wizardrod'},
        ownsLeftLauncher: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (violations) {
          expect(violations.any((v) => v.kind == DeckViolationKind.hallOfFameInSingles), isTrue);
        },
        (_) => fail('Should fail with hallOfFameInSingles violation'),
      );
    });
  });
}
