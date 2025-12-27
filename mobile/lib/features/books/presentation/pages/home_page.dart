import 'package:ethio_book_store/features/auth/domain/entities/user.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:ethio_book_store/features/books/presentation/pages/user_profile_page.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/Book.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassBtnIcon.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/Tag.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/category.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/coverImage.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/header.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/rating.dart';
import 'package:ethio_book_store/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Animated background
  late final AnimationController _bgController;

  // Navigation
  int _navIndex = 0;

  // Search
  final _searchCtrl = TextEditingController();

  // Categories
  final List<String> _categories = const [
    'All',
    'Fiction',
    'Sci‑Fi',
    'Business',
    'Self Help',
    'Design',
    'History',
  ];
  String _selectedCategory = 'All';

  // Featured carousel
  late final PageController _pageCtrl;
  double _page = 0;

  // Favorites
  final Set<String> _favorites = {};

  // Mock data
  late List<Book> _allBooks;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _pageCtrl = PageController(viewportFraction: 0.82)
      ..addListener(() {
        setState(() => _page = _pageCtrl.page ?? 0);
      });

    // Trigger books loading via Bloc (returns void) and initialize local list.
    context.read<BookBloc>().add(LoadBooksEvent());
    _allBooks = [];
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Book> get _filteredBooks {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _allBooks.where((b) {
      final catOk =
          _selectedCategory == 'All' ||
          b.category.toLowerCase() == _selectedCategory.toLowerCase();
      final qOk =
          q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
      return catOk && qOk;
    }).toList();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _allBooks.shuffle();
    });
  }

  InputDecoration _glassInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 26 / 255),
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 64 / 255)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF2C94C), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final isSmall = width < 360;

    const colors = [
      Color(0xFF0D1B2A), // ink
      Color(0xFF233542), // slate
      Color(0xFF3A2F2A), // leather
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (_, __) {
          final t = Curves.easeInOut.transform(_bgController.value);
          final begin = Alignment.lerp(
            Alignment.bottomLeft,
            Alignment.topRight,
            t,
          )!;
          final end = Alignment.lerp(
            Alignment.topRight,
            Alignment.bottomLeft,
            t,
          )!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: colors,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: -80,
                  top: -60,
                  child: GlowCircle(size: 300, color: Color(0xFFF2C94C)),
                ),
                const Positioned(
                  right: -100,
                  bottom: -80,
                  child: GlowCircle(size: 360, color: Color(0xFFA1E3B5)),
                ),
                const Positioned(
                  right: -10,
                  top: 120,
                  child: GlowCircle(size: 180, color: Color(0xFFD9CBAA)),
                ),
                SafeArea(
                  child: RefreshIndicator(
                    color: const Color(0xFF0D1B2A),
                    backgroundColor: const Color(0xFFF2C94C),
                    onRefresh: _refresh,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(child: Header(context)),
                        SliverToBoxAdapter(child: _buildSearch()),
                        SliverToBoxAdapter(child: _buildCategories()),

                        SliverToBoxAdapter(
                          child: BlocBuilder<BookBloc, BookState>(
                            builder: (context, state) {
                              if (state is BooksLoaded) {
                                _allBooks = state.books;
                              } else if (state is BookLoadingInProgress) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFF2C94C),
                                    ),
                                  ),
                                );
                              } else if (state is BookOperationFailure) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Error: ${state.error}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return _buildFeatured(height);
                            },
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            media.padding.bottom + 100,
                          ),
                          sliver: BlocBuilder<BookBloc, BookState>(
                            builder: (context, state) {
                              if (state is BooksLoaded) {
                                _allBooks = state.books;
                              }else if (state is BookLoadingInProgress) {
                                return const SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: null
                                  ),
                                );
                              } else if (state is BookOperationFailure) {
                                return SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Error: ${state.error}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return _buildGrid(width, height, isSmall);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNav()),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white),
        decoration:
            _glassInputDecoration(
              hint: 'Search books, authors, topics',
              icon: Icons.search_rounded,
            ).copyWith(
              suffixIcon: _searchCtrl.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                    ),
            ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = _categories[i];
          final selected = label == _selectedCategory;
          return Category(
            label,
            selected,
            () => setState(() => _selectedCategory = label),
          );
        },
      ),
    );
  }

  Widget _buildFeatured(double screenHeight) {
    final featured = _allBooks.where((b) => b.isFeatured).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    final cardHeight = screenHeight.clamp(480.0, 900.0) * 0.26;

    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: featured.length,
        padEnds: false,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final book = featured[index];
          final delta = (_page - index).abs();
          final scale = 1 - (delta * 0.08);
          final translateY = 12.0 * delta;

          return Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: scale.clamp(0.9, 1.0),
              child: GestureDetector(
                onTap: () => _openQuickLook(book),
                child: GlassContainer(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: 8,
                    top: 10,
                    bottom: 14,
                  ),
                  borderRadius: 18,
                  blurSigma: 18,
                  color: Colors.white.withValues(alpha: 22 / 255),
                  borderColor: Colors.white.withValues(alpha: 56 / 255),
                  child: Row(
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                          child: CoverImage(url: book.coverUrl),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tag(
                                label: book.tag ?? 'Featured',
                                color: const Color(0xFFF2C94C),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Rating(rating: book.rating),
                              const Spacer(),
                              Text(
                                '\$${book.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFF2C94C),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverGrid _buildGrid(double width, double height, bool isSmall) {
    final data = _filteredBooks;

    // Adaptive columns for different device widths
    int crossAxisCount = 2;
    if (width >= 720) {
      crossAxisCount = 4;
    } else if (width >= 520) {
      crossAxisCount = 3;
    }

    // Adaptive item height to avoid overflow on small screens
    final itemHeight = (height / 3).clamp(230.0, 320.0);

    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final book = data[index];
        final fav = _favorites.contains(book.id);
        return GestureDetector(
          onTap: () => _openQuickLook(book),
          child: GlassContainer(
            borderRadius: 18,
            blurSigma: 16,
            color: Colors.white.withValues(alpha: 18 / 255),
            borderColor: Colors.white.withValues(alpha: 46 / 255),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CoverImage(url: book.coverUrl),
                        ),
                      ),
                      if (book.tag != null)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Tag(
                            label: book.tag!,
                            color: const Color(0xFFF2C94C),
                          ),
                        ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: GlassIconBtn(
                          icon: fav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          onTap: () {
                            setState(() {
                              if (fav) {
                                _favorites.remove(book.id);
                              } else {
                                _favorites.add(book.id);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: isSmall ? 13.5 : 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmall ? 11.5 : 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Rating(rating: book.rating, size: isSmall ? 13 : 14),
                    const Spacer(),
                    Text(
                      '\$${book.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFF2C94C),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }, childCount: data.length),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: itemHeight,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        borderRadius: 18,
        blurSigma: 20,
        color: Colors.white.withValues(alpha: 26 / 255),
        borderColor: Colors.white.withValues(alpha: 56 / 255),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: _navIndex == 0,
              onTap: () => setState(() {
                _navIndex = 0;
                Navigator.pushNamed(context, '/home');
              }),
            ),
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              selected: _navIndex == 1,
              onTap: () => setState(() {
                _navIndex = 1;
                Navigator.pushNamed(context, '/ChatPage');
              }),
            ),
            _NavItem(
              icon: Icons.cloud_upload_outlined,
              label: 'Upload',
              selected: _navIndex == 2,
              onTap: () => setState(() {
                _navIndex = 2;
                Navigator.pushNamed(context, '/UploadPage');
              }),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: _navIndex == 3,
              onTap: () => setState(() {
                _navIndex = 3;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserProfilePage(user: widget.user)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuickLook(Book book) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickLookSheet(
        book: book,
        onAddToCart: () {
            Navigator.of(context).pushReplacementNamed(
            "/ChatPage",
            arguments: {"bookTitle": book.title},
            );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('now you can chat about "${book.title}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  //   List<Book> _seedBooks() {
  //     return [
  //       Book(
  //         id: '1',
  //         title: 'The Midnight Library',
  //         author: 'Matt Haig',
  //         price: 12.99,
  //         rating: 4.6,
  //         category: 'Fiction',
  //         isFeatured: true,
  //         tag: 'Bestseller',
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1543007630-9710e4a00a20?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/the-midnight-library.pdf',
  //       ),
  //       Book(
  //         id: '2',
  //         title: 'Atomic Habits',
  //         author: 'James Clear',
  //         price: 14.50,
  //         rating: 4.8,
  //         category: 'Self Help',
  //         isFeatured: true,
  //         tag: 'Hot',
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/atomic-habits.pdf',
  //       ),
  //       Book(
  //         id: '3',
  //         title: 'Designing Interfaces',
  //         author: 'Jenifer Tidwell',
  //         price: 28.40,
  //         rating: 4.4,
  //         category: 'Design',
  //         isFeatured: false,
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1513475382585-d06e58bcb0ea?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/designing-interfaces.pdf',
  //       ),
  //       Book(
  //         id: '4',
  //         title: 'The Pragmatic Programmer',
  //         author: 'Andrew Hunt',
  //         price: 26.00,
  //         rating: 4.9,
  //         category: 'Business',
  //         isFeatured: true,
  //         tag: 'Editor\'s Pick',
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1526312426976-593c2d0b1a49?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/pragmatic-programmer.pdf',
  //       ),
  //       Book(
  //         id: '5',
  //         title: 'Dune',
  //         author: 'Frank Herbert',
  //         price: 18.20,
  //         rating: 4.7,
  //         category: 'Sci‑Fi',
  //         isFeatured: false,
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1541963463532-d68292c34b19?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/dune.pdf',
  //       ),
  //       Book(
  //         id: '6',
  //         title: 'Sapiens',
  //         author: 'Yuval Noah Harari',
  //         price: 16.30,
  //         rating: 4.5,
  //         category: 'History',
  //         isFeatured: false,
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/sapiens.pdf',
  //       ),
  //       Book(
  //         id: '7',
  //         title: 'Clean Architecture',
  //         author: 'Robert C. Martin',
  //         price: 24.90,
  //         rating: 4.6,
  //         category: 'Business',
  //         isFeatured: false,
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1528208079124-0fe4469a1f7f?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/clean-architecture.pdf',
  //       ),
  //       Book(
  //         id: '8',
  //         title: 'Neuromancer',
  //         author: 'William Gibson',
  //         price: 13.75,
  //         rating: 4.2,
  //         category: 'Sci‑Fi',
  //         isFeatured: false,
  //         coverUrl:
  //             'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=600&auto=format&fit=crop',
  //         bookUrl: 'https://example.com/books/neuromancer.pdf',
  //       ),
  //     ];
  //   }
  // }
}

// Network cover with graceful placeholder, loading, and error handling

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF2C94C) : Colors.white70;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
