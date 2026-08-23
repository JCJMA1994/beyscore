import '../catalog/part.dart';
import '../catalog/part_type.dart';

/// Result of evaluating a Beyblade X combo's performance metrics.
class ComboEvaluation {
  const ComboEvaluation({
    required this.attack,
    required this.defense,
    required this.stamina,
    required this.weightG,
    required this.totalStats,
    required this.synergyPercentage,
    required this.tier,
    this.winRate,
    required this.dataSourceLabel,
  });

  final int attack;
  final int defense;
  final int stamina;
  final double weightG;
  final int totalStats;
  final int synergyPercentage; // Range 40% - 99%
  final String tier; // 'S+', 'S', 'A+', 'A', 'B+', 'B', 'C'
  final String? winRate; // e.g. '68%' or null / 'N/D'
  final String dataSourceLabel;
}

/// Domain calculator for combo aggregate stats, synergy, and competitive tier ratings.
class ComboStatsCalculator {
  const ComboStatsCalculator();

  static const Map<String, double> _tierScores = {
    'S+': 6.0,
    'S': 5.0,
    'A+': 4.0,
    'A': 3.0,
    'B+': 2.0,
    'B': 1.0,
    'C': 0.0,
  };

  /// Calculates the aggregate performance metrics of a combo.
  ComboEvaluation evaluate({
    required Part blade,
    required Part ratchet,
    required Part bit,
    Part? lockChip,
    Part? assistBlade,
    Part? overBlade,
  }) {
    // 1. Base Stat Aggregation
    final atk = (blade.attack ?? _estimateStat(blade, 'atk')) +
        (ratchet.attack ?? _estimateStat(ratchet, 'atk')) +
        (bit.attack ?? _estimateStat(bit, 'atk')) +
        (assistBlade?.attack ?? _estimateAssistStat(assistBlade, 'atk')) +
        (overBlade?.attack ?? 0);

    final def = (blade.defense ?? _estimateStat(blade, 'def')) +
        (ratchet.defense ?? _estimateStat(ratchet, 'def')) +
        (bit.defense ?? _estimateStat(bit, 'def')) +
        (assistBlade?.defense ?? _estimateAssistStat(assistBlade, 'def')) +
        (overBlade?.defense ?? 0);

    final sta = (blade.stamina ?? _estimateStat(blade, 'sta')) +
        (ratchet.stamina ?? _estimateStat(ratchet, 'sta')) +
        (bit.stamina ?? _estimateStat(bit, 'sta')) +
        (assistBlade?.stamina ?? _estimateAssistStat(assistBlade, 'sta')) +
        (overBlade?.stamina ?? 0);

    final bladeWeight = blade.weightG ??
        ((blade.weightMinG != null && blade.weightMaxG != null)
            ? (blade.weightMinG! + blade.weightMaxG!) / 2.0
            : 32.0);

    final ratchetWeight = ratchet.weightG ?? 6.5;
    final bitWeight = bit.weightG ?? 2.3;
    final lockChipWeight = lockChip?.weightG ?? _estimateLockChipWeight(lockChip);
    final assistWeight = assistBlade?.weightG ?? _estimateAssistWeight(assistBlade);
    final overWeight = overBlade?.weightG ?? (overBlade != null ? 3.5 : 0.0);

    final totalWeight =
        bladeWeight + ratchetWeight + bitWeight + lockChipWeight + assistWeight + overWeight;
    final totalStats = atk + def + sta;

    // 2. Synergy Calculation
    final synergy = _calculateSynergy(
      blade: blade,
      ratchet: ratchet,
      bit: bit,
      assistBlade: assistBlade,
      atk: atk,
      def: def,
      sta: sta,
    );

    // 3. Tier Rating Calculation
    final (tier, winRate, label) = _resolveTierAndWinRate(
      blade: blade,
      ratchet: ratchet,
      bit: bit,
    );

    return ComboEvaluation(
      attack: atk,
      defense: def,
      stamina: sta,
      weightG: double.parse(totalWeight.toStringAsFixed(1)),
      totalStats: totalStats,
      synergyPercentage: synergy,
      tier: tier,
      winRate: winRate,
      dataSourceLabel: label,
    );
  }

  double _estimateLockChipWeight(Part? lockChip) {
    if (lockChip == null) return 0;
    final name = lockChip.name.toLowerCase();
    if (name.contains('valkyrie') || name.contains('戰神')) return 6;
    if (name.contains('emperor') || name.contains('帝王')) return 5;
    return 1.8;
  }

  double _estimateAssistWeight(Part? assistBlade) {
    if (assistBlade == null) return 0;
    final name = assistBlade.name.toLowerCase();
    if (name.contains('turn') || name == 't') return 5.5;
    if (name.contains('bumper') || name == 'b') return 5.2;
    if (name.contains('heavy') || name == 'h') return 5;
    if (name.contains('jaggy') || name == 'j') return 4.85;
    return 4.5;
  }

  int _estimateAssistStat(Part? assist, String stat) {
    if (assist == null) return 0;
    final name = assist.name.toLowerCase();
    if (name.contains('jaggy') || name == 'j' || name.contains('assault') || name == 'a') {
      return stat == 'atk' ? 15 : 5;
    }
    if (name.contains('bumper') || name == 'b' || name.contains('turn') || name == 't') {
      return stat == 'def' ? 15 : 5;
    }
    if (name.contains('wheel') || name == 'w' || name.contains('round') || name == 'r') {
      return stat == 'sta' ? 15 : 5;
    }
    return 10;
  }

  int _calculateSynergy({
    required Part blade,
    required Part ratchet,
    required Part bit,
    Part? assistBlade,
    required int atk,
    required int def,
    required int sta,
  }) {
    var score = 50;
    final type = blade.beyType ?? _inferType(blade);

    switch (type) {
      case BeyType.attack:
        if ((ratchet.attack ?? 0) > 12) score += 12;
        if ((bit.attack ?? 0) > 18) score += 14;
        if ((bit.attack ?? 0) > 25) score += 8;
        if (assistBlade != null) {
          final an = assistBlade.name.toLowerCase();
          if (an.contains('jaggy') || an == 'j' || an.contains('assault') || an == 'a') {
            score += 10;
          }
        }
      case BeyType.defense:
        if ((ratchet.defense ?? 0) > 12) score += 12;
        if ((bit.defense ?? 0) > 18) score += 14;
        if ((bit.defense ?? 0) > 25) score += 8;
        if (assistBlade != null) {
          final an = assistBlade.name.toLowerCase();
          if (an.contains('bumper') || an == 'b' || an.contains('turn') || an == 't') {
            score += 10;
          }
        }
      case BeyType.stamina:
        if ((ratchet.stamina ?? 0) > 14) score += 12;
        if ((bit.stamina ?? 0) > 18) score += 14;
        if ((bit.stamina ?? 0) > 25) score += 8;
        if (assistBlade != null) {
          final an = assistBlade.name.toLowerCase();
          if (an.contains('wheel') || an == 'w' || an.contains('round') || an == 'r') {
            score += 10;
          }
        }
      case BeyType.balance:
        score += 8;
        if ((ratchet.attack ?? 0) > 10 && (ratchet.stamina ?? 0) > 10) score += 8;
        if ((bit.attack ?? 0) > 12 && (bit.stamina ?? 0) > 12) score += 8;
        if (assistBlade != null) score += 6;
    }

    return score.clamp(40, 99);
  }

  (String tier, String? winRate, String label) _resolveTierAndWinRate({
    required Part blade,
    required Part ratchet,
    required Part bit,
  }) {
    // Known top meta combos with high competitive sample size
    final exactKey =
        '${blade.name.toLowerCase()}|${(ratchet.code ?? ratchet.name).toLowerCase()}|${(bit.code ?? bit.name).toLowerCase()}';

    if (exactKey.contains('wizard rod') && exactKey.contains('9-60') && exactKey.contains('b')) {
      return ('S+', '72%', 'DATI WBO REALI');
    }
    if (exactKey.contains('phoenix wing') && exactKey.contains('5-60') && exactKey.contains('p')) {
      return ('S+', '69%', 'DATI WBO REALI');
    }
    if (exactKey.contains('shark scale') && exactKey.contains('1-70') && exactKey.contains('lr')) {
      return ('S+', '67%', 'DATI WBO REALI');
    }
    if (exactKey.contains('shark edge') && exactKey.contains('1-60') && exactKey.contains('lf')) {
      return ('S', '65%', 'DATI WBO REALI');
    }
    if (exactKey.contains('dran buster') && exactKey.contains('1-60') && exactKey.contains('a')) {
      return ('S', '64%', 'DATI WBO REALI');
    }

    // Weighted estimate based on individual piece tiers
    final bTierScore = _tierScores[blade.metaTier ?? 'B+'] ?? 2.0;
    final rTierScore = _tierScores[ratchet.metaTier ?? 'B'] ?? 1.5;
    final btTierScore = _tierScores[bit.metaTier ?? 'B'] ?? 1.5;

    final weightedScore = (bTierScore * 0.60) + (rTierScore * 0.20) + (btTierScore * 0.20);
    final calculatedTier = _scoreToTier(weightedScore);

    return (
      '~$calculatedTier',
      null, // N/D
      'STIMA DA COMBO WBO PARZIALI',
    );
  }

  String _scoreToTier(double n) {
    if (n >= 5.5) return 'S+';
    if (n >= 4.5) return 'S';
    if (n >= 3.5) return 'A+';
    if (n >= 2.5) return 'A';
    if (n >= 1.5) return 'B+';
    if (n >= 0.5) return 'B';
    return 'C';
  }

  int _estimateStat(Part part, String stat) {
    final type = part.beyType ?? _inferType(part);
    return switch (type) {
      BeyType.attack => stat == 'atk' ? 65 : stat == 'def' ? 25 : 30,
      BeyType.defense => stat == 'def' ? 65 : stat == 'sta' ? 45 : 20,
      BeyType.stamina => stat == 'sta' ? 70 : stat == 'def' ? 40 : 15,
      BeyType.balance => stat == 'atk' ? 40 : stat == 'def' ? 40 : 40,
    };
  }

  BeyType _inferType(Part part) {
    final n = part.name.toLowerCase();
    if (n.contains('sword') || n.contains('shark') || n.contains('wing') || n.contains('dagger') || n.contains('buster')) {
      return BeyType.attack;
    }
    if (n.contains('shield') || n.contains('chain') || n.contains('rhino') || n.contains('golem')) {
      return BeyType.defense;
    }
    if (n.contains('rod') || n.contains('scythe') || n.contains('wizard') || n.contains('mirage')) {
      return BeyType.stamina;
    }
    return BeyType.balance;
  }
}
