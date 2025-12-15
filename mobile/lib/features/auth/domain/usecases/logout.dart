import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/user_repository.dart';

class Logout {
  final UserRepository userRepository;

  Logout({required this.userRepository});
  Future<Either<Failure, void>> call() {
    return userRepository.logout();
  }
}