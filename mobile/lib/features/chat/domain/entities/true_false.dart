import 'package:equatable/equatable.dart';

class TrueFalse extends Equatable {
  final String question;
  final String answer;
  final String explanation;

  const TrueFalse({
    required this.question,
    required this.answer,
    required this.explanation,
  });
  @override
  List<Object?> get props => [question, answer, explanation];
}