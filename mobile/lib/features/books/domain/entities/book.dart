
import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final double price;
  final double rating;
  final String category;
  final bool isFeatured;
  final String? tag;
  final String coverUrl;
  final String sharedBy;
  final String bookUrl;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
    required this.category,
    required this.coverUrl,
    required this.bookUrl,
    this.isFeatured = false,
    this.tag,
    this.sharedBy = 'Admin',
    this.lastReadPage = 0,
    this.totalPages = 0,
  });

  final int lastReadPage;
  final int totalPages;

  double get readProgress => totalPages > 0 ? lastReadPage / totalPages : 0.0;


  @override
  List<Object?> get props => [id, title, author, rating, price, category, isFeatured, tag, coverUrl, sharedBy, bookUrl, lastReadPage, totalPages];
}