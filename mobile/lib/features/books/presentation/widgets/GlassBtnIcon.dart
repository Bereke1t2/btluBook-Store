import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:flutter/material.dart';

class GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const GlassIconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      blurSigma: 16,
      color: Colors.white.withValues(alpha: 22 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}