import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';

abstract class ChatRepository {
  Future<Either<Failure , List<MultipleQuestions>>> getMultipleQuestions(String BookName );
  Future<Either<Failure , List<TrueFalse>>> getTrueFalseQuestion(String BookName );
  Future<Either<Failure , List<ShortAnswer>>> getShortAnswerQuestion(String BookName );
  Future<Either<Failure , String>> getChatResponse(String prompt , String BookName );
}