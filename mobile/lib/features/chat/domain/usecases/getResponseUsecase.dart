import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/domain/repositories/chat_repository.dart';

class GetChatResponseUseCase {
  final ChatRepository repository;

  GetChatResponseUseCase(this.repository);

  Future<Either<Failure, String>> call(String prompt , String bookName) {
    return repository.getChatResponse(prompt , bookName);
  }
}
