import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/repositories/chat_repository.dart';


class GetShortAnswerUseCase {
  final ChatRepository repository;

  GetShortAnswerUseCase(this.repository);

  Future<Either<Failure, List<ShortAnswer>>> call(String bookName) {
    return repository.getShortAnswerQuestion(bookName);
  }
}
