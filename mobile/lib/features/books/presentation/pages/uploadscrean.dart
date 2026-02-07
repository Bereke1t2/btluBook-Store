import 'dart:io';
import 'dart:ui' as ui;
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ethio_book_store/core/const/url_const.dart';

// -----------------------------------------------------------------------------
// 1. MAIN PAGE
// -----------------------------------------------------------------------------

class UploadBookPage extends StatefulWidget {
  const UploadBookPage({super.key});

  @override
  State<UploadBookPage> createState() => _UploadBookPageState();
}

class _UploadBookPageState extends State<UploadBookPage>
    with SingleTickerProviderStateMixin {
  // --- Theming Colors ---
  static const _gold = Color(0xFFF2C94C);

  // --- Controllers ---
  late final AnimationController _bgController;
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _sharedByCtrl = TextEditingController(); // New: Matches entity
  final _tagCtrl = TextEditingController(); // New: Matches entity
  final _priceCtrl = TextEditingController();
  final _bookUrlCtrl = TextEditingController(); // Replaces pdfUrl
  final _coverCtrl = TextEditingController(); // Persistent controller for cover

  // --- State Variables ---
  String? _coverUrl;
  String _category = 'Fiction';
  bool _isFree = false;
  bool _isFeatured = false;

  // --- Data Lists ---
  static const _categories = <String>[
    'Fiction',
    'Non‑fiction',
    'Romance',
    'Technology',
    'Kids',
    'Business',
    'Fantasy',
    'Biography',
    'Academic',
  ];

  @override
  void initState() {
    super.initState();
    // Default logged in user
    _sharedByCtrl.text = "Admin";
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _sharedByCtrl.dispose();
    _priceCtrl.dispose();
    _bookUrlCtrl.dispose();
    _coverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true, // Prevents keyboard overflow
      body: Stack(
        children: [
          // 1. Modularized Background
          AnimatedBackground(controller: _bgController),

          // 2. Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HeaderBar(
                    onBack: () => Navigator.maybePop(context),
                    onPresets: _showCoverPresets,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: CoverPreviewCard(
                      title: _titleCtrl.text,
                      author: _authorCtrl.text,
                      category: _category,
                      coverUrl: _coverUrl,
                      price: _isFree ? "FREE" : _priceCtrl.text,
                      onClear: () => setState(() => _coverUrl = null),
                      onEdit: _showCoverUrlInput,
                    ),
                  ),
                ),

                // --- Form Section: Basic Info ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SectionWrapper(
                        icon: Icons.menu_book_rounded,
                        title: 'Book Details',
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GlassTextField(
                                    controller: _titleCtrl,
                                    hint: 'Title',
                                    icon: Icons.title_rounded,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GlassTextField(
                                    controller: _authorCtrl,
                                    hint: 'Author',
                                    icon: Icons.person_rounded,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GlassTextField(
                              controller: _sharedByCtrl,
                              hint: 'Shared By (Uploader)',
                              icon: Icons.badge_rounded,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GlassDropdown<String>(
                                    value: _category,
                                    items: _categories,
                                    icon: Icons.category_rounded,
                                    onChanged: (v) => setState(
                                      () => _category = v ?? _category,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GlassTextField(
                                    controller: _tagCtrl,
                                    hint: 'Tag (Optional)',
                                    icon: Icons.label_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // --- Form Section: Pricing ---
                      SectionWrapper(
                        icon: Icons.monetization_on_rounded,
                        title: 'Pricing & Status',
                        child: Column(
                          children: [
                            GlassSwitch(
                              label: 'Free Book',
                              value: _isFree,
                              onChanged: (v) => setState(() {
                                _isFree = v;
                                if (v) _priceCtrl.clear();
                              }),
                            ),
                            const SizedBox(height: 8),
                            if (!_isFree) ...[
                              GlassTextField(
                                controller: _priceCtrl,
                                hint: 'Price',
                                icon: Icons.attach_money_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                            ],
                            GlassSwitch(
                              label: 'Feature on Home',
                              value: _isFeatured,
                              onChanged: (v) => setState(() => _isFeatured = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // --- Form Section: Assets ---
                      SectionWrapper(
                        icon: Icons.cloud_upload_rounded,
                        title: 'Assets',
                        child: Column(
                            children: [
                            GlassTextField(
                              controller: _bookUrlCtrl,
                              hint: 'Select Book/PDF file',
                              icon: Icons.insert_drive_file_rounded,
                              readOnly: true,
                              onTap: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'epub'],
                                withData: false,
                              );
                              if (result != null) {
                                final path = result.files.single.path;
                                if (path != null) {
                                setState(() {
                                  _bookUrlCtrl.text = path;
                                });
                                }
                              }
                              },
                            ),
                            const SizedBox(height: 12),
                            GlassTextField(
                              controller: _coverCtrl,
                              hint: 'Pick Cover Image (Gallery or File)',
                              icon: Icons.image_rounded,
                              readOnly: true,
                              onTap: () async {
                                // Requires:
                                //   image_picker: ^1.x
                                //   import 'package:image_picker/image_picker.dart';
                                //   import 'package:file_picker/file_picker.dart';
                                final choice = await showModalBottomSheet<String>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => GlassContainer(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Select Source',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GlassButton(
                                                label: 'Gallery',
                                                icon: Icons.photo_library_rounded,
                                                onTap: () => Navigator.pop(context, 'gallery'),
                                                isPrimary: true,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: GlassButton(
                                                label: 'Files',
                                                icon: Icons.folder_rounded,
                                                onTap: () => Navigator.pop(context, 'files'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                                String? pickedPath;
                                try {
                                  if (choice == 'gallery') {
                                    final picker = ImagePicker();
                                    final xfile = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );
                                    pickedPath = xfile?.path;
                                  } else if (choice == 'files') {
                                    final result = await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                      withData: false,
                                    );
                                    pickedPath = result?.files.single.path;
                                  }
                                } catch (e) {
                                  _showToast('Failed to pick image: $e');
                                }

                                if (pickedPath != null) {
                                  setState(() {
                                    _coverUrl = pickedPath;
                                    _coverCtrl.text = pickedPath!;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Action Buttons ---
                      // --- Action Buttons ---
                      BlocConsumer<BookBloc, BookState>(
                        listener: (context, state) {
                          if (state is BookAddedSuccessfully) {
                            _showToast('Book uploaded successfully!');
                            Navigator.pop(context);
                          } else if (state is BookOperationFailure) {
                            _showToast('Error: ${state.error}');
                          }
                        },
                        builder: (context, state) {
                          if (state is BookAddingInProgress) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: _gold,
                              ),
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: GlassButton(
                                    label: 'Cancel',
                                    onTap: () => Navigator.pop(context),
                                    isPrimary: false,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GlassButton(
                                    label: 'Upload Book',
                                    icon: Icons.check_circle_rounded,
                                    onTap: _submitUpload,
                                    isPrimary: true,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: media.padding.bottom + 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );  
  }

  // --- Logic Methods ---

  void _submitUpload() {
    // 1. Validation
    if (_titleCtrl.text.isEmpty || _authorCtrl.text.isEmpty) {
      _showToast('Title and Author are required.');
      return;
    }
    if (_bookUrlCtrl.text.isEmpty) {
      _showToast('Please provide a Book/PDF URL.');
      return;
    }
    if (_coverUrl == null || _coverUrl!.isEmpty) {
      _showToast('Please select a cover image.');
      return;
    }

    final price = _isFree ? 0.0 : double.tryParse(_priceCtrl.text) ?? 0.0;

    // 2. Create Entity (Matches your provided Book class)
    // Note: ID would typically be generated by DB or UUID
    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      price: price,
      rating: 0.0, // Default for new books
      category: _category,
      isFeatured: _isFeatured,
      tag: _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
      coverUrl: _coverUrl!,
      sharedBy: _sharedByCtrl.text.trim(),
      bookUrl: _bookUrlCtrl.text.trim(),
    );
    context.read<BookBloc>().add(AddBookEvent(newBook));
  }

  void _showCoverPresets() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CoverPickerSheet(
        onSelect: (url) {
          setState(() => _coverUrl = url);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCoverUrlInput() {
    final c = TextEditingController(text: _coverUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassContainer(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassTextField(
                controller: c,
                hint: 'Paste Image URL',
                icon: Icons.link,
              ),
              const SizedBox(height: 12),
              GlassButton(
                label: 'Apply',
                isPrimary: true,
                onTap: () {
                  setState(() => _coverUrl = c.text);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF233542),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. MODULARIZED WIDGETS
// -----------------------------------------------------------------------------

class SectionWrapper extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SectionWrapper({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        GlassContainer(padding: const EdgeInsets.all(16), child: child),
      ],
    );
  }
}

class HeaderBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onPresets;

  const HeaderBar({super.key, required this.onBack, required this.onPresets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          _IconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Upload Book',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _IconButton(icon: Icons.photo_library_rounded, onTap: onPresets),
        ],
      ),
    );
  }
}

class CoverPreviewCard extends StatelessWidget {
  final String title;
  final String author;
  final String category;
  final String price;
  final String? coverUrl;
  final VoidCallback onClear;
  final VoidCallback onEdit;

  const CoverPreviewCard({
    super.key,
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    required this.coverUrl,
    required this.onClear,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 120,
              color: Colors.black26,
              child: coverUrl == null
                  ? const Icon(Icons.image_not_supported, color: Colors.white24)
                  : (coverUrl!.startsWith('http') || coverUrl!.startsWith('/uploads'))
                      ? Image.network(
                          coverUrl!.startsWith('http') 
                              ? coverUrl! 
                              : "${UrlConst.baseUrl}${coverUrl!.startsWith('/') ? '' : '/'}$coverUrl",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, color: Colors.white24),
                        )
                      : Image.file(
                          File(coverUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, color: Colors.white24),
                        ),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.isEmpty ? 'Untitled' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author.isEmpty ? 'Unknown Author' : author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniTag(label: category),
                    _MiniTag(label: price, isPrice: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Color(0xFFF2C94C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onClear,
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. UI PRIMITIVES (GLASS STYLE)
// -----------------------------------------------------------------------------

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color color;
  final Color borderColor;

  const GlassContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.color = const Color(0x1AFFFFFF),
    this.borderColor = const Color(0x33FFFFFF), // default ~20% white
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF2C94C), width: 1),
        ),
      ),
    );
  }
}

class GlassDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final IconData icon;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(icon, color: Colors.white70, size: 20),
          dropdownColor: const Color(0xFF233542),
          style: const TextStyle(color: Colors.white),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class GlassSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const GlassSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFF2C94C),
          activeTrackColor: Colors.black,
        ),
      ],
    );
  }
}

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? const Color(0xFFF2C94C)
          : Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: isPrimary
              ? null
              : BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(14),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isPrimary ? Colors.black : Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: GlassContainer(
        borderRadius: 50,
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final bool isPrice;
  const _MiniTag({required this.label, this.isPrice = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrice ? const Color(0xFFF2C94C) : Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrice ? Colors.black : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. BACKGROUND & EXTRAS
// -----------------------------------------------------------------------------

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const AnimatedBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(controller.value);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.lerp(
                Alignment.bottomLeft,
                Alignment.topRight,
                t,
              )!,
              end: Alignment.lerp(Alignment.topRight, Alignment.bottomLeft, t)!,
              colors: const [
                Color(0xFF0D1B2A),
                Color(0xFF233542),
                Color(0xFF3A2F2A),
              ],
            ),
          ),
          child: Stack(
            children: const [
              Positioned(
                left: -80,
                top: -60,
                child: _GlowCircle(color: Color(0xFFF2C94C), size: 280),
              ),
              Positioned(
                right: -90,
                bottom: -60,
                child: _GlowCircle(color: Color(0xFFA1E3B5), size: 330),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class CoverPickerSheet extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const CoverPickerSheet({super.key, required this.onSelect});

  static const _presets = [
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=480&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=480&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=480&auto=format&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Preset",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => onSelect(_presets[i]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _presets[i],
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
