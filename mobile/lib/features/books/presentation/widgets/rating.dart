import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final double rating;
  final double size;

  const Rating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = i < full
            ? Icons.star_rounded
            : (i == full && half ? Icons.star_half_rounded : Icons.star_border_rounded);
        return Icon(icon, color: const Color(0xFFF2C94C), size: size);
      }),
    );
  }
}