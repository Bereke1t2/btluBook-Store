import 'package:dartz/dartz.dart';
import 'package:ethio_book_store/core/errors/failure.dart';
import 'package:ethio_book_store/features/auth/domain/entities/user.dart';
import 'package:ethio_book_store/features/auth/domain/repositories/user_repository.dart';

class UpdateProfile {
  final UserRepository repository;

  UpdateProfile({required this.repository});

  Future<Either<Failure, User>> call(User user) async {
    print('UpdateProfile UseCase: called with user: ${user.username}, ${user.email}');
    return await repository.updateProfile(user);
  }
}