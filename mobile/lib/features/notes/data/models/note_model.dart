class NoteModel {
  final String id;
  final int userId;
  final String bookId;
  final String content;
  final bool isAiGenerated;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.content,
    required this.isAiGenerated,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? 0,
      bookId: json['book_id'] ?? '',
      content: json['content'] ?? '',
      isAiGenerated: json['is_ai_generated'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'content': content,
      'is_ai_generated': isAiGenerated,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NoteModel copyWith({
    String? id,
    int? userId,
    String? bookId,
    String? content,
    bool? isAiGenerated,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
