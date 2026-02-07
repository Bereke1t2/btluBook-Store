part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class GetChatResponseLoadingState extends ChatState{}
class GetChatResponseSuccessState extends ChatState{
  final String response;

  GetChatResponseSuccessState(this.response);
}
class GetChatResponseFaliurState extends ChatState{
  final String message;
  GetChatResponseFaliurState(this.message);
}

class GetChatResponseStreamingState extends ChatState {
  final String chunk;
  GetChatResponseStreamingState(this.chunk);
}




class GetMultipleQuestionsLoadingState extends ChatState{}

class GetMultipleQuestionsSuccessState extends ChatState{
  final List<MultipleQuestions> questions;

  GetMultipleQuestionsSuccessState(this.questions);
}
class GetMultipleQuestionsFaliurState extends ChatState {
  final String message;
  
  GetMultipleQuestionsFaliurState(this.message);
}



class GetShortAnswerQuestionLoadingState extends ChatState{}

class GetShortAnswerQuestionSuccessState extends ChatState{
  final List<ShortAnswer> questions;

  GetShortAnswerQuestionSuccessState(this.questions);
}

class GetShortAnswerQuestionFaliurState extends ChatState{
  final String message;

  GetShortAnswerQuestionFaliurState(this.message);
}


class GetTrueFalseQuestionLoadingState extends ChatState{}

class GetTrueFalseQuestionSuccessState extends ChatState{
  final List<TrueFalse> questions;

  GetTrueFalseQuestionSuccessState(this.questions);
}
class GetTrueFalseQuestionFaliurState extends ChatState{
  final String message;

  GetTrueFalseQuestionFaliurState(this.message);
}

