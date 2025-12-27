import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';

class TrueFalseModel extends TrueFalse {
  const TrueFalseModel({
    required super.question,
    required super.answer,
    required super.explanation,

  });

  factory TrueFalseModel.fromJson(Map<String, dynamic> json) {
    return TrueFalseModel(
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
