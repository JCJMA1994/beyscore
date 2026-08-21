// features/deck/domain/services/deck_validator.dart
//
// Valida un deck 3on3 contra las reglas oficiales v12 (marzo 2026).
//
// Funcion pura: sin base de datos, sin red, sin Flutter. Se testea con
// un mapa de piezas y nada mas.
//
// La regla que casi nadie implementa: NINGUNA pieza puede repetirse entre
// los 3 beys, y dos piezas del mismo nombre en distinto color cuentan como
// la MISMA pieza. Un jugador con dos Dran Sword (uno negro, uno rojo) no
// puede usar los dos. Se descubre en el chequeo previo del torneo, cuando
// ya es tarde.

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

  /// Qué beys del deck (0, 1, 2) están implicados. Permite señalarlos en la UI
  /// en vez de dar un error genérico que el usuario no sabe dónde arreglar.
  final List<int> beyIndexes;
}

class DeckValidator {
  const DeckValidator();

  /// Los dos únicos lock chips CX que la regla v12 permite repetir, uno de cada.
  static const _duplicateExceptions = {
    'lockchip-ares',
    'lockchip-emperor',
  };

  /// Valida un deck. [beys] es la alineación en orden de combate.
  /// [isSingles] cambia si se permiten piezas de salón de la fama.
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
        message: 'Un deck 3on3 lleva exactamente 3 beys. Tienes ${beys.length}.',
      ));
    }

    for (var i = 0; i < beys.length; i++) {
      if (!beys[i].isComplete) {
        violations.add(DeckViolation(
          kind: DeckViolationKind.incompleteBey,
          message: 'Al bey ${i + 1} le falta alguna pieza.',
          beyIndexes: [i],
        ));
      }
    }

    // --- piezas repetidas -------------------------------------------------
    // Clave de identidad: el `identityKey` de la pieza, NO su id de inventario.
    // Dos Dran Sword de distinto color comparten identityKey, y la regla los
    // trata como la misma pieza aunque el usuario tenga dos ejemplares.
    final apariciones = <String, List<int>>{};
    for (var i = 0; i < beys.length; i++) {
      for (final p in beys[i].parts) {
        apariciones.putIfAbsent(p.identityKey, () => []).add(i);
      }
    }

    apariciones.forEach((clave, indices) {
      if (indices.length <= 1) return;
      if (_duplicateExceptions.contains(clave) && indices.length == 2) return;

      final nombre = beys[indices.first]
          .parts
          .firstWhere((p) => p.identityKey == clave)
          .name;

      violations.add(DeckViolation(
        kind: DeckViolationKind.duplicatePart,
        message: '$nombre está en los beys ${indices.map((i) => i + 1).join(" y ")}. '
            'Las piezas no pueden repetirse, ni siquiera en otro color.',
        partId: clave,
        partName: nombre,
        beyIndexes: indices,
      ));
    });

    // --- salón de la fama --------------------------------------------------
    if (isSingles) {
      for (var i = 0; i < beys.length; i++) {
        for (final p in beys[i].parts) {
          if (hallOfFamePartIds.contains(p.identityKey)) {
            violations.add(DeckViolation(
              kind: DeckViolationKind.hallOfFameInSingles,
              message: '${p.name} es pieza de salón de la fama: no vale en '
                  'combate individual, pero sí en 3on3.',
              partId: p.identityKey,
              partName: p.name,
              beyIndexes: [i],
            ));
          }
        }
      }
    }

    // --- lanzador de giro izquierdo ---------------------------------------
    // Derivación legítima: es una definición física, no una inferencia.
    // Un bey de giro izquierdo no encaja en un lanzador derecho.
    if (!ownsLeftLauncher) {
      for (var i = 0; i < beys.length; i++) {
        if (beys[i].spinsLeft) {
          violations.add(DeckViolation(
            kind: DeckViolationKind.missingLeftLauncher,
            message: 'El bey ${i + 1} gira a la izquierda y necesita un lanzador '
                'con marca L (BX-40 o BX-47).',
            beyIndexes: [i],
          ));
        }
      }
    }

    return violations.isEmpty
        ? Right(ValidDeck(beys))
        : Left(violations);
  }
}

/// Tipo que solo se puede construir pasando por el validador.
/// Si tienes un ValidDeck, es legal — no hay que volver a comprobarlo.
class ValidDeck {
  const ValidDeck(this.beys);
  final List<BeyBuild> beys;
}

class BeyBuild {
  const BeyBuild({required this.parts, required this.spinsLeft});
  final List<PartRef> parts;
  final bool spinsLeft;

  bool get isComplete {
    final tipos = parts.map((p) => p.type).toSet();
    return tipos.contains(PartKind.blade) &&
        tipos.contains(PartKind.ratchet) &&
        tipos.contains(PartKind.bit);
  }
}

enum PartKind { blade, ratchet, bit, lockChip, mainBlade, assistBlade, overBlade, metalBlade }

class PartRef {
  const PartRef({
    required this.identityKey,
    required this.name,
    required this.type,
  });

  /// Identidad a efectos de reglas: mismo nombre = misma pieza, sin importar
  /// el color ni cuántos ejemplares tenga el usuario.
  final String identityKey;
  final String name;
  final PartKind type;
}
