import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';

class UpdateReadingProgressUseCase {
  final BookRepository repository;

  UpdateReadingProgressUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, int page, int totalPages) async {
    return await repository.updateReadingProgress(id, page, totalPages);
  }
}
