import 'package:ethio_book_store/app/themes/app_theme.dart';
import 'package:ethio_book_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/login_page.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/onboarding_page.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/signup_page.dart';
import 'package:ethio_book_store/features/auth/presentation/pages/splash_screan.dart';
import 'package:ethio_book_store/features/books/domain/entities/book.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:ethio_book_store/features/books/presentation/pages/book_details_page.dart';
import 'package:ethio_book_store/features/books/presentation/pages/home_page.dart';
import 'package:ethio_book_store/features/books/presentation/pages/uploadscrean.dart';
import 'package:ethio_book_store/features/books/presentation/pages/user_profile_page.dart';
import 'package:ethio_book_store/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ethio_book_store/features/chat/presentation/pages/chat_page.dart';
import 'package:ethio_book_store/features/reader/presentation/pages/downloaded_book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Main App widget with theme support.
/// Uses ThemeBloc for dark/light mode switching.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme Bloc
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc()..add(LoadTheme()),
        ),
        // Auth Bloc
        BlocProvider<AuthBloc>(
          create: (_) {
            final bloc = GetIt.I<AuthBloc>();
            bloc.add(CheckAuthStatusEvent());
            return bloc;
          },
        ),
        // Book Bloc
        BlocProvider<BookBloc>(
          create: (_) => GetIt.I<BookBloc>(),
        ),
        // Chat Bloc
        BlocProvider<ChatBloc>(
          create: (_) => GetIt.I<ChatBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, AppThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'btluBook Store',
            debugShowCheckedModeBanner: false,
            
            // Theme switching
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
            
            routes: _buildRoutes(),
            initialRoute: "/",
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
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
                    _handleUnauthenticated(context);
                  }
                },
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      "/": (_) => const SplashScrean(),
      "/onboarding": (_) => const OnboardingPage(),
      "/home": (context) {
        final authState = context.read<AuthBloc>().state;
        if (authState is LoginSuccess) {
          return HomePage(user: authState.user);
        } else if (authState is Authenticated) {
          return HomePage(user: authState.user);
        }
        debugPrint('User not authenticated, redirecting to login page. state: $authState');
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

        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final user = args?['user'];
        if (user != null) {
          return UserProfilePage(user: user);
        }

        return const LoginPage();
      },
      "/Download": (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final argUser = args?['user'];
        final downloadedBooks = args?['downloadedBooks'];
        final onRemove = args?['onRemove'] as void Function(dynamic)?;

        if (argUser != null) {
          return DownloadedBookPage(
            user: argUser,
            downloadedBooks: downloadedBooks,
            onRemove: onRemove,
          );
        }

        final authState = context.read<AuthBloc>().state;
        if (authState is LoginSuccess) {
          return DownloadedBookPage(
            user: authState.user,
            downloadedBooks: downloadedBooks,
            onRemove: onRemove,
          );
        } else if (authState is Authenticated) {
          return DownloadedBookPage(
            user: authState.user,
            downloadedBooks: downloadedBooks,
            onRemove: onRemove,
          );
        }

        return const LoginPage();
      },
      "/ChatPage": (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        final bookTitle = args?['bookTitle'] as String? ?? 'books';
        final isStudentBook = args?['isStudentBook'] as bool? ?? true;

        return ChatPage(
          bookTitle: bookTitle,
          isStudentBook: isStudentBook,
        );
      },
      "/BookDetails": (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final book = args?['book'] as Book?;
        final heroTag = args?['heroTag'] as String?;
        
        if (book == null) {
          return const LoginPage(); // Fallback
        }
        
        return BookDetailsPage(
          book: book,
          heroTag: heroTag,
        );
      },
    };
  }

  Future<void> _handleUnauthenticated(BuildContext context) async {
    final isOnboardingCompleted = await OnboardingPage.isCompleted();
    if (!context.mounted) return;
    
    if (isOnboardingCompleted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/login",
        (_) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/onboarding",
        (_) => false,
      );
    }
  }
}
