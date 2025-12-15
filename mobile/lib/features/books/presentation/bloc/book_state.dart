part of 'book_bloc.dart';

@immutable
sealed class BookState {}

final class BookInitial extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;

  BooksLoaded(this.books);
}
class BookLoadingInProgress extends BookState {}
class BookOperationFailure extends BookState {
  final String error;

  BookOperationFailure(this.error);
}

class BookAddingInProgress extends BookState {}
class BookAddedSuccessfully extends BookState {
}
// class BookDiscussionLoaded extends BookState {
//   final List<Message> messages;

//   BookDiscussionLoaded(this.messages);
// }
