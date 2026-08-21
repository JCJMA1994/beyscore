import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'bey_silhouette.dart';

/// Displays a Beyblade part image with network caching, asset fallback,
/// and geometric silhouette as graceful fallback (e.g. offline).
class PartImage extends StatelessWidget {
  const PartImage({
    required this.type,
    this.imageRemote,
    this.imageLocal,
    this.size = 48,
    this.color = AppColors.x,
    this.showBorder = true,
    this.borderRadius = 6,
    super.key,
  });

  final PartType type;
  final String? imageRemote;
  final String? imageLocal;
  final double size;
  final Color color;
  final bool showBorder;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget imageContent;

    if (imageRemote != null && imageRemote!.isNotEmpty) {
      imageContent = Image.network(
        imageRemote!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: color.withValues(alpha: 0.5),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _fallbackLocalOrSilhouette();
        },
      );
    } else {
      imageContent = _fallbackLocalOrSilhouette();
    }

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.void_,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: imageContent,
      ),
    );
  }

  Widget _fallbackLocalOrSilhouette() {
    if (imageLocal != null && imageLocal!.isNotEmpty) {
      return Image.asset(
        imageLocal!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return BeySilhouette(type: type, size: size, color: color);
        },
      );
    }
    return BeySilhouette(type: type, size: size, color: color);
  }
}
