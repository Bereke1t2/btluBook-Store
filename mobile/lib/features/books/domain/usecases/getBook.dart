
import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';

class GetBookUseCase {
  final BookRepository repository;
  GetBookUseCase({required this.repository});
  Future<Either<Failure, Book>> call(String id) {
    return repository.getBook(id);
  }
}