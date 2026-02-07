import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color color;

  const Tag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 80), // Limit max width for grid tags
      child: GlassContainer(
        borderRadius: 999,
        blurSigma: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: color.withValues(alpha: 36 / 255),
        borderColor: color,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
