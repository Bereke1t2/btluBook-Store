import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class Signup{
  final UserRepository userRepository;

  Signup({required this.userRepository});
  Future<Either<Failure, User>> call(String email, String password, String username) {
    return userRepository.signup(email, password, username);
  }
}