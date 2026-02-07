part of 'book_bloc.dart';

@immutable
sealed class BookEvent {}

class LoadBooksEvent extends BookEvent {}
class AddBookEvent extends BookEvent {
  final Book book;

  AddBookEvent(this.book);
}

class DiscussAboutTheBook extends BookEvent {
  final String bookId;

  DiscussAboutTheBook(this.bookId);
}
class SearchBooksEvent extends BookEvent {
  final String query;

  SearchBooksEvent(this.query);
}

class DownloadBookEvent extends BookEvent {
  final String bookId;
  DownloadBookEvent(this.bookId);
}

class LoadDownloadedBooksEvent extends BookEvent {}

class UpdateReadingProgressEvent extends BookEvent {
  final String bookId;
  final int page;
  final int totalPages;

  UpdateReadingProgressEvent({
    required this.bookId,
    required this.page,
    required this.totalPages,
  });
}