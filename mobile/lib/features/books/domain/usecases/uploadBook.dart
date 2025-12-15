import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';

class UploadBookUseCase {
  final BookRepository repository;
  UploadBookUseCase({required this.repository});
  Future<Either<Failure, void>> call(Book book) {
    return repository.uploadBook(book);
  }
}