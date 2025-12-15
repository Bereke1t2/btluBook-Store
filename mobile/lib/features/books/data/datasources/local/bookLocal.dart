import 'package:drift/drift.dart';
import 'package:ethio_book_store/features/books/data/local_database/app_database.dart';
import 'package:ethio_book_store/features/books/data/models/bookModel.dart';

abstract class BookLocalDataSource {
  Future<void> cacheBooks(List<BookModel> books);
  Future<BookModel> getBook(String id);
  Future<List<BookModel>> getCachedBooks();
  Future<void> clearCache();
}


class BookLocalDataSourceImpl implements BookLocalDataSource {
  final AppDatabase database;
  BookLocalDataSourceImpl(this.database);
  @override
  Future<void> cacheBooks(List<BookModel> books) async {
    books.map((book) => database.into(database.books).insert(
      BooksCompanion.insert(
        id: book.id,
        title: book.title,
        author: book.author,
        price: book.price,
        rating: book.rating,
        category: book.category,
        isFeatured: Value(book.isFeatured),
        tag: Value(book.tag),
        coverUrl: book.coverUrl,
        sharedBy: book.sharedBy,
        bookUrl: book.bookUrl,
      ),
    )).toList();
  }

  @override

  Future<BookModel> getBook(String id) async {
    final bookRow = await (database.select(database.books)
      ..where((tbl) => tbl.id.equals(id)))
      .getSingle();

    return BookModel(
      id: bookRow.id,
      title: bookRow.title,
      author: bookRow.author,
      price: bookRow.price,
      rating: bookRow.rating,
      category: bookRow.category,
      isFeatured: bookRow.isFeatured,
      tag: bookRow.tag,
      coverUrl: bookRow.coverUrl,
      sharedBy: bookRow.sharedBy,
      bookUrl: bookRow.bookUrl,
    );
  }

  @override
  Future<List<BookModel>> getCachedBooks() async {
    final bookRows = await database.select(database.books).get();
    return bookRows.map((bookRow) {
      return BookModel(
        id: bookRow.id,
        title: bookRow.title,
        author: bookRow.author,
        price: bookRow.price,
        rating: bookRow.rating,
        category: bookRow.category,
        isFeatured: bookRow.isFeatured,
        tag: bookRow.tag,
        coverUrl: bookRow.coverUrl,
        sharedBy: bookRow.sharedBy,
        bookUrl: bookRow.bookUrl,
      );
    }).toList();
  }

  @override
  Future<void> clearCache() {
    return database.delete(database.books).go();
  }
}