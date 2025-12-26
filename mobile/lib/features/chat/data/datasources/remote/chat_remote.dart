import 'package:ethio_book_store/app/app.dart';
import 'package:ethio_book_store/features/auth/data/datasources/local/localdata.dart';
import 'package:ethio_book_store/features/books/data/local_database/app_database.dart';
import 'package:ethio_book_store/features/chat/data/datasources/local/chat_local.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';
import 'package:ethio_book_store/features/chat/data/models/short_answer_model.dart';
import 'package:ethio_book_store/features/chat/data/models/true_false_model.dart';
import 'package:ethio_book_store/features/chat/data/models/multiple_questions_model.dart';
import 'package:http/http.dart' as http;

abstract class ChatRemoteDataSource {
  Future<String> getChatResponse(String prompt);
  Future<List<TrueFalse>> getTrueFalseQuestion(String bookName);
  Future<List<MultipleQuestions>> getMultipleQuestions(String bookName);
  Future<List<ShortAnswer>> getShortAnswerQuestion(String bookName);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final LocalData localData;
  final ChatLocalDataSource localDataSource;
  final http.Client client;

  ChatRemoteDataSourceImpl(this.localData, this.localDataSource, this.client);

  static const Duration _delayDuration = Duration(seconds: 30);
  Future<void> _delay() => Future.delayed(_delayDuration);

  @override
  Future<String> getChatResponse(String prompt) async {
    await _delay();
    return "the book is good and i love it";
  }

  @override
  Future<List<TrueFalse>> getTrueFalseQuestion(String bookName) async {
    await _delay();
    return [
      TrueFalseModel(
        question: "The book $bookName is set in Ethiopia.",
        answer: "True",
        explanation: "Most chapters reference locations in Ethiopia.",
      ),
      TrueFalseModel(
        question: "The main character is a historian.",
        answer: "False",
        explanation: "They are introduced as a university student in chapter 1.",
      ),
      TrueFalseModel(
        question: "Chapter 3 describes a journey to Addis Ababa.",
        answer: "True",
        explanation: "A trip to Addis Ababa is detailed in chapter 3.",
      ),
    ];
  }

  @override
  Future<List<MultipleQuestions>> getMultipleQuestions(String bookName) async {
    await _delay();
    return [
      MultipleQuestionsModel(
        question: "What is the central theme of $bookName?",
        options: [
          "Friendship and loyalty",
          "Space exploration",
          "Cooking and recipes",
          "Medieval warfare",
        ],
        correctIndex: 0,
        explanations:
            "The story consistently focuses on bonds between characters.",
      ),
      MultipleQuestionsModel(
        question: "Which city is prominently featured in the story?",
        options: ["Nairobi", "Addis Ababa", "Cairo", "Lagos"],
        correctIndex: 1,
        explanations:
            "Several key events occur in Addis Ababa across multiple chapters.",
      ),
      MultipleQuestionsModel(
        question: "Who mentors the protagonist?",
        options: ["A neighbor", "A professor", "A cousin", "A journalist"],
        correctIndex: 1,
        explanations:
            "The professor provides guidance and resources throughout the book.",
      ),
    ];
  }

  @override
  Future<List<ShortAnswer>> getShortAnswerQuestion(String bookName) async {
    await _delay();
    return [
      ShortAnswerModel(
        question: "Summarize the conflict faced by the protagonist.",
        answer:
            "Balancing academic pressure with personal responsibilities and identity.",
        explanation:
            "This is revealed through interactions with family and peers.",
      ),
      ShortAnswerModel(
        question: "What motivates the main character to continue their journey?",
        answer: "A desire to uncover the truth and help their community.",
        explanation:
            "Motivations are reinforced by challenges and mentor guidance.",
      ),
      ShortAnswerModel(
        question: "Describe the significance of the opening scene.",
        answer:
            "It sets the tone, introduces the stakes, and foreshadows key events.",
        explanation:
            "Symbols in the scene reappear as motifs later in the story.",
      ),
    ];
  }
}