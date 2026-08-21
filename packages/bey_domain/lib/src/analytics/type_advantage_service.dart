import '../catalog/part_type.dart';

/// Relationship outcome between two Beyblade archetypes.
enum AdvantageOutcome {
  advantage('VENTAJA TÁCTICA', 1),
  disadvantage('DESVENTAJA TÁCTICA', -1),
  neutral('ENFRENTAMIENTO NEUTRAL', 0);

  const AdvantageOutcome(this.label, this.weight);
  final String label;
  final int weight;
}

/// Tactical analysis report comparing two opposing Beyblade builds.
class MatchupAnalysis {
  const MatchupAnalysis({
    required this.playerType,
    required this.opponentType,
    required this.outcome,
    required this.tacticalTip,
  });

  final BeyType? playerType;
  final BeyType? opponentType;
  final AdvantageOutcome outcome;
  final String tacticalTip;
}

/// Domain service calculating tactical type matchups according to official Beyblade X mechanics.
class TypeAdvantageService {
  const TypeAdvantageService();

  MatchupAnalysis evaluateMatchup(BeyType? playerType, BeyType? opponentType) {
    if (playerType == null || opponentType == null) {
      return const MatchupAnalysis(
        playerType: null,
        opponentType: null,
        outcome: AdvantageOutcome.neutral,
        tacticalTip: 'Datos incompletos para diagnóstico de arquetipo.',
      );
    }

    if (playerType == opponentType) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.neutral,
        tacticalTip: 'Combate espejo: la precisión de lanzamiento y velocidad de entrada definirán la victoria.',
      );
    }

    // Official Rock-Paper-Scissors cycle: Attack > Stamina > Defense > Attack
    if (playerType == BeyType.attack && opponentType == BeyType.stamina) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.advantage,
        tacticalTip: 'Aprovecha el X-Dash temprano para forzar Over o Burst Finish antes de que se estabilice.',
      );
    }

    if (playerType == BeyType.stamina && opponentType == BeyType.defense) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.advantage,
        tacticalTip: 'Mantén el centro del estadio; tu inercia centrífuga superará la resistencia pasiva del rival.',
      );
    }

    if (playerType == BeyType.defense && opponentType == BeyType.attack) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.advantage,
        tacticalTip: 'Absorbe los impactos en la zona baja y permite que el atacante gaste su energía o sufra self-KO.',
      );
    }

    // Disadvantage scenarios
    if (playerType == BeyType.stamina && opponentType == BeyType.attack) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.disadvantage,
        tacticalTip: 'Lanza con leve inclinación para esquivar el primer impacto en la línea del X-Dash.',
      );
    }

    if (playerType == BeyType.defense && opponentType == BeyType.stamina) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.disadvantage,
        tacticalTip: 'Intenta un lanzamiento agresivo hacia el centro para desestabilizar su rotación al inicio.',
      );
    }

    if (playerType == BeyType.attack && opponentType == BeyType.defense) {
      return MatchupAnalysis(
        playerType: playerType,
        opponentType: opponentType,
        outcome: AdvantageOutcome.disadvantage,
        tacticalTip: 'Apunta a los rieles laterales para impactar en ángulo en vez de chocar frontalmente.',
      );
    }

    // Balance matchups
    return MatchupAnalysis(
      playerType: playerType,
      opponentType: opponentType,
      outcome: AdvantageOutcome.neutral,
      tacticalTip: 'Arquetipo Balance: ajusta tu ángulo de tiro según la postura ofensiva o defensiva del rival.',
    );
  }
}
