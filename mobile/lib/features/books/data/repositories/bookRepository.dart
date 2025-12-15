import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/connection/network.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/books/data/datasources/remote/book_remote_data_source.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';
import 'package:ethio_book_store/features/books/data/datasources/local/bookLocal.dart';
import 'package:ethio_book_store/features/books/data/models/bookModel.dart';

class BookRepositoryImpl implements BookRepository {
  final BookLocalDataSource localDataSource;
  final BookRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  BookRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, Book>> getBook(String id) async{
    if (await networkInfo.isConnected) {
      try{
        final book = await remoteDataSource.fetchBook(id);
        return Right(book);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try{
        final book = await localDataSource.getBook(id);
        return Right(book);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getBooks(int page, int limit) async{
    if (await networkInfo.isConnected) {
      try{
        final books = await remoteDataSource.fetchBooks(page, limit);
        return Right(books);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try{
        final books = await localDataSource.getCachedBooks();
        return Right(books);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, void>> uploadBook(Book book) async{
    final model = BookModel.fromEntity(book);
    if (await networkInfo.isConnected) {
      try{
        await remoteDataSource.uploadBook(model);
        return Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
  

  @override
  Future<Either<Failure, void>> downloadBook(String id) async{
    if (await networkInfo.isConnected) {
      try{
        await remoteDataSource.downloadBook(id);
        return Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}