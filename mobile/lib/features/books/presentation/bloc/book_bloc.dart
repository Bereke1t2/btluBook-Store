import 'package:bloc/bloc.dart';
import 'package:ethio_book_store/features/books/domain/usecases/downloadBook.dart';
import 'package:ethio_book_store/features/books/domain/usecases/getBook.dart';
import 'package:ethio_book_store/features/books/domain/usecases/getBooks.dart';
import 'package:ethio_book_store/features/books/domain/usecases/uploadBook.dart';
import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/download_update.dart';

import '../../domain/entities/book.dart';

import 'package:ethio_book_store/features/books/domain/usecases/get_downloaded_books.dart';
import 'package:ethio_book_store/features/books/domain/usecases/update_reading_progress.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooksUseCase getBooksUseCase;
  final GetBookUseCase getBookUseCase;
  final UploadBookUseCase uploadBookUseCase;
  final DownloadBookUseCase downloadBookUseCase;
  final GetDownloadedBooksUseCase getDownloadedBooksUseCase; // Added
  final UpdateReadingProgressUseCase updateReadingProgressUseCase; // Added

  BookBloc({
    required this.getBooksUseCase,
    required this.getBookUseCase,
    required this.uploadBookUseCase,
    required this.downloadBookUseCase,
    required this.getDownloadedBooksUseCase,
    required this.updateReadingProgressUseCase,
  }) : super(BookInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<AddBookEvent>(_onAddBook);
    on<DownloadBookEvent>(_onDownloadBook);
    on<LoadDownloadedBooksEvent>(_onLoadDownloadedBooks); // Added
    on<UpdateReadingProgressEvent>(_onUpdateReadingProgress); // Added
    // on<DiscussAboutTheBook>(_onDiscussAboutTheBook);
    // on<SearchBooksEvent>(_onSearchBooks);
  }
  Future<Map<String, String>> _getDownloadedBooksMap() async {
    final downloadedResult = await getDownloadedBooksUseCase();
    return downloadedResult.fold(
      (_) => <String, String>{},
      (books) => {for (var b in books) b.id: b.bookUrl},
    );
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event, Emitter<BookState> emit) async {
    emit(BookLoadingInProgress());
    final result = await getBooksUseCase(1, 20);
    final downloadedMap = await _getDownloadedBooksMap();
    
    result.fold(
      (failure) => emit(BookOperationFailure(failure.message)),
      (books) => emit(BooksLoaded(books, downloadedBooks: downloadedMap)),
    );
  }

  Future<void> _onAddBook(
    AddBookEvent event, Emitter<BookState> emit) async {
    emit(BookAddingInProgress());
    final result = await uploadBookUseCase(event.book);
    result.fold(
      (failure) {
        emit(BookOperationFailure(failure.message));
        emit(BookInitial());
      },
      (_) => emit(BookAddedSuccessfully()),
    );
  }

  Future<void> _onDownloadBook(
    DownloadBookEvent event, Emitter<BookState> emit) async {
    // Preserve current books if we are in BooksLoaded state
    List<Book>? currentBooks;
    Map<String, String> downloadedMap = <String, String>{};
    if (state is BooksLoaded) {
      currentBooks = (state as BooksLoaded).books;
      downloadedMap = Map.from((state as BooksLoaded).downloadedBooks);
    }

    emit(BookDownloading(event.bookId));

    try {
      await emit.forEach<Either<Failure, DownloadUpdate>>(
        downloadBookUseCase(event.bookId),
        onData: (result) {
          return result.fold(
            (failure) {
              return BookOperationFailure(failure.message);
            },
            (update) {
              if (update.isCompleted) {
                // Add to downloaded IDs locally so it updates immediately when we restore state
                downloadedMap[event.bookId] = update.bookPath!;
                return BookDownloadSuccess(update.bookPath!, event.bookId);
              }
              return BookDownloadProgress(event.bookId, update.progress);
            },
          );
        },
      );
      
      if (currentBooks != null) {
        emit(BooksLoaded(currentBooks, downloadedBooks: downloadedMap));
      } else {
        // If we didn't have current books (e.g. from Details page directly), 
        // we might want to refresh the list or just go back to Initial/Loaded
        add(LoadBooksEvent());
      }
    } catch (e) {
      emit(BookOperationFailure(e.toString()));
      if (currentBooks != null) emit(BooksLoaded(currentBooks, downloadedBooks: downloadedMap));
    }
  }

  Future<void> _onLoadDownloadedBooks(
    LoadDownloadedBooksEvent event, Emitter<BookState> emit) async {
    emit(BookLoadingInProgress());
    final result = await getDownloadedBooksUseCase();
    result.fold(
      (failure) => emit(BookOperationFailure(failure.message)),
      (books) {
        final map = {for (var b in books) b.id: b.bookUrl};
        emit(BooksLoaded(books, downloadedBooks: map));
      },
    );
  }

  Future<void> _onUpdateReadingProgress(
    UpdateReadingProgressEvent event, Emitter<BookState> emit) async {
    // Fire and forget, or handle error silently?
    await updateReadingProgressUseCase(event.bookId, event.page, event.totalPages);
    // Don't emit state to avoid rebuilding UI unexpectedly during reading
  }
}