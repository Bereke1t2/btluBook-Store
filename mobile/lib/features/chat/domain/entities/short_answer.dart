import 'package:equatable/equatable.dart';

class ShortAnswer extends Equatable {
  final String question;
  final String answer;
  final String explanation;

  const ShortAnswer({
    required this.question,
    required this.answer,
    required this.explanation,
  });

  @override
  List<Object?> get props => [question, answer, explanation];
}
