import 'package:ethio_book_store/core/const/app_typography.dart';
import 'package:ethio_book_store/core/const/ui_const.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/note_bloc.dart';
import '../../data/models/note_model.dart';

class NotesPage extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const NotesPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _aiTextController = TextEditingController();
  String _token = '';

  // Animated background
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: UiConst.durationBackground,
    )..repeat(reverse: true);
    _loadTokenAndNotes();
  }

  Future<void> _loadTokenAndNotes() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    if (mounted) {
      context.read<NoteBloc>().add(LoadNotes(bookId: widget.bookId, token: _token));
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _noteController.dispose();
    _aiTextController.dispose();
    super.dispose();
  }

  void _showAddNoteDialog() {
    final noteBloc = context.read<NoteBloc>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Note',
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: GlassContainer(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add Note', style: AppTypography.headlineSmall),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Type your note here...',
                        hintStyle: AppTypography.hint,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedButton(
                            label: 'Save',
                            isPrimary: true,
                            onTap: () {
                              if (_noteController.text.isNotEmpty) {
                                noteBloc.add(CreateNote(
                                      bookId: widget.bookId,
                                      content: _noteController.text,
                                      token: _token,
                                    ));
                                _noteController.clear();
                                Navigator.pop(context);
                              }
                            },
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
      },
    );
  }

  void _showAIDialog() {
    final noteBloc = context.read<NoteBloc>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AI Summary',
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: GlassContainer(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: UiConst.amber, size: 24),
                        const SizedBox(width: 10),
                        Text('AI Summary', style: AppTypography.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Paste text from the book to generate an AI summary or insights.',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _aiTextController,
                      maxLines: 6,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Paste content here...',
                        hintStyle: AppTypography.hint,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedButton(
                            label: 'Generate',
                            icon: Icons.auto_awesome,
                            isPrimary: true,
                            onTap: () {
                              if (_aiTextController.text.isNotEmpty) {
                                noteBloc.add(GenerateAINote(
                                      bookId: widget.bookId,
                                      text: _aiTextController.text,
                                      token: _token,
                                    ));
                                _aiTextController.clear();
                                Navigator.pop(context);
                              }
                            },
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                const Positioned(
                  left: -50,
                  top: 100,
                  child: _DecorativeCircle(size: 200, color: UiConst.glowAmber),
                ),
                const Positioned(
                  right: -80,
                  bottom: 100,
                  child: _DecorativeCircle(size: 300, color: UiConst.glowSage),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: BlocConsumer<NoteBloc, NoteState>(
                          listener: (context, state) {
                            if (state is NoteError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message), 
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: UiConst.error,
                                ),
                              );
                            }
                            if (state is AINotePending) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('AI is analyzing content...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            if (state is AINoteDone) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Note added successfully!'), 
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: UiConst.sage,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is NoteLoading) {
                              return const Center(child: CircularProgressIndicator(color: UiConst.amber));
                            }
                            if (state is NoteLoaded) {
                              if (state.notes.isEmpty) {
                                return _buildEmptyState();
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.notes.length,
                                itemBuilder: (context, index) {
                                  final note = state.notes[index];
                                  return _NoteCard(
                                    note: note,
                                    onDelete: () {
                                      context.read<NoteBloc>().add(DeleteNote(
                                            noteId: note.id,
                                            bookId: widget.bookId,
                                            token: _token,
                                          ));
                                    },
                                  );
                                },
                              );
                            }
                            return const SizedBox.shrink();
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'ai',
            onPressed: _showAIDialog,
            backgroundColor: UiConst.amber,
            foregroundColor: Colors.black,
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showAddNoteDialog,
            backgroundColor: UiConst.slate,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiConst.radiusMedium)),
            child: const Icon(Icons.add_rounded, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reading Notes', style: AppTypography.headlineSmall),
                Text(
                  widget.bookTitle,
                  style: AppTypography.bodySmall.copyWith(color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note_rounded, size: 100, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 24),
            Text(
              'Capture your thoughts',
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add personal notes or use AI to summarize key sections of the book.',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (note.isAiGenerated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: UiConst.brandGradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.auto_awesome, size: 12, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'AI Summary',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Personal Note',
                    style: AppTypography.labelSmall.copyWith(color: UiConst.amber),
                  ),
                const Spacer(),
                Text(
                  _formatDate(note.createdAt),
                  style: AppTypography.labelSmall.copyWith(color: Colors.white24),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_sweep_outlined, size: 20, color: UiConst.error.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              style: AppTypography.bodyMedium.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}
