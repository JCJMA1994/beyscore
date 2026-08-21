import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clipper that cuts corners at 45 degrees (Cyber/Mecha chamfer style).
class ChamferClipper extends CustomClipper<Path> {
  const ChamferClipper({
    this.cutSize = 10.0,
    this.topLeft = true,
    this.topRight = false,
    this.bottomRight = true,
    this.bottomLeft = false,
  });

  final double cutSize;
  final bool topLeft;
  final bool topRight;
  final bool bottomRight;
  final bool bottomLeft;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Top-left
    if (topLeft) {
      path
        ..moveTo(0, cutSize)
        ..lineTo(cutSize, 0);
    } else {
      path.moveTo(0, 0);
    }

    // Top-right
    if (topRight) {
      path
        ..lineTo(w - cutSize, 0)
        ..lineTo(w, cutSize);
    } else {
      path.lineTo(w, 0);
    }

    // Bottom-right
    if (bottomRight) {
      path
        ..lineTo(w, h - cutSize)
        ..lineTo(w - cutSize, h);
    } else {
      path.lineTo(w, h);
    }

    // Bottom-left
    if (bottomLeft) {
      path
        ..lineTo(cutSize, h)
        ..lineTo(0, h - cutSize);
    } else {
      path.lineTo(0, h);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ChamferClipper oldClipper) {
    return oldClipper.cutSize != cutSize ||
        oldClipper.topLeft != topLeft ||
        oldClipper.topRight != topRight ||
        oldClipper.bottomRight != bottomRight ||
        oldClipper.bottomLeft != bottomLeft;
  }
}

/// Custom painter to draw chamfered borders precisely matching [ChamferClipper].
class ChamferBorderPainter extends CustomPainter {
  const ChamferBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.0,
    this.cutSize = 10.0,
    this.topLeft = true,
    this.topRight = false,
    this.bottomRight = true,
    this.bottomLeft = false,
    this.glowColor,
    this.glowRadius = 0.0,
  });

  final Color borderColor;
  final double borderWidth;
  final double cutSize;
  final bool topLeft;
  final bool topRight;
  final bool bottomRight;
  final bool bottomLeft;
  final Color? glowColor;
  final double glowRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = ChamferClipper(
      cutSize: cutSize,
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );
    final path = clipper.getClip(size);

    if (glowColor != null && glowRadius > 0) {
      final glowPaint = Paint()
        ..color = glowColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 1.5
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
      canvas.drawPath(path, glowPaint);
    }

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChamferBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.cutSize != cutSize ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.glowRadius != glowRadius;
  }
}

/// Card with 45° chamfered corners and high-tech glow borders.
class ChamferCard extends StatelessWidget {
  const ChamferCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.panel,
    this.borderColor = AppColors.line,
    this.borderWidth = 1.0,
    this.cutSize = 10.0,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.glowColor,
    this.glowRadius = 0.0,
    this.topLeft = true,
    this.topRight = false,
    this.bottomRight = true,
    this.bottomLeft = false,
    this.onTap,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double cutSize;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double glowRadius;
  final bool topLeft;
  final bool topRight;
  final bool bottomRight;
  final bool bottomLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final clipper = ChamferClipper(
      cutSize: cutSize,
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );

    Widget content = CustomPaint(
      painter: ChamferBorderPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        cutSize: cutSize,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
        glowColor: glowColor,
        glowRadius: glowRadius,
      ),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          color: backgroundColor,
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        customBorder: const RoundedRectangleBorder(),
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
