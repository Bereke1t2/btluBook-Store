import 'package:ethio_book_store/core/const/url_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethio_book_store/core/const/ui_const.dart';
import 'package:ethio_book_store/core/const/app_typography.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/animated_button.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/rating.dart';
import 'package:ethio_book_store/features/notes/presentation/pages/notes_page.dart';
import 'package:ethio_book_store/features/notes/presentation/bloc/note_bloc.dart';
import 'package:ethio_book_store/injections.dart' as di;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:ethio_book_store/features/reader/presentation/pages/pdf_reader_page.dart';
import 'dart:io';


/// Book Details Page with parallax cover, description, and actions.
class BookDetailsPage extends StatefulWidget {
  final Book book;
  final String? heroTag;

  const BookDetailsPage({
    super.key,
    required this.book,
    this.heroTag,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late final ScrollController _scrollController;
  
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;
  double _scrollOffset = 0;

  // Mock related books
  late final List<Book> _relatedBooks;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    _relatedBooks = _getMockRelatedBooks();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Book> _getMockRelatedBooks() {
    // Would fetch from API based on category
    return [
      Book(
        id: 'r1',
        title: 'Similar Book 1',
        author: 'Author Name',
        price: 12.99,
        rating: 4.5,
        category: widget.book.category,
        coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300',
        bookUrl: '',
      ),
      Book(
        id: 'r2',
        title: 'Similar Book 2',
        author: 'Another Author',
        price: 15.99,
        rating: 4.3,
        category: widget.book.category,
        coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=300',
        bookUrl: '',
      ),
      Book(
        id: 'r3',
        title: 'You May Also Like',
        author: 'Third Author',
        price: 10.99,
        rating: 4.7,
        category: widget.book.category,
        coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=300',
        bookUrl: '',
      ),
    ];
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: UiConst.slate,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadBook() {
    // Trigger download via bloc
    context.read<BookBloc>().add(DownloadBookEvent(widget.book.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "${widget.book.title}"...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF233542),
      ),
    );
  }

  void _chatAboutBook() {
    Navigator.pushNamed(
      context,
      '/ChatPage',
      arguments: {'bookTitle': widget.book.title, 'isStudentBook': true},
    );
  }

  void _shareBook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share sheet would open here'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: UiConst.slate,
      ),
    );
  }

  void _openNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => di.sl<NoteBloc>(),
          child: NotesPage(
            bookId: widget.book.id,
            bookTitle: widget.book.title,
          ),
        ),
      ),
    );
  }

  void _openBook(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<NoteBloc>()),
            BlocProvider.value(value: context.read<BookBloc>()),
          ],
          child: PDFReaderPage(
            filePath: filePath,
            bookId: widget.book.id,
            bookTitle: widget.book.title,
            initialPage: widget.book.lastReadPage > 0 ? widget.book.lastReadPage - 1 : 0,
          ),
        ),
      ),
    ).then((_) {
      // Optional: Refresh book details or progress if needed
      context.read<BookBloc>().add(LoadBooksEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final coverHeight = screenHeight * 0.45;
    
    // Parallax factor
    final parallaxOffset = _scrollOffset * 0.5;
    final coverOpacity = (1 - (_scrollOffset / coverHeight)).clamp(0.3, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: UiConst.ink,
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
                // Parallax cover image
                Positioned(
                  top: -parallaxOffset,
                  left: 0,
                  right: 0,
                  height: coverHeight,
                  child: Opacity(
                    opacity: coverOpacity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: widget.heroTag ?? 'book-${widget.book.id}',
                          child: CachedNetworkImage(
                            imageUrl: widget.book.coverUrl.startsWith('http') 
                                ? widget.book.coverUrl 
                                : "${UrlConst.baseUrl}${widget.book.coverUrl.startsWith('/') ? '' : '/'}${widget.book.coverUrl}",
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: UiConst.slate),
                            errorWidget: (_, __, ___) => Container(
                              color: UiConst.slate,
                              child: const Icon(Icons.book, color: Colors.white24, size: 64),
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                UiConst.ink.withOpacity(0.3),
                                UiConst.ink.withOpacity(0.8),
                                UiConst.ink,
                              ],
                              stops: const [0.0, 0.5, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main scrollable content
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Spacer for cover
                    SliverToBoxAdapter(
                      child: SizedBox(height: coverHeight - 60),
                    ),

                    // Book info card
                    SliverToBoxAdapter(
                      child: _buildInfoCard(),
                    ),

                    // Description section
                    SliverToBoxAdapter(
                      child: _buildDescriptionSection(),
                    ),

                    // Stats section
                    SliverToBoxAdapter(
                      child: _buildStatsSection(),
                    ),

                    // Actions section
                    SliverToBoxAdapter(
                      child: _buildActionsSection(),
                    ),

                    // Related books section
                    SliverToBoxAdapter(
                      child: _buildRelatedBooksSection(),
                    ),

                    // Bottom padding
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                    ),
                  ],
                ),

                // Top navigation bar
                _buildTopBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    final showSolid = _scrollOffset > 100;
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: UiConst.durationFast,
        decoration: BoxDecoration(
          color: showSolid ? UiConst.ink.withOpacity(0.95) : Colors.transparent,
          boxShadow: showSolid
              ? [BoxShadow(color: Colors.black26, blurRadius: 10)]
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GlassContainer(
                  borderRadius: UiConst.radiusRound,
                  padding: const EdgeInsets.all(8),
                  blurSigma: UiConst.blurMedium,
                  color: Colors.black38,
                  borderColor: Colors.white24,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
                const Spacer(),
                if (showSolid)
                  Expanded(
                    child: Text(
                      widget.book.title,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                GlassContainer(
                  borderRadius: UiConst.radiusRound,
                  padding: const EdgeInsets.all(8),
                  blurSigma: UiConst.blurMedium,
                  color: Colors.black38,
                  borderColor: Colors.white24,
                  child: InkWell(
                    onTap: _shareBook,
                    child: const Icon(Icons.share_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        borderRadius: UiConst.radiusXLarge,
        blurSigma: UiConst.blurHeavy,
        color: UiConst.glassFill,
        borderColor: UiConst.glassBorder,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag
            if (widget.book.tag != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UiConst.radiusRound),
                  gradient: const LinearGradient(colors: UiConst.brandGradient),
                ),
                child: Text(
                  widget.book.tag!,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // Title
            Text(
              widget.book.title,
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: 8),

            // Author
            Row(
              children: [
                const Icon(Icons.person_rounded, color: Colors.white54, size: 18),
                const SizedBox(width: 6),
                Text(
                  'by ${widget.book.author}',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category and rating row
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(UiConst.radiusRound),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Text(
                      widget.book.category,
                      style: AppTypography.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Rating(rating: widget.book.rating, size: 16),
                  const SizedBox(width: 20),
                  // Favorite button
                  AnimatedFavoriteButton(
                    isFavorite: _isFavorite,
                    onTap: _toggleFavorite,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price
            Row(
              children: [
                Text(
                  widget.book.price > 0 ? '\$${widget.book.price.toStringAsFixed(2)}' : 'FREE',
                  style: AppTypography.priceLarge,
                ),
                const Spacer(),
                Text(
                  'Shared by ${widget.book.sharedBy}',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    const description = '''
This is a beautifully written book that explores deep themes and captivating narratives. The author masterfully weaves together complex characters and thought-provoking ideas that will stay with you long after you finish reading.

Whether you're looking for entertainment, education, or inspiration, this book delivers on all fronts. Critics have praised its innovative approach and compelling storytelling, making it a must-read for anyone interested in the genre.

The book has received numerous accolades and continues to inspire readers around the world. Its timeless themes resonate with audiences of all ages, making it a perfect addition to any bookshelf.
''';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GlassContainer(
        borderRadius: UiConst.radiusLarge,
        blurSigma: UiConst.blurMedium,
        color: UiConst.glassFill,
        borderColor: UiConst.glassBorder,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_rounded, color: UiConst.amber, size: 20),
                const SizedBox(width: 8),
                Text('Description', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: UiConst.durationMedium,
              crossFadeState: _isDescriptionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                description,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                description,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Text(
                _isDescriptionExpanded ? 'Show less' : 'Read more',
                style: AppTypography.labelMedium.copyWith(color: UiConst.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              label: 'Rating',
              value: widget.book.rating.toStringAsFixed(1),
              color: UiConst.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.menu_book_rounded,
              label: 'Category',
              value: widget.book.category,
              color: UiConst.sage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.download_rounded,
              label: 'Downloads',
              value: '1.2K',
              color: UiConst.brandAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<BookBloc, BookState>(
                  builder: (context, state) {
                    bool isDownloading = false;
                    bool isAlreadyDownloaded = false;
                    String? localPath;
                    double progress = 0;

                    if (state is BookDownloading && state.bookId == widget.book.id) {
                      isDownloading = true;
                    } else if (state is BookDownloadProgress && state.bookId == widget.book.id) {
                      isDownloading = true;
                      progress = state.progress;
                    } else if (state is BooksLoaded) {
                      isAlreadyDownloaded = state.downloadedBooks.containsKey(widget.book.id);
                      localPath = state.downloadedBooks[widget.book.id];
                    } else if (state is BookDownloadSuccess && state.bookId == widget.book.id) {
                      isAlreadyDownloaded = true;
                      localPath = state.path;
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedButton(
                          label: isDownloading
                              ? 'Downloading ${(progress * 100).toInt()}%'
                              : (isAlreadyDownloaded ? 'Open' : 'Download'),
                          icon: isDownloading 
                              ? Icons.sync_rounded 
                              : (isAlreadyDownloaded ? Icons.menu_book_rounded : Icons.download_rounded),
                          isPrimary: true,
                          onTap: isDownloading 
                              ? null 
                              : (isAlreadyDownloaded 
                                  ? () => _openBook(localPath!) 
                                  : _downloadBook),
                        ),
                        if (isDownloading) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(UiConst.amber),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedButton(
                  label: 'Chat AI',
                  icon: Icons.chat_bubble_outline_rounded,
                  isPrimary: false,
                  onTap: _chatAboutBook,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedButton(
            label: 'Notes',
            icon: Icons.note_alt_outlined,
            isPrimary: false,
            onTap: _openNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedBooksSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: UiConst.amber, size: 20),
                const SizedBox(width: 8),
                Text('Similar Books', style: AppTypography.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _relatedBooks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final book = _relatedBooks[index];
                return _RelatedBookCard(book: book);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: UiConst.radiusMedium,
      blurSigma: UiConst.blurMedium,
      color: UiConst.glassFill,
      borderColor: UiConst.glassBorder,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

/// Related book card
class _RelatedBookCard extends StatelessWidget {
  final Book book;

  const _RelatedBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailsPage(book: book),
          ),
        );
      },
      child: GlassContainer(
        borderRadius: UiConst.radiusMedium,
        blurSigma: UiConst.blurLight,
        color: UiConst.glassFill,
        borderColor: UiConst.glassBorder,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UiConst.radiusMedium),
                    topRight: Radius.circular(UiConst.radiusMedium),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl.startsWith('http') 
                        ? book.coverUrl 
                        : "${UrlConst.baseUrl}${book.coverUrl.startsWith('/') ? '' : '/'}${book.coverUrl}",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => Container(color: UiConst.slate),
                    errorWidget: (_, __, ___) => Container(
                      color: UiConst.slate,
                      child: const Icon(Icons.book, color: Colors.white24),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTypography.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${book.price.toStringAsFixed(2)}',
                      style: AppTypography.labelSmall.copyWith(color: UiConst.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
