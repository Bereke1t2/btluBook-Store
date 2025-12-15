import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class CheckAuthStatus {
  final UserRepository userRepository;

  CheckAuthStatus({required this.userRepository});

  Future<Either<Failure, User>> call() async {
    return await userRepository.getCurrentUser();
  }
}