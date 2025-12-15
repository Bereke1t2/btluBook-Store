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