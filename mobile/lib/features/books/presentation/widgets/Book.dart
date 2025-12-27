import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/Tag.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/coverImage.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/rating.dart';
import 'package:flutter/material.dart';

class QuickLookSheet extends StatelessWidget {
  final Book book;
  final VoidCallback onAddToCart;

  const QuickLookSheet({super.key, required this.book, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: GlassContainer(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        blurSigma: 26,
        color: Colors.white.withValues(alpha: 24 / 255),
        borderColor: Colors.white.withValues(alpha: 66 / 255),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 90 / 255),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 88,
                        height: 120,
                        child: CoverImage(url: book.coverUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tag(label: book.tag ?? 'Recommended', color: const Color(0xFFF2C94C)),
                          const SizedBox(height: 8),
                          Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Rating(rating: book.rating),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '\$${book.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFF2C94C),
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C94C),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text(
                          'GO to Chat',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

