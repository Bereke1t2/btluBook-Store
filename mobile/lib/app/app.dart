import 'package:ethio_book_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/login_page.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/signup_page.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/splash_screan.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:ethio_book_store/features/books/presentation/pages/chat_page.dart';
import 'package:ethio_book_store/features/books/presentation/pages/home_page.dart';
import 'package:ethio_book_store/features/books/presentation/pages/uploadscrean.dart';
import 'package:ethio_book_store/features/books/presentation/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (_) => const SplashScrean(),
        "/home": (context) {
          final authState = context.read<AuthBloc>().state;
          if (authState is LoginSuccess) {
            return HomePage(user: authState.user);
          }
          print('User not authenticated, redirecting to login page. state: $authState');
          return const LoginPage();
        },
        "/login": (_) => const LoginPage(),
        "/signup": (_) => const SignupPage(),
        "/UploadPage": (_) => const UploadBookPage(),
        "/profile": (context) {
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            return UserProfilePage(user: authState.user);
          }
          return const LoginPage();
        },
        "/ChatPage": (_) =>
            const ChatPage(bookTitle: 'btluBook', isStudentBook: true),
      },
      initialRoute: "/",
      builder: (context, child) {
        return MultiBlocProvider(
            providers: [
            BlocProvider<AuthBloc>(
              create: (_) {
              final bloc = GetIt.I<AuthBloc>();
              bloc.add(CheckAuthStatusEvent());
              return bloc;
              },
            ),
            BlocProvider<BookBloc>(
              create: (_) => GetIt.I<BookBloc>(),
            ),
            // Add another bloc like this:
            // BlocProvider<YourBloc>(
            //   create: (_) => GetIt.I<YourBloc>(),
            // ),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => current is! AuthLoading,
            listener: (context, state) {
              if (state is Authenticated) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/home",
                  (_) => false,
                );
              }

              if (state is Unauthenticated) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (_) => false,
                );
              }
            },
            child: child!, // ✅ NEVER replace this
          ),
        );
      },
    );
  }
}
