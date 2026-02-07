import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:ethio_book_store/core/const/ui_const.dart';
import 'package:ethio_book_store/core/const/app_typography.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/GlassContainer.dart';
import 'package:ethio_book_store/features/books/presentation/widgets/animated_button.dart';
import 'package:ethio_book_store/features/notes/presentation/bloc/note_bloc.dart';
import 'package:ethio_book_store/injections.dart' as di;
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:ethio_book_store/features/auth/data/datasources/local/localdata.dart';

class PDFReaderPage extends StatefulWidget {
  final String filePath;
  final String bookId;
  final String bookTitle;
  final int initialPage;

  const PDFReaderPage({
    super.key,
    required this.filePath,
    required this.bookId,
    required this.bookTitle,
    this.initialPage = 0,
  });

  @override
  State<PDFReaderPage> createState() => _PDFReaderPageState();
}

class _PDFReaderPageState extends State<PDFReaderPage> {
  int _totalPages = 0;
  late int _currentPage;
  bool _isReady = false;
  String _errorMessage = '';
  late PDFViewController _pdfViewController;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The PDF Viewer
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
              context.read<BookBloc>().add(UpdateReadingProgressEvent(
                bookId: widget.bookId,
                page: page! + 1,
                totalPages: total ?? _totalPages,
              ));
            },
          ),

          // Custom Premium Header
          _buildPremiumHeader(),

          if (!_isReady)
            const Center(
              child: CircularProgressIndicator(color: UiConst.amber),
            ),

          if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  _errorMessage, 
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: UiConst.error),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: UiConst.slate,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        child: const Icon(Icons.edit_note_rounded, size: 28),
        onPressed: () => _showAddNoteBottomSheet(context),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookTitle,
                      style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_isReady)
                      Text(
                        'Page ${_currentPage + 1} of $_totalPages',
                        style: AppTypography.labelSmall.copyWith(color: Colors.white54),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_isReady)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${((_currentPage + 1) / _totalPages * 100).toInt()}%',
                    style: AppTypography.labelSmall.copyWith(color: UiConst.amber),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteBottomSheet(BuildContext context) {
    final noteController = TextEditingController();
    final noteBloc = context.read<NoteBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Note', style: AppTypography.headlineSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: UiConst.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: UiConst.amber.withOpacity(0.2)),
                    ),
                    child: Text('Page ${_currentPage + 1}', style: AppTypography.labelMedium.copyWith(color: UiConst.amber)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: noteController,
                autofocus: true,
                cursorColor: UiConst.amber,
                style: AppTypography.bodyMedium,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts on this page...',
                  hintStyle: AppTypography.hint,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: UiConst.amber, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedButton(
                label: 'Save Note',
                isPrimary: true,
                onTap: () async {
                  if (noteController.text.isNotEmpty) {
                    final noteContent = "Page ${_currentPage + 1}: ${noteController.text}";
                    final token = await di.sl<LocalData>().getToken();
                    
                    if (token != null && context.mounted) {
                      noteBloc.add(CreateNote(
                        content: noteContent,
                        bookId: widget.bookId,
                        token: token,
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Note added to your collection'),
                          backgroundColor: UiConst.sage,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please login to add notes')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
