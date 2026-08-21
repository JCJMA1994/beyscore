import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Banner shown when a match outcome or score has an active dispute.
class DisputeBanner extends StatelessWidget {
  const DisputeBanner({
    required this.message,
    this.onResolve,
    super.key,
  });

  final String message;
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dranzer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        border: Border.all(color: AppColors.dranzer.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.dranzer, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onResolve != null)
            TextButton(
              onPressed: onResolve,
              child: Text(
                'RESOLVE',
                style: AppTypography.mono.copyWith(
                  color: AppColors.dranzer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
