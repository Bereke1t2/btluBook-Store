import 'package:ethio_book_store/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.passwordHash,
    super.profileImage,
    required super.createdAt,
    required super.updatedAt,
    super.booksReadCount = 0,
    super.readingStreak = 0,
    super.lastReadDate,
    super.points = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final int id = () {
      if (rawId == null) return 0;
      if (rawId is int) return rawId;
      if (rawId is String && rawId.isNotEmpty) {
        return int.tryParse(rawId) ?? 0;
      }
      return 0;
    }();

    final String username = (json['username'] as String?)?.trim() ?? '';
    final String email = (json['email'] as String?)?.trim() ?? '';
    final String passwordHash = (json['passwordHash'] as String?)?.trim() ?? '';

    final DateTime createdAt =
        json['created_at'] != null ? _parseDate(json['created_at']) : DateTime.now();
    final DateTime updatedAt =
        json['updated_at'] != null ? _parseDate(json['updated_at']) : DateTime.now();

    return UserModel(
      id: id,
      username: username,
      email: email,
      passwordHash: passwordHash,
      profileImage: (json['profile_image'] as String?) ??
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTISkOqZqbBuD0yPxtE7VU7DI36fTG0IuwpoQ&s",
      createdAt: createdAt,
      updatedAt: updatedAt,
      booksReadCount: (json['books_read_count'] as int?) ?? 0,
      readingStreak: (json['reading_streak'] as int?) ?? 0,
      lastReadDate: _tryParseDate(json['last_read_date']),
      points: (json['points'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'booksReadCount': booksReadCount,
      'readingStreak': readingStreak,
      'lastReadDate': lastReadDate?.toIso8601String(),
      'points': points,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) {
      // milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.parse(value as String);
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null;
    }
  }

  static UserModel fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      passwordHash: user.passwordHash,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      booksReadCount: user.booksReadCount,
      readingStreak: user.readingStreak,
      lastReadDate: user.lastReadDate,
      points: user.points,
    );
  }
}