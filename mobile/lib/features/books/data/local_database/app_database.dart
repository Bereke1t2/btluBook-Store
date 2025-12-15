import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart'; // for NativeDatabase
import 'package:ethio_book_store/features/books/data/local_database/book_local_database.dart';


part 'app_database.g.dart';

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          NativeDatabase(
            File('books.db'),       // Database file
            logStatements: true,     // Logs queries to console
          ),
        );

  @override
  int get schemaVersion => 1;
}
