import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';

class GetDownloadedBooksUseCase {
  final BookRepository repository;

  GetDownloadedBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getDownloadedBooks();
  }
}
