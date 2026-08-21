import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Standard container card with subtle borders and chamfered corners.
class BeyCard extends StatelessWidget {
  const BeyCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.panel,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        border: Border.all(
          color: borderColor ?? AppColors.line,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        child: content,
      );
    }

    return content;
  }
}
