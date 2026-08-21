import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Official BeyScore Logo with high-impact skewed gradients.
///
/// Follows 1-usuario.html §3 branding:
/// - 'BEY' in Dragoon-to-X gradient (#2B6BFF -> #00E5D0)
/// - 'SCORE' in Dranzer-to-Pegasus gradient (#FF3B2F -> #FFC400)
/// - Skewed -8° esports angle
class BeyLogo extends StatelessWidget {
  const BeyLogo({
    super.key,
    this.fontSize = 32,
    this.subtitle,
    this.showXBadge = true,
  });

  final double fontSize;
  final String? subtitle;
  final bool showXBadge;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform(
          transform: Matrix4.skewX(-0.14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.dragoon, AppColors.x],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'BEY',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.dranzer, AppColors.pegasus],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'SCORE',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              if (showXBadge) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.x.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.x, width: 1.5),
                  ),
                  child: Text(
                    'X',
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: fontSize * 0.45,
                      fontWeight: FontWeight.w900,
                      color: AppColors.x,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!.toUpperCase(),
            style: AppTypography.mono.copyWith(
              fontSize: fontSize * 0.26,
              color: AppColors.mute,
              letterSpacing: 2.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
