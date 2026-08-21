import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Small visual badge/dot showing whether local changes are synced with Supabase / LAN.
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    required this.isOnline,
    required this.isSyncing,
    this.pendingCount = 0,
    super.key,
  });

  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch ((isOnline, isSyncing, pendingCount > 0)) {
      (false, _, _) => (AppColors.mute, 'OFFLINE'),
      (true, true, _) => (AppColors.pegasus, 'SYNCING...'),
      (true, false, true) => (AppColors.pegasus, '$pendingCount PENDING'),
      (true, false, false) => (AppColors.x, 'SYNCED'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.mono.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
