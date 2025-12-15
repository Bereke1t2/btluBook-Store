import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';

class DownloadBookUseCase {
  final BookRepository repository;
  DownloadBookUseCase({required this.repository});
  Future<Either<Failure, void>> call(String id) {
    return repository.downloadBook(id);
  }
}