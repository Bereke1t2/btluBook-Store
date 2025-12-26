import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';

class ShortAnswerModel extends ShortAnswer{
  ShortAnswerModel({
    required String question,
    required String answer,
    required String explanation,
  }) : super(
          question: question,
          answer: answer,
          explanation: explanation,
        );

  factory ShortAnswerModel.fromJson(Map<String, dynamic> json) {
    return ShortAnswerModel(
      question: json['question'],
      answer: json['answer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'explanation': explanation,
    };
  }
}