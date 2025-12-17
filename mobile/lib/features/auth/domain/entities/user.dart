import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String passwordHash;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int booksReadCount;
  final int readingStreak;
  final DateTime? lastReadDate;
  final int points;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.booksReadCount = 0,
    this.readingStreak = 0,
    this.lastReadDate,
    this.points = 0,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        passwordHash,
        profileImage,
        createdAt,
        updatedAt,
        booksReadCount,
        readingStreak,
        lastReadDate,
        points,
      ];

}
