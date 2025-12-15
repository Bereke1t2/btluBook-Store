
import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';

class GetBooksUseCase {
  final BookRepository repository;
  GetBooksUseCase({required this.repository});
  Future<Either<Failure, List<Book>>> call(int page , int limit) {
    return repository.getBooks(page, limit);
  }
}