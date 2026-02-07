import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';
import 'package:ethio_book_store/features/books/domain/entities/download_update.dart';

class DownloadBookUseCase {
  final BookRepository repository;
  DownloadBookUseCase({required this.repository});
  Stream<Either<Failure, DownloadUpdate>> call(String id) {
    return repository.downloadBook(id);
  }
}