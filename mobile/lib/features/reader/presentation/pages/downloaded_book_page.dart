import 'dart:ui' as ui;
import 'dart:io';
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
import 'package:ethio_book_store/features/notes/presentation/pages/notes_page.dart';
import 'package:ethio_book_store/features/notes/presentation/bloc/note_bloc.dart';
import 'package:ethio_book_store/injections.dart' as di;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ethio_book_store/features/reader/presentation/pages/pdf_reader_page.dart'; // Added

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

  // Bloc
  late BookBloc _bookBloc;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);

    _bookBloc = di.sl<BookBloc>()..add(LoadDownloadedBooksEvent());
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchController.dispose();
    _bookBloc.close();
    super.dispose();
  }


  List<Book> _filteredBooks(List<Book> books) {
    return books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          book.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookBloc,
      child: Scaffold(
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
                        _buildHeader(), // Updated separately if needed, but signature changed?
                        _buildSearchBar(),
                        _buildCategoryFilter(),
                        Expanded(
                          child: BlocBuilder<BookBloc, BookState>(
                            builder: (context, state) {
                              if (state is BookLoadingInProgress) {
                                return const Center(child: CircularProgressIndicator(color: UiConst.amber));
                              } else if (state is BooksLoaded) {
                                final books = _filteredBooks(state.books);
                                return books.isEmpty
                                    ? _buildEmptyState()
                                    : _buildBookList(books);
                              } else if (state is BookOperationFailure) {
                                return Center(child: Text(state.error, style: const TextStyle(color: Colors.white)));
                              }
                              return _buildEmptyState();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        int count = 0;
        if (state is BooksLoaded) count = state.books.length;
        
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
                      '$count',
                      style: AppTypography.labelLarge.copyWith(color: UiConst.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildBookList(List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _DownloadedBookCard(
          book: book,
          onOpen: () => _openBook(book),
          onChat: () => _chatAboutBook(book),
          onNotes: () => _openNotes(book),
          onDelete: () => _deleteBook(book),
        );
      },
    );
  }

  void _deleteBook(Book book) {
    // Delete logic? Currently BookBloc doesn't have DeleteDownloadedBookEvent.
    // Assuming we just remove from UI for now or ignore delete in this iteration.
    // Or call a delete use case.
  }

  void _openBook(Book book) {
    if (book.bookUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Book file not found'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: UiConst.error,
        ),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<NoteBloc>()),
            BlocProvider.value(value: _bookBloc),
          ],
          child: PDFReaderPage(
            filePath: book.bookUrl,
            bookId: book.id,
            bookTitle: book.title,
            initialPage: book.lastReadPage > 0 ? book.lastReadPage - 1 : 0,
          ),
        ),
      ),
    ).then((_) {
      _bookBloc.add(LoadDownloadedBooksEvent());
    });
  }

  void _chatAboutBook(Book book) {
    Navigator.pushNamed(
      context,
      '/ChatPage',
      arguments: {'bookTitle': book.title, 'isStudentBook': true},
    );
  }

  void _openNotes(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => di.sl<NoteBloc>(),
          child: NotesPage(
            bookId: book.id,
            bookTitle: book.title,
          ),
        ),
      ),
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
/// Downloaded book card with progress, actions
class _DownloadedBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onOpen;
  final VoidCallback onChat;
  final VoidCallback onNotes;
  final VoidCallback onDelete;

  const _DownloadedBookCard({
    required this.book,
    required this.onOpen,
    required this.onChat,
    required this.onNotes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final readProgress = book.readProgress;
    
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
                  child: book.coverUrl.startsWith('http')
                      ? CachedNetworkImage(
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
                        )
                      : Image.file(
                          File(book.coverUrl), // Requires dart:io
                          width: 70,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white12,
                            child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
                          ),
                        ),
                ),
                // Progress overlay
                if (readProgress > 0)
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
                        widthFactor: readProgress > 1.0 ? 1.0 : readProgress,
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
                        label: readProgress > 0
                            ? '${(readProgress * 100).toInt()}%'
                            : 'New',
                        color: readProgress > 0 ? UiConst.sage : UiConst.amber,
                      ),
                      const SizedBox(width: 8),
                      // _InfoChip(
                      //   icon: Icons.storage_rounded,
                      //   label: 'PDF', // Placeholder
                      // ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    readProgress > 0 ? 'Page ${book.lastReadPage} of ${book.totalPages}' : 'Tap to read',
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
                  icon: Icons.note_alt_outlined,
                  onTap: onNotes,
                  tooltip: 'Notes',
                  color: UiConst.sage,
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: onChat,
                  tooltip: 'Chat',
                ),
                // const SizedBox(height: 8),
                // _ActionButton(
                //   icon: Icons.delete_outline_rounded,
                //   onTap: onDelete,
                //   tooltip: 'Delete',
                //   color: UiConst.error,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // String _formatDate(DateTime date) { ... } // Removed
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
