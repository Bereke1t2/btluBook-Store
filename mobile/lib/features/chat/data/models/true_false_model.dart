import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';

class TrueFalseModel extends TrueFalse {
  TrueFalseModel({
    required String question,
    required String answer,
    required String explanation,

  }) : super(
          question: question,
          answer: answer,
          explanation: explanation,
        );

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
