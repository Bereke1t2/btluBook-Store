import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class Login {
  final UserRepository userRepository;

  Login({required this.userRepository});
  Future<Either<Failure, User>> call(String email, String password) {
    print('Login usecase called with email: $email');
    return userRepository.login(email, password);
  }
}
