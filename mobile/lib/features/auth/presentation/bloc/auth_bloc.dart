import 'package:bloc/bloc.dart';
import 'package:ethio_book_store/features/auth/domain/usecases/login.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/signup.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login loginUseCase;
  final Signup signupUseCase;
  final Logout logoutUseCase;
  final CheckAuthStatus checkAuthStatusUseCase;
  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await checkAuthStatusUseCase();
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(Authenticated(user: user)),
      );
    });
    on<LoginRequested>((event, emit) async {
      emit(LoginLoading());
      final result = await loginUseCase(event.email, event.password);
      result.fold(
        (failure) => emit(LoginFailure(message: failure.message)),
        (user) => emit(LoginSuccess(user: user)),
      );
    });
    on<SignupRequested>((event, emit) async {
      emit(SignupLoading());
      final result = await signupUseCase(event.email, event.password, event.username);
      result.fold(
        (failure) => emit(SignupFailure(message: failure.message)),
        (user) => emit(SignupSuccess(user: user)),
      );
    });
    on<LogoutRequested>((event, emit) async {
      emit(LogoutLoading());
      final result = await logoutUseCase();
      result.fold(
        (failure) => emit(LogoutFailure(message: failure.message)),
        (_) => emit(LogoutSuccess()),
      );
    });
  }
}
