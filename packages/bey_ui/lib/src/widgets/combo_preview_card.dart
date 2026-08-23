import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'part_image.dart';

/// Interactive combo performance preview card with real-time stats,
/// synergy score, tier badge, and blade artwork.
class ComboPreviewCard extends StatelessWidget {
  const ComboPreviewCard({
    required this.blade,
    required this.ratchet,
    required this.bit,
    this.lockChip,
    this.assistBlade,
    this.overBlade,
    this.evaluation,
    this.onSave,
    super.key,
  });

  final Part blade;
  final Part ratchet;
  final Part bit;
  final Part? lockChip;
  final Part? assistBlade;
  final Part? overBlade;
  final ComboEvaluation? evaluation;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final eval = evaluation ??
        const ComboStatsCalculator().evaluate(
          blade: blade,
          ratchet: ratchet,
          bit: bit,
          lockChip: lockChip,
          assistBlade: assistBlade,
          overBlade: overBlade,
        );

    final partsCode = '${blade.productCode ?? '—'} · ${ratchet.code ?? ratchet.name} · ${bit.code ?? bit.name}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF232838), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Preview Title + Tier Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANTEPRIMA COMBO',
                      style: AppTypography.mono.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                        color: const Color(0xFF7E8B9B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      blade.name.toUpperCase(),
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      partsCode,
                      style: AppTypography.mono.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '~ ${eval.dataSourceLabel}',
                      style: AppTypography.mono.copyWith(
                        fontSize: 9,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B0E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEAB308), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      eval.tier,
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFACC15),
                      ),
                    ),
                    Text(
                      'TIER',
                      style: AppTypography.mono.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: const Color(0xFFCA8A04),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Live Preview Center Area
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF090B10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1A1F2C)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  left: 12,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE PREVIEW',
                        style: AppTypography.mono.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular Blade Artwork
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.x.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: PartImage(
                      type: PartType.blade,
                      imageRemote: blade.imageRemote,
                      imageLocal: blade.imageLocal,
                      size: 96,
                      showBorder: false,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Stat Bars (ATK, DEF, STA, WGT)
          _buildStatBar(
            label: 'ATK',
            value: eval.attack,
            color: const Color(0xFFC8392B),
            percentage: (eval.attack / 120.0).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          _buildStatBar(
            label: 'DEF',
            value: eval.defense,
            color: const Color(0xFF378ADD),
            percentage: (eval.defense / 100.0).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          _buildStatBar(
            label: 'STA',
            value: eval.stamina,
            color: const Color(0xFF639922),
            percentage: (eval.stamina / 100.0).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          _buildStatBar(
            label: 'WGT',
            valueString: '${eval.weightG}g',
            color: const Color(0xFF6B7280),
            percentage: (eval.weightG / 55.0).clamp(0.0, 1.0),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF1E2433), height: 1),
          const SizedBox(height: 14),

          // 4. Footer Badges (Total Stats, Win Rate, Sinergia)
          Row(
            children: [
              Expanded(
                child: _buildFooterStat(
                  label: 'TOTAL STATS',
                  value: '${eval.totalStats}',
                  valueColor: Colors.white,
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFF1E2433)),
              Expanded(
                child: _buildFooterStat(
                  label: 'WIN RATE',
                  value: eval.winRate ?? 'N/D',
                  valueColor: eval.winRate != null ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFF1E2433)),
              Expanded(
                child: _buildFooterStat(
                  label: 'SINERGIA',
                  value: '${eval.synergyPercentage}%',
                  valueColor: const Color(0xFFEAB308),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    int? value,
    String? valueString,
    required Color color,
    required double percentage,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: AppTypography.mono.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2433),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 36,
          child: Text(
            valueString ?? '$value',
            textAlign: TextAlign.end,
            style: AppTypography.mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterStat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.displaySmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.mono.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
