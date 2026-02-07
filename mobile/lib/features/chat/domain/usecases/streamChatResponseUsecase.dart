import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/domain/repositories/chat_repository.dart';

class StreamChatResponseUseCase {
  final ChatRepository repository;

  StreamChatResponseUseCase(this.repository);

  Stream<Either<Failure, String>> call(String prompt, String bookName) {
    return repository.streamChatResponse(prompt, bookName);
  }
}
