import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';

class MultipleQuestionsModel extends MultipleQuestions {
  const MultipleQuestionsModel({
    required super.question,
    required super.options,
    required super.correctIndex,
    required super.explanations,
  });

  factory MultipleQuestionsModel.fromJson(Map<String, dynamic> json) {
    return MultipleQuestionsModel(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      explanations: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'explanations': explanations,
    };
  }
}
