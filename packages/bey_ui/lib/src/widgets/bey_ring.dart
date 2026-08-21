import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Animated rotating dashed ring used in hero, splash, and battle overlays.
class BeyRing extends StatefulWidget {
  const BeyRing({
    this.size = 110,
    this.color = AppColors.x,
    this.duration = const Duration(seconds: 10),
    this.reverse = false,
    this.child,
    super.key,
  });

  final double size;
  final Color color;
  final Duration duration;
  final bool reverse;
  final Widget? child;

  @override
  State<BeyRing> createState() => _BeyRingState();
}

class _BeyRingState extends State<BeyRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: widget.reverse);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(color: widget.color),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer dashed ring
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const dashCount = 24;
    const sweep = 3.1415926535 * 2 / dashCount;
    for (var i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        false,
        outerPaint,
      );
    }

    // Inner glowing ring
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius * 0.7, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.color != color;
}
