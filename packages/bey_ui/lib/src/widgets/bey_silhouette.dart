import 'package:bey_domain/bey_domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders a dynamic geometric silhouette for Beyblade parts.
class BeySilhouette extends StatelessWidget {
  const BeySilhouette({
    required this.type,
    this.size = 64,
    this.color = AppColors.line2,
    super.key,
  });

  final PartType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SilhouettePainter(type: type, color: color),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter({required this.type, required this.color});

  final PartType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    switch (type) {
      case PartType.blade:
      case PartType.mainBlade:
      case PartType.overBlade:
      case PartType.metalBlade:
        // 3-blade hexagonal geometry
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final r = i.isEven ? radius : radius * 0.7;
          if (i == 0) {
            path.moveTo(center.dx + radius * 0.9, center.dy);
          } else {
            path.lineTo(center.dx + r * 0.9, center.dy + r * 0.9);
          }
        }
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(center, radius * 0.4, paint);
      case PartType.ratchet:
        // Ratchet circular ring with 3 or 4 notches
        canvas.drawCircle(center, radius * 0.75, paint);
        canvas.drawCircle(center, radius * 0.35, paint);
      case PartType.bit:
        // Bit shaft and tip shape
        final rect = Rect.fromCenter(center: center, width: radius * 0.6, height: radius * 1.2);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
        canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.5), radius * 0.2, paint);
      case PartType.lockChip:
      case PartType.assistBlade:
      case PartType.accessory:
        canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
