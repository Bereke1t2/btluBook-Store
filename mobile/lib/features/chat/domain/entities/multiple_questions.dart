
import 'package:equatable/equatable.dart';

class MultipleQuestions extends Equatable {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanations;

  const MultipleQuestions({
    required this.question,
    required this.options,
    required this.explanations,
    required this.correctIndex,
  });

  @override
  List<Object?> get props => [question, options, explanations, correctIndex];
}
