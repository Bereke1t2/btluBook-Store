import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethio_book_store/core/connection/network.dart';
import 'package:ethio_book_store/features/auth/data/datasources/local/localdata.dart';
import 'package:ethio_book_store/features/auth/data/datasources/remote/remotedata.dart';
import 'package:ethio_book_store/features/auth/data/repositories/userRepository.dart';
import 'package:ethio_book_store/features/auth/domain/repositories/user_repository.dart';
import 'package:ethio_book_store/features/auth/domain/usecases/check_auth_status.dart';
import 'package:ethio_book_store/features/auth/domain/usecases/login.dart';
import 'package:ethio_book_store/features/auth/domain/usecases/logout.dart';
import 'package:ethio_book_store/features/auth/domain/usecases/signup.dart';
import 'package:ethio_book_store/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ethio_book_store/features/books/data/datasources/local/bookLocal.dart';
import 'package:ethio_book_store/features/books/data/datasources/remote/book_remote_data_source.dart';
import 'package:ethio_book_store/features/books/data/local_database/app_database.dart';
import 'package:ethio_book_store/features/books/data/repositories/bookRepository.dart';
import 'package:ethio_book_store/features/books/domain/repositories/bookRepo.dart';
import 'package:ethio_book_store/features/books/domain/usecases/downloadBook.dart';
import 'package:ethio_book_store/features/books/domain/usecases/getBook.dart';
import 'package:ethio_book_store/features/books/domain/usecases/getBooks.dart';
import 'package:ethio_book_store/features/books/domain/usecases/uploadBook.dart';
import 'package:ethio_book_store/features/books/presentation/bloc/book_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  
   sl.registerFactory(() => AuthBloc(
     loginUseCase: sl(),
     signupUseCase: sl(),
     logoutUseCase: sl(),
     checkAuthStatusUseCase: sl(),
   ));

   sl.registerFactory(() => BookBloc(
     getBooksUseCase: sl(),
     getBookUseCase: sl(),
     uploadBookUseCase: sl(),
     downloadBookUseCase: sl(),
   ));
  // Usecases
  sl.registerLazySingleton(() => CheckAuthStatus(userRepository:sl()));
  sl.registerLazySingleton(() => Login(userRepository:  sl()));
  sl.registerLazySingleton(() => Logout(userRepository:  sl()));
  sl.registerLazySingleton(() => Signup(userRepository:  sl()));

  sl.registerLazySingleton(() => GetBookUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetBooksUseCase(repository: sl()));
  sl.registerLazySingleton(() => UploadBookUseCase(repository: sl()));
  sl.registerLazySingleton(() => DownloadBookUseCase(repository: sl()));

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      networkInfo: sl(),
      remoteDataSource: sl(),
      localDataSource: sl()

    ),
  );

  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  //local databases
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  // Data sources
  sl.registerLazySingleton<RemoteData>(
    () => RemoteDataSourceImpl(sl() , sl()),
  );
  sl.registerLazySingleton<LocalData>(
    () => LocaldataImpl(sl()),
  );


  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(sl() , sl(), sl()),
  );
  sl.registerLazySingleton<BookLocalDataSource>(
   () => BookLocalDataSourceImpl(sl())
  );
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<http.Client>(() => http.Client());
}
