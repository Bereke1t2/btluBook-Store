import 'package:flutter/material.dart';

class CoverPlaceholder extends StatelessWidget {
  final bool animate;
  const CoverPlaceholder({super.key, this.animate = false});

  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withValues(alpha: 24 / 255);
    final hi = Colors.white.withValues(alpha: 52 / 255);
    return AnimatedContainer(
      duration: animate ? const Duration(milliseconds: 700) : Duration.zero,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: animate ? [base, hi, base] : [base, base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white70,
          size: 42,
        ),
      ),
    );
  }
}
