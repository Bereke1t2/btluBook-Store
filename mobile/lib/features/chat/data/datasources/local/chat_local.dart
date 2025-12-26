import 'package:ethio_book_store/features/books/data/local_database/app_database.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheChatResponse(String response);
  Future<String> getLastChatResponse();

  Future<void> cacheTrueFalseQuestion(List<TrueFalse> question);
  Future<List<TrueFalse>> getLastTrueFalseQuestion();

  Future<void> cacheMultipleQuestions(List<MultipleQuestions> questions);
  Future<List<MultipleQuestions>> getLastMultipleQuestions();

  Future<void> cacheShortAnswerQuestion(List<ShortAnswer> question);
  Future<List<ShortAnswer>> getLastShortAnswerQuestion();
}


class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final AppDatabase database;
  ChatLocalDataSourceImpl(this.database);
  // Implement the methods to fetch data from local storage
  @override
  Future<void> cacheChatResponse(String response) async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<String> getLastChatResponse() async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<void> cacheTrueFalseQuestion(List<TrueFalse> question) async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<List<TrueFalse>> getLastTrueFalseQuestion() async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<void> cacheMultipleQuestions(List<MultipleQuestions> questions) async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<List<MultipleQuestions>> getLastMultipleQuestions() async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<void> cacheShortAnswerQuestion(List<ShortAnswer> question) async {
    // Implementation goes here
    throw UnimplementedError();
  }

  @override
  Future<List<ShortAnswer>> getLastShortAnswerQuestion() async {
    // Implementation goes here
    throw UnimplementedError();
  }
}
