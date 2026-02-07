import 'package:ethio_book_store/features/books/domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.price,
    required super.rating,
    required super.category,
    required super.isFeatured,
    super.tag,
    required super.coverUrl,
    required super.sharedBy,
    required super.bookUrl,
    super.lastReadPage,
    super.totalPages,
  });

  static double _toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  static bool _toBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final s = value.toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
      return s == '1';
    }
    return defaultValue;
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      price: _toDouble(json['price'], defaultValue: 0.0),
      rating: _toDouble(json['rating'], defaultValue: 0.0),
      category: (json['category'] ?? '').toString(),
      isFeatured: _toBool(json['is_featured'], defaultValue: false),
      tag: json['tag']?.toString(),
      coverUrl: (json['cover_url'] ?? '').toString(),
      sharedBy: (json['shared_by'] ?? '').toString(),
      bookUrl: (json['book_url'] ?? '').toString(),
      lastReadPage: json['last_read_page'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'rating': rating,
      'category': category,
      'is_featured': isFeatured,
      'tag': tag,
      'cover_url': coverUrl,
      'shared_by': sharedBy,
      'book_url': bookUrl,
      'last_read_page': lastReadPage,
      'total_pages': totalPages,
    };
  }

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      price: book.price,
      rating: book.rating,
      category: book.category,
      isFeatured: book.isFeatured,
      tag: book.tag,
      coverUrl: book.coverUrl,
      sharedBy: book.sharedBy,
      bookUrl: book.bookUrl,
      lastReadPage: book.lastReadPage,
      totalPages: book.totalPages,
    );
  }
}