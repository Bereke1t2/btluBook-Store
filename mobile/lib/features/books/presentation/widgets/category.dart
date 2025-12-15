import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:flutter/material.dart';

Widget Category(String label, bool selected, Function onTap) {
  return GestureDetector(
    onTap: () => onTap(),
    child: GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 12,
      color: selected
          ? const Color(0xFFF2C94C).withValues(alpha: 40 / 255)
          : Colors.white.withValues(alpha: 22 / 255),
      borderColor: selected
          ? const Color(0xFFF2C94C)
          : Colors.white.withValues(alpha: 56 / 255),
      child: Row(
        children: [
          if (selected)
            const Icon(Icons.star_rounded, color: Color(0xFFF2C94C), size: 18),
          if (selected) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
