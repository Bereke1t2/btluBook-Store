import 'package:ethio_book_store/features/books/presentation/widgets/coverPlaceHolder.dart';
import 'package:ethio_book_store/core/const/url_const.dart';
import 'package:flutter/material.dart';

class CoverImage extends StatelessWidget {
  final String? url;

  const CoverImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const CoverPlaceholder();
    }
    String imagePath = url!;
    if (!imagePath.startsWith('http')) {
      imagePath = "${UrlConst.baseUrl}${imagePath.startsWith('/') ? '' : '/'}${imagePath}";
    }
    
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      // Lightweight shimmer-ish loading
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const CoverPlaceholder(animate: true);
      },
      errorBuilder: (context, error, stack) {
        return const CoverPlaceholder();
      },
    );
  }
}
