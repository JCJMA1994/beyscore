import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'chamfer_card.dart';

enum ChamferButtonVariant {
  go, // Gradient Dragoon -> X with cyan glow
  primary, // Solid X Cyan
  ghost, // Transparent with border
  danger, // Dranzer Red
  warning, // Pegasus Yellow
  disabled, // Line border, mute text
}

class ChamferButton extends StatelessWidget {
  const ChamferButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ChamferButtonVariant.go,
    this.icon,
    this.isLoading = false,
    this.cutSize = 8.0,
    this.height = 48.0,
    this.denialReason,
  });

  final String text;
  final VoidCallback? onPressed;
  final ChamferButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final double cutSize;
  final double height;
  final String? denialReason;

  @override
  Widget build(BuildContext context) {
    final effectiveVariant = onPressed == null ? ChamferButtonVariant.disabled : variant;

    final isGo = effectiveVariant == ChamferButtonVariant.go;
    final isGhost = effectiveVariant == ChamferButtonVariant.ghost;
    final isDanger = effectiveVariant == ChamferButtonVariant.danger;
    final isWarning = effectiveVariant == ChamferButtonVariant.warning;
    final isDisabled = effectiveVariant == ChamferButtonVariant.disabled;

    Color textColor;
    Color borderColor;
    Color? glowColor;
    Gradient? gradient;
    var bgColor = Colors.transparent;

    if (isGo) {
      textColor = const Color(0xFF04121A);
      borderColor = AppColors.x;
      glowColor = AppColors.x.withValues(alpha: 0.35);
      gradient = const LinearGradient(
        colors: [AppColors.dragoon, AppColors.x],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (isGhost) {
      textColor = AppColors.text;
      borderColor = AppColors.line2;
      bgColor = Colors.transparent;
    } else if (isDanger) {
      textColor = AppColors.text;
      borderColor = AppColors.dranzer;
      bgColor = AppColors.dranzer.withValues(alpha: 0.2);
      glowColor = AppColors.dranzer.withValues(alpha: 0.4);
    } else if (isWarning) {
      textColor = const Color(0xFF04121A);
      borderColor = AppColors.pegasus;
      bgColor = AppColors.pegasus;
      glowColor = AppColors.pegasus.withValues(alpha: 0.4);
    } else if (isDisabled) {
      textColor = AppColors.mute;
      borderColor = AppColors.line;
      bgColor = AppColors.panel.withValues(alpha: 0.5);
    } else {
      textColor = const Color(0xFF04121A);
      borderColor = AppColors.x;
      bgColor = AppColors.x;
      glowColor = AppColors.x.withValues(alpha: 0.4);
    }

    final clipper = ChamferClipper(cutSize: cutSize);

    Widget buttonCore = CustomPaint(
      painter: ChamferBorderPainter(
        borderColor: borderColor,
        cutSize: cutSize,
        glowColor: glowColor,
        glowRadius: isGo ? 12.0 : 0.0,
      ),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: gradient == null ? bgColor : null,
            gradient: gradient,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (onPressed != null && !isLoading) {
      buttonCore = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: buttonCore,
        ),
      );
    }

    if (denialReason != null && isDisabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          buttonCore,
          const SizedBox(height: 6),
          Text(
            denialReason!,
            textAlign: TextAlign.center,
            style: AppTypography.mono.copyWith(
              fontSize: 10,
              color: AppColors.mute,
            ),
          ),
        ],
      );
    }

    return buttonCore;
  }
}
