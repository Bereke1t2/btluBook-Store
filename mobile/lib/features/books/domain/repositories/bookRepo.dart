import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks(int page, int limit);
  Future<Either<Failure, Book>> getBook(String id);
  Future<Either<Failure, void>> uploadBook(Book book);
  Future<Either<Failure, void>> downloadBook(String id);
}