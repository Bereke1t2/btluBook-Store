import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethio_book_store/core/const/ui_const.dart';
import 'package:ethio_book_store/core/const/app_typography.dart';
import 'package:ethio_book_store/features/auth/domain/entities/user.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/skeleton_loader.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/animated_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Downloaded Books Page - Shows all books downloaded by the user.
/// Features: Search, filter, delete, open book, chat about book.
class DownloadedBookPage extends StatefulWidget {
  final User user;
  final List<Book>? downloadedBooks;
  final void Function(Book)? onRemove;

  const DownloadedBookPage({
    super.key,
    required this.user,
    this.downloadedBooks,
    this.onRemove,
  });

  @override
  State<DownloadedBookPage> createState() => _DownloadedBookPageState();
}

class _DownloadedBookPageState extends State<DownloadedBookPage>
    with SingleTickerProviderStateMixin {
  // Animated background
  late final AnimationController _bgController;

  // Search
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Fiction', 'Non-fiction', 'Academic', 'Business', 'Technology'];

  // Mock downloaded books (in real app, this would come from local DB)
  late List<_DownloadedBook> _downloadedBooks;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);

    // Initialize with mock data or passed books
    _downloadedBooks = _getMockDownloadedBooks();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_DownloadedBook> _getMockDownloadedBooks() {
    // Mock data - in real app, fetch from local database
    return [
      _DownloadedBook(
        book: const Book(
          id: '1',
          title: 'The Midnight Library',
          author: 'Matt Haig',
          price: 12.99,
          rating: 4.6,
          category: 'Fiction',
          coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
          bookUrl: '/path/to/book1.pdf',
          isFeatured: true,
          tag: 'Bestseller',
        ),
        downloadDate: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: '3.2 MB',
        readProgress: 0.45,
        lastReadPage: 156,
        totalPages: 346,
      ),
      _DownloadedBook(
        book: const Book(
          id: '2',
          title: 'Atomic Habits',
          author: 'James Clear',
          price: 14.50,
          rating: 4.8,
          category: 'Business',
          coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
          bookUrl: '/path/to/book2.pdf',
          isFeatured: true,
          tag: 'Popular',
        ),
        downloadDate: DateTime.now().subtract(const Duration(days: 5)),
        fileSize: '2.8 MB',
        readProgress: 0.72,
        lastReadPage: 212,
        totalPages: 294,
      ),
      _DownloadedBook(
        book: const Book(
          id: '3',
          title: 'Clean Code',
          author: 'Robert C. Martin',
          price: 26.00,
          rating: 4.9,
          category: 'Technology',
          coverUrl: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400',
          bookUrl: '/path/to/book3.pdf',
        ),
        downloadDate: DateTime.now().subtract(const Duration(days: 10)),
        fileSize: '5.1 MB',
        readProgress: 0.15,
        lastReadPage: 67,
        totalPages: 448,
      ),
      _DownloadedBook(
        book: const Book(
          id: '4',
          title: 'Dune',
          author: 'Frank Herbert',
          price: 18.20,
          rating: 4.7,
          category: 'Fiction',
          coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400',
          bookUrl: '/path/to/book4.pdf',
          tag: 'Classic',
        ),
        downloadDate: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '4.5 MB',
        readProgress: 0.0,
        lastReadPage: 0,
        totalPages: 658,
      ),
    ];
  }

  List<_DownloadedBook> get _filteredBooks {
    return _downloadedBooks.where((db) {
      final matchesSearch = _searchQuery.isEmpty ||
          db.book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          db.book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          db.book.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _deleteBook(_DownloadedBook downloadedBook) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: UiConst.slate,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiConst.radiusLarge)),
        title: Text('Delete Book', style: AppTypography.headlineMedium),
        content: Text(
          'Are you sure you want to delete "${downloadedBook.book.title}"?\n\nThis will remove the book from your device.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _downloadedBooks.remove(downloadedBook);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${downloadedBook.book.title} deleted'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: UiConst.slate,
                ),
              );
            },
            child: Text('Delete', style: AppTypography.labelLarge.copyWith(color: UiConst.error)),
          ),
        ],
      ),
    );
  }

  void _openBook(_DownloadedBook downloadedBook) {
    // In real app, open PDF reader
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening "${downloadedBook.book.title}"...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: UiConst.slate,
      ),
    );
  }

  void _chatAboutBook(_DownloadedBook downloadedBook) {
    Navigator.pushNamed(
      context,
      '/ChatPage',
      arguments: {'bookTitle': downloadedBook.book.title, 'isStudentBook': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_bgController.value);
          final begin = Alignment.lerp(Alignment.bottomLeft, Alignment.topRight, t)!;
          final end = Alignment.lerp(Alignment.topRight, Alignment.bottomLeft, t)!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: UiConst.gradientBackground,
                stops: UiConst.gradientStops,
              ),
            ),
            child: Stack(
              children: [
                // Decorative glow circles
                const Positioned(
                  left: -80,
                  top: -60,
                  child: _GlowCircle(size: 280, color: UiConst.glowAmber),
                ),
                const Positioned(
                  right: -100,
                  bottom: -80,
                  child: _GlowCircle(size: 340, color: UiConst.glowSage),
                ),
                const Positioned(
                  right: -20,
                  top: 120,
                  child: _GlowCircle(size: 180, color: UiConst.glowParchment),
                ),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildCategoryFilter(),
                      Expanded(
                        child: _filteredBooks.isEmpty
                            ? _buildEmptyState()
                            : _buildBookList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(UiConst.radiusRound),
            onTap: () => Navigator.maybePop(context),
            child: GlassContainer(
              borderRadius: UiConst.radiusRound,
              padding: const EdgeInsets.all(10),
              blurSigma: UiConst.blurMedium,
              color: UiConst.glassFill,
              borderColor: UiConst.glassBorder,
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: UiConst.brandTextGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(r),
              blendMode: BlendMode.srcIn,
              child: Text(
                'Downloaded Books',
                style: AppTypography.headlineLarge,
              ),
            ),
          ),
          GlassContainer(
            borderRadius: UiConst.radiusMedium,
            padding: const EdgeInsets.all(10),
            blurSigma: UiConst.blurMedium,
            color: UiConst.glassFill,
            borderColor: UiConst.glassBorder,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder_rounded, color: UiConst.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${_downloadedBooks.length}',
                  style: AppTypography.labelLarge.copyWith(color: UiConst.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: GlassContainer(
        borderRadius: UiConst.radiusMedium,
        blurSigma: UiConst.blurMedium,
        color: UiConst.glassFill,
        borderColor: UiConst.glassBorder,
        child: TextField(
          controller: _searchController,
          style: AppTypography.bodyMedium,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search your books...',
            hintStyle: AppTypography.hint,
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: UiConst.durationFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UiConst.radiusRound),
                gradient: isSelected
                    ? const LinearGradient(colors: UiConst.brandGradient)
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                category,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredBooks.length,
      itemBuilder: (context, index) {
        final downloadedBook = _filteredBooks[index];
        return _DownloadedBookCard(
          downloadedBook: downloadedBook,
          onOpen: () => _openBook(downloadedBook),
          onChat: () => _chatAboutBook(downloadedBook),
          onDelete: () => _deleteBook(downloadedBook),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [UiConst.amber.withOpacity(0.2), UiConst.sage.withOpacity(0.2)],
                ),
              ),
              child: const Icon(
                Icons.download_done_rounded,
                size: 56,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All'
                  ? 'No books found'
                  : 'No downloaded books yet',
              style: AppTypography.headlineMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All'
                  ? 'Try adjusting your search or filter'
                  : 'Download books from the store to read them offline',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_searchQuery.isEmpty && _selectedCategory == 'All')
              AnimatedButton(
                label: 'Browse Books',
                icon: Icons.explore_rounded,
                isPrimary: true,
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

/// Downloaded book card with progress, actions
class _DownloadedBookCard extends StatelessWidget {
  final _DownloadedBook downloadedBook;
  final VoidCallback onOpen;
  final VoidCallback onChat;
  final VoidCallback onDelete;

  const _DownloadedBookCard({
    required this.downloadedBook,
    required this.onOpen,
    required this.onChat,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final book = downloadedBook.book;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassContainer(
        borderRadius: UiConst.radiusLarge,
        blurSigma: UiConst.blurMedium,
        color: UiConst.glassFill,
        borderColor: UiConst.glassBorder,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(UiConst.radiusSmall),
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.white12,
                      child: const Center(
                        child: Icon(Icons.book_rounded, color: Colors.white24),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white12,
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
                    ),
                  ),
                ),
                // Progress overlay
                if (downloadedBook.readProgress > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(UiConst.radiusSmall),
                          bottomRight: Radius.circular(UiConst.radiusSmall),
                        ),
                        color: Colors.black45,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: downloadedBook.readProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(UiConst.radiusSmall),
                            ),
                            gradient: const LinearGradient(colors: UiConst.brandGradient),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress and metadata
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.menu_book_rounded,
                        label: downloadedBook.readProgress > 0
                            ? '${(downloadedBook.readProgress * 100).toInt()}%'
                            : 'New',
                        color: downloadedBook.readProgress > 0 ? UiConst.sage : UiConst.amber,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.storage_rounded,
                        label: downloadedBook.fileSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Downloaded ${_formatDate(downloadedBook.downloadDate)}',
                    style: AppTypography.labelSmall.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                _ActionButton(
                  icon: Icons.play_arrow_rounded,
                  onTap: onOpen,
                  tooltip: 'Read',
                  isPrimary: true,
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: onChat,
                  tooltip: 'Chat',
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: onDelete,
                  tooltip: 'Delete',
                  color: UiConst.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Small info chip
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConst.radiusRound),
        color: (color ?? Colors.white).withOpacity(0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color ?? Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Action button for card
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool isPrimary;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.isPrimary = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary ? const LinearGradient(colors: UiConst.brandGradient) : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? (isPrimary ? Colors.black : Colors.white70),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Glow circle decoration
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.4), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

/// Downloaded book model with metadata
class _DownloadedBook {
  final Book book;
  final DateTime downloadDate;
  final String fileSize;
  final double readProgress; // 0.0 to 1.0
  final int lastReadPage;
  final int totalPages;

  const _DownloadedBook({
    required this.book,
    required this.downloadDate,
    required this.fileSize,
    this.readProgress = 0.0,
    this.lastReadPage = 0,
    this.totalPages = 0,
  });
}