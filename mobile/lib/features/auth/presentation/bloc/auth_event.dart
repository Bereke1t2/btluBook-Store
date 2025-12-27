part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class SignupRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String? profileImage;

  SignupRequested({
    required this.username,
    required this.email,
    required this.password,
    this.profileImage,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final User user;
  UpdateProfileRequested({required this.user});
}