part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}


final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  final User user;

  Authenticated({required this.user});
}
final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}


final class LoginLoading extends AuthState {}
final class SignupLoading extends AuthState {}
final class LogoutLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final User user;

  LoginSuccess({required this.user});
}
final class SignupSuccess extends AuthState {
  final User user;

  SignupSuccess({required this.user});
}
final class LogoutSuccess extends AuthState {}

final class LoginFailure extends AuthState {
  final String message;

  LoginFailure({required this.message});
}
final class SignupFailure extends AuthState {
  final String message;
  SignupFailure({required this.message});
}
final class LogoutFailure extends AuthState {
  final String message;
  LogoutFailure({required this.message});
}


final class UpdateProfileLoading extends AuthState {}
final class UpdateProfileSuccess extends AuthState {
  final User user;
  UpdateProfileSuccess({required this.user});
}
final class UpdateProfileFailure extends AuthState {
  final String message;
  UpdateProfileFailure({required this.message});
}