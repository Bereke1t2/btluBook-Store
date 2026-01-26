import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ethio_book_store/core/const/ui_const.dart';

/// Skeleton loading placeholders for smooth loading states.
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.15),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Book card skeleton for loading states
class BookCardSkeleton extends StatelessWidget {
  final bool isSmall;
  
  const BookCardSkeleton({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(UiConst.radiusLarge),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image skeleton
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(UiConst.radiusMedium),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title skeleton
          SkeletonLoader(
            width: double.infinity,
            height: isSmall ? 14 : 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 4),
          // Author skeleton
          SkeletonLoader(
            width: 80,
            height: isSmall ? 12 : 14,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          // Rating and price row
          Row(
            children: [
              SkeletonLoader(
                width: 60,
                height: 14,
                borderRadius: 4,
              ),
              const Spacer(),
              SkeletonLoader(
                width: 40,
                height: 16,
                borderRadius: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Featured book card skeleton
class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(UiConst.radiusLarge),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          // Cover skeleton
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.08),
            highlightColor: Colors.white.withOpacity(0.15),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(UiConst.radiusLarge),
                  bottomLeft: Radius.circular(UiConst.radiusLarge),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 60, height: 20, borderRadius: 10),
                  const SizedBox(height: 8),
                  SkeletonLoader(width: double.infinity, height: 18, borderRadius: 4),
                  const SizedBox(height: 6),
                  SkeletonLoader(width: 100, height: 14, borderRadius: 4),
                  const Spacer(),
                  SkeletonLoader(width: 50, height: 20, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List item skeleton for downloaded books, etc.
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(UiConst.radiusLarge),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          // Thumbnail skeleton
          SkeletonLoader(
            width: 60,
            height: 80,
            borderRadius: UiConst.radiusSmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 16, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonLoader(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                SkeletonLoader(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SkeletonLoader(width: 32, height: 32, borderRadius: UiConst.radiusRound),
        ],
      ),
    );
  }
}

/// Chat message skeleton
class ChatMessageSkeleton extends StatelessWidget {
  final bool isUser;
  
  const ChatMessageSkeleton({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
            const SizedBox(height: 6),
            SkeletonLoader(width: 150, height: 14, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
