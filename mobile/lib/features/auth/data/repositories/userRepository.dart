import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/features/auth/data/models/user.dart';
import 'package:ethio_book_store/features/auth/domain/entities/user.dart';

import '../../../../core/connection/network.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/localdata.dart';
import '../datasources/remote/remotedata.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteData remoteDataSource;
  final LocalData localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login(email, password);
        return Right(user);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    
    } else {
      return Left(NetworkFailure("No internet connection"));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signup(String email, String password, String username) async {
    if (await networkInfo.isConnected) {
      try {
        final  user = await remoteDataSource.signup(email, password, username);
        return Right(user);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure("No internet connection"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        // await remoteDataSource.logout();
        localDataSource.clearCache();
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure("No internet connection"));
    }
  }
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await localDataSource.getCachedUser();
        final token = await localDataSource.getToken();
        if (user == null || token == null) {
          return Left(CacheFailure("No cached user found"));
        }
        await remoteDataSource.getCurrentUser(token);
        return Right(user);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure("No internet connection"));
    }
  }
  @override
  Future<Either<Failure, UserModel>> updateProfile(User user) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await remoteDataSource.updateProfile(UserModel.fromEntity(user));
        return Right(updatedUser);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure("No internet connection"));
    }
  }
}