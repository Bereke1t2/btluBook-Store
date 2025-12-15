// data/database/tables/books.dart
import 'package:drift/drift.dart';

class Books extends Table {
  // Non-nullable fields
  TextColumn get id => text().customConstraint('UNIQUE')(); // primary identifier
  TextColumn get title => text()();
  TextColumn get author => text()();
  RealColumn get price => real()();
  RealColumn get rating => real()();
  TextColumn get category => text()();
  BoolColumn get isFeatured => boolean().withDefault(const Constant(false))();
  TextColumn get coverUrl => text()();     // cover image file path
  TextColumn get sharedBy => text()();     // user who shared the book
  TextColumn get bookUrl => text()();      // pdf/epub file path

  // Nullable fields
  TextColumn get tag => text().nullable()();
}
