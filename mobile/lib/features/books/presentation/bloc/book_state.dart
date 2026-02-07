part of 'book_bloc.dart';

@immutable
sealed class BookState {}

final class BookInitial extends BookState {}

class BooksLoaded extends BookState {
  final List<Book> books;
  final Map<String, String> downloadedBooks; // id -> local path

  BooksLoaded(this.books, {this.downloadedBooks = const {}});
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

class BookDownloading extends BookState {
  final String bookId;
  BookDownloading(this.bookId);
}
class BookDownloadProgress extends BookState {
  final String bookId;
  final double progress;
  BookDownloadProgress(this.bookId, this.progress);
}
class BookDownloadSuccess extends BookState {
  final String path;
  final String bookId;
  BookDownloadSuccess(this.path, this.bookId);
}
