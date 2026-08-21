import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Horizontal gauge for stats (Attack, Defense, Stamina, Weight).
class StatBar extends StatelessWidget {
  const StatBar({
    required this.label,
    required this.value,
    this.maxValue = 100,
    this.color = AppColors.x,
    super.key,
  });

  final String label;
  final num value;
  final num maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mute,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toString(),
              style: AppTypography.mono.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.steel,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
