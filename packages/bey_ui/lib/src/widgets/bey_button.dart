import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum BeyButtonVariant {
  primary,
  secondary,
  danger,
  ghost,
}

/// Primary interactive button with solid typography and sharp styling.
class BeyButton extends StatelessWidget {
  const BeyButton({
    required this.label,
    this.onPressed,
    this.variant = BeyButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final BeyButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      BeyButtonVariant.primary => (AppColors.x, AppColors.void_, AppColors.x),
      BeyButtonVariant.secondary => (AppColors.panel2, AppColors.text, AppColors.line2),
      BeyButtonVariant.danger => (AppColors.dranzer, AppColors.text, AppColors.dranzer),
      BeyButtonVariant.ghost => (Colors.transparent, AppColors.mute, Colors.transparent),
    };

    final content = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.3),
        disabledForegroundColor: fg.withValues(alpha: 0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
          side: BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: fg,
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: fg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: content);
    }
    return content;
  }
}
