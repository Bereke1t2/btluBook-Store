import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';
import 'package:ethio_book_store/features/chat/domain/repositories/chat_repository.dart';


class GetTrueFalseUseCase {
  final ChatRepository repository;

  GetTrueFalseUseCase(this.repository);

  Future<Either<Failure, List<TrueFalse>>> call(String bookName) {
    return repository.getTrueFalseQuestion(bookName);
  }
}
