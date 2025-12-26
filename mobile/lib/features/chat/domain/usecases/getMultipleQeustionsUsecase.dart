
import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/repositories/chat_repository.dart';

class GetMultipleQuestionsUseCase {
  final ChatRepository repository;

  GetMultipleQuestionsUseCase(this.repository);

  Future<Either<Failure, List<MultipleQuestions>>> call(String bookName) {
    return repository.getMultipleQuestions(bookName);
  }
}
