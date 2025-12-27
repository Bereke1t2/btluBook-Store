import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/connection/network.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/chat/data/datasources/local/chat_local.dart';
import 'package:ethio_book_store/features/chat/data/datasources/remote/chat_remote.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';
import 'package:ethio_book_store/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, String>> getChatResponse(String prompt , String bookName) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteResponse = await remoteDataSource.getChatResponse(prompt , bookName);
        localDataSource.cacheChatResponse(remoteResponse);
        return Right(remoteResponse);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        final localResponse = await localDataSource.getLastChatResponse();
        return Right(localResponse);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<TrueFalse>>> getTrueFalseQuestion(String bookName) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteQuestion =
            await remoteDataSource.getTrueFalseQuestion(bookName);
        localDataSource.cacheTrueFalseQuestion(remoteQuestion);
        return Right(remoteQuestion);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        final localQuestion =
            await localDataSource.getLastTrueFalseQuestion();
        return Right(localQuestion);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, List<MultipleQuestions>>> getMultipleQuestions(String bookName) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteQuestions =
            await remoteDataSource.getMultipleQuestions(bookName);
        localDataSource.cacheMultipleQuestions(remoteQuestions);
        return Right(remoteQuestions);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        final localQuestions =
            await localDataSource.getLastMultipleQuestions();
        return Right(localQuestions);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, List<ShortAnswer>>> getShortAnswerQuestion(String bookName) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteQuestion =
            await remoteDataSource.getShortAnswerQuestion(bookName);
        localDataSource.cacheShortAnswerQuestion(remoteQuestion);
        return Right(remoteQuestion);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        final localQuestion =
            await localDataSource.getLastShortAnswerQuestion();
        return Right(localQuestion);
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    }
  }
}