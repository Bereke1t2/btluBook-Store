import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color color;

  const Tag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 999,
      blurSigma: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: color.withValues(alpha: 36 / 255),
      borderColor: color,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
