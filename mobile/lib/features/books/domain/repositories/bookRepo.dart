import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/domain/entities/download_update.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks(int page, int limit);
  Future<Either<Failure, Book>> getBook(String id);
  Future<Either<Failure, void>> uploadBook(Book book);
  Stream<Either<Failure, DownloadUpdate>> downloadBook(String id);

  Future<Either<Failure, void>> updateReadingProgress(String id, int page, int totalPages);
  Future<Either<Failure, List<Book>>> getDownloadedBooks();
}