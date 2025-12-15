import 'package:bloc/bloc.dart';
import 'package:ethio_book_store/features/books/domain/usecases/downloadBook.dart';
import 'package:ethio_book_store/features/books/domain/usecases/getBook.dart';
import 'package:ethio_book_store/features/books/domain/usecases/getBooks.dart';
import 'package:ethio_book_store/features/books/domain/usecases/uploadBook.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/book.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooksUseCase getBooksUseCase;
  final GetBookUseCase getBookUseCase;
  final UploadBookUseCase uploadBookUseCase;
  final DownloadBookUseCase downloadBookUseCase;

  BookBloc({
    required this.getBooksUseCase,
    required this.getBookUseCase,
    required this.uploadBookUseCase,
    required this.downloadBookUseCase,
  }) : super(BookInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<AddBookEvent>(_onAddBook);
    // on<DiscussAboutTheBook>(_onDiscussAboutTheBook);
    // on<SearchBooksEvent>(_onSearchBooks);
  }
  Future<void> _onLoadBooks(
    LoadBooksEvent event, Emitter<BookState> emit) async {
    emit(BookLoadingInProgress());
    print("Loading books...");
    final result = await getBooksUseCase(1, 20);
    print("books are loeaded or faild");
    result.fold(
      (failure) => emit(BookOperationFailure(failure.message)),
      (books) => emit(BooksLoaded(books)),
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
  
}