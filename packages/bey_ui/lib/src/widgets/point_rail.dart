import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Point rail widget displaying score progression up to [targetPoints].
///
/// Designed for quick glance recognition from distance (table mode).
class PointRail extends StatelessWidget {
  const PointRail({
    required this.score,
    required this.targetPoints,
    required this.accentColor,
    this.playerName = '',
    this.isWinner = false,
    super.key,
  });

  final int score;
  final int targetPoints;
  final Color accentColor;
  final String playerName;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWinner ? accentColor : AppColors.line,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerName.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    playerName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isWinner)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'WIN',
                      style: AppTypography.mono.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(targetPoints, (index) {
              final isAchieved = index < score;
              return Expanded(
                child: Container(
                  height: 14,
                  margin: EdgeInsets.only(right: index < targetPoints - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isAchieved ? accentColor : AppColors.steel,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isAchieved ? accentColor : AppColors.line,
                      width: 1,
                    ),
                    boxShadow: isAchieved
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
