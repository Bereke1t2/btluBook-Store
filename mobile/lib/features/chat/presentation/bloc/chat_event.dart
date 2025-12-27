part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class GetChatResponseEvent extends ChatEvent {
  final String prompt;
  final String bookName;

  GetChatResponseEvent(this.prompt , this.bookName);
}
class GetTrueFalseQuestionEvent extends ChatEvent {
  final String bookName;

  GetTrueFalseQuestionEvent(this.bookName);
}
class GetMultipleQuestionsEvent extends ChatEvent {
  final String bookName;

  GetMultipleQuestionsEvent(this.bookName);
}

class GetShortAnswerQuestionEvent extends ChatEvent{
  final String bookName;

  GetShortAnswerQuestionEvent(this.bookName);
}