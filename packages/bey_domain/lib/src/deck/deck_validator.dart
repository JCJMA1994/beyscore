// Deck validator — validates 3on3 decks against official v12 rules.
//
// Pure function: no database, no network, no Flutter.
// Migrated from docs/deck_validator.dart.
//
// The rule that hurts most at the check-in table: NO piece can repeat
// between the 3 beys, even in a different color. Two DranSword (one black,
// one red) count as the SAME piece. The identity key is the catalog ID,
// NOT the inventory ID.

import 'package:fpdart/fpdart.dart';

enum DeckViolationKind {
  wrongBeyCount,
  duplicatePart,
  hallOfFameInSingles,
  incompleteBey,
  missingLeftLauncher,
}

class DeckViolation {
  const DeckViolation({
    required this.kind,
    required this.message,
    this.partId,
    this.partName,
    this.beyIndexes = const [],
  });

  final DeckViolationKind kind;
  final String message;
  final String? partId;
  final String? partName;

  /// Which beys (0, 1, 2) are involved. Lets the UI highlight them.
  final List<int> beyIndexes;
}

class DeckValidator {
  const DeckValidator();

  /// The only two CX lock chips the v12 rules allow to repeat, one of each.
  static const _duplicateExceptions = {
    'lockchip-ares',
    'lockchip-emperor',
    'lock-chip-ares',
    'lock-chip-emperor',
    'ares',
    'emperor',
  };

  /// Normalizes part identity keys for consistent duplicate detection.
  static String normalizeIdentityKey(String key) {
    return key.toLowerCase().trim().replaceAll(' ', '-').replaceAll('_', '-');
  }

  /// Validates a deck. [beys] is the lineup in combat order.
  Either<List<DeckViolation>, ValidDeck> validate(
    List<BeyBuild> beys, {
    required bool isSingles,
    required Set<String> hallOfFamePartIds,
    required bool ownsLeftLauncher,
  }) {
    final violations = <DeckViolation>[];

    if (beys.length != 3) {
      violations.add(DeckViolation(
        kind: DeckViolationKind.wrongBeyCount,
        message:
            'Un Deck 3on3 requiere exactamente 3 Beys armados. Tienes ${beys.length}.',
      ));
    }

    for (var i = 0; i < beys.length; i++) {
      if (!beys[i].isComplete) {
        violations.add(DeckViolation(
          kind: DeckViolationKind.incompleteBey,
          message: 'El Bey ${i + 1} está incompleto (falta Blade/MainBlade, Ratchet o Bit).',
          beyIndexes: [i],
        ));
      }
    }

    // --- duplicate parts check ---
    // Identity key = catalog ID, NOT inventory ID.
    final appearances = <String, List<int>>{};
    for (var i = 0; i < beys.length; i++) {
      for (final p in beys[i].parts) {
        final normKey = normalizeIdentityKey(p.identityKey);
        appearances.putIfAbsent(normKey, () => []).add(i);
      }
    }

    appearances.forEach((key, indices) {
      if (indices.length <= 1) return;
      // Exception: Ares and Emperor lock chips can appear up to twice across the 3 beys
      final isException = _duplicateExceptions.any((ex) => key.contains(ex));
      if (isException && indices.length == 2) return;

      final matchingPart = beys[indices.first]
          .parts
          .firstWhere((p) => normalizeIdentityKey(p.identityKey) == key);

      violations.add(DeckViolation(
        kind: DeckViolationKind.duplicatePart,
        message:
            '${matchingPart.name} se repite en los Beys ${indices.map((i) => i + 1).join(" y ")}. '
            'Las reglas oficiales v12 prohíben repetir piezas entre los 3 Beys (incluso en distinto color).',
        partId: key,
        partName: matchingPart.name,
        beyIndexes: indices,
      ));
    });

    // --- hall of fame check ---
    if (isSingles) {
      for (var i = 0; i < beys.length; i++) {
        for (final p in beys[i].parts) {
          final normKey = normalizeIdentityKey(p.identityKey);
          if (hallOfFamePartIds.map(normalizeIdentityKey).contains(normKey)) {
            violations.add(DeckViolation(
              kind: DeckViolationKind.hallOfFameInSingles,
              message:
                  '${p.name} es una pieza del Hall of Fame: prohibida en combate individual (1on1), '
                  'pero permitida en 3on3.',
              partId: p.identityKey,
              partName: p.name,
              beyIndexes: [i],
            ));
          }
        }
      }
    }

    // --- left launcher check ---
    if (!ownsLeftLauncher) {
      for (var i = 0; i < beys.length; i++) {
        if (beys[i].spinsLeft) {
          violations.add(DeckViolation(
            kind: DeckViolationKind.missingLeftLauncher,
            message:
                'El Bey ${i + 1} gira a la izquierda y requiere un lanzador oficial con marca L '
                '(BX-40 o BX-47).',
            beyIndexes: [i],
          ));
        }
      }
    }

    return violations.isEmpty ? Right(ValidDeck(beys)) : Left(violations);
  }
}

/// Type that can only be constructed through the validator.
/// If you hold a ValidDeck, it passed all checks.
class ValidDeck {
  const ValidDeck(this.beys);
  final List<BeyBuild> beys;
}

class BeyBuild {
  const BeyBuild({required this.parts, required this.spinsLeft});
  final List<PartRef> parts;
  final bool spinsLeft;

  /// A Bey is complete if it has either a standard Blade (BX/UX) OR
  /// a modular CX structure (LockChip + MainBlade + AssistBlade), plus Ratchet and Bit.
  bool get isComplete {
    final kinds = parts.map((p) => p.type).toSet();
    final hasBladeStructure = kinds.contains(PartKind.blade) ||
        (kinds.contains(PartKind.mainBlade) &&
            kinds.contains(PartKind.lockChip) &&
            kinds.contains(PartKind.assistBlade));

    return hasBladeStructure &&
        kinds.contains(PartKind.ratchet) &&
        kinds.contains(PartKind.bit);
  }
}

enum PartKind {
  blade,
  ratchet,
  bit,
  lockChip,
  mainBlade,
  assistBlade,
  overBlade,
  metalBlade,
}

class PartRef {
  const PartRef({
    required this.identityKey,
    required this.name,
    required this.type,
  });

  /// Identity for rules: same name = same piece, regardless of color
  /// or how many the user owns.
  final String identityKey;
  final String name;
  final PartKind type;
}
