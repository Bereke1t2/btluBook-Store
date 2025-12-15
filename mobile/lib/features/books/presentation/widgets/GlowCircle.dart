
// GlowCircle moved inline to avoid missing import
import 'package:flutter/material.dart';

class GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const GlowCircle({
    super.key,
    required this.size,
    required this.color,
    this.blur = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 160 / 255),
              blurRadius: blur,
              spreadRadius: blur * 0.35,
            ),
          ],
        ),
      ),
    );
  }
}