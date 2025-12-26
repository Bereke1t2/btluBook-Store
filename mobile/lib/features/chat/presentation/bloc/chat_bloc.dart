import 'package:bloc/bloc.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getMultipleQeustionsUsecase.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getResponseUsecase.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getShortAnswerUseacase.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getTrueFalseUsecase.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatResponseUseCase chatResponseUC;
  final GetMultipleQuestionsUseCase multipleChooseUC;
  final GetShortAnswerUseCase shortAnswerUC;
  final GetTrueFalseUseCase trueFalseUC;

  ChatBloc({
    required this.chatResponseUC,
    required this.multipleChooseUC,
    required this.shortAnswerUC,
    required this.trueFalseUC,
  }) : super(ChatInitial()) {
    on<GetChatResponseEvent>(_onLoadingResponse);
    on<GetMultipleQuestionsEvent>(_onGetingMultipleQeustions);
    on<GetTrueFalseQuestionEvent>(_onGetingTrueFlase);
    on<GetShortAnswerQuestionEvent>(_onGetShortAnwer);
  }

  Future<void> _onLoadingResponse(
    GetChatResponseEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(GetChatResponseLoadingState());
    final failureOrResponse = await chatResponseUC(event.prompt);
    failureOrResponse.fold(
      (failure) => emit(GetChatResponseFaliurState(failure.message)),
      (response) => emit(GetChatResponseSuccessState(response)),
    );
  }


  Future<void> _onGetingMultipleQeustions(
    GetMultipleQuestionsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(GetMultipleQuestionsLoadingState());
    final failureOrQuestions = await multipleChooseUC(event.bookName);
    failureOrQuestions.fold(
      (failure) => emit(GetMultipleQuestionsFaliurState(failure.message)),
      (questions) => emit(GetMultipleQuestionsSuccessState(questions)),
    );
  }

  Future<void> _onGetingTrueFlase(
    GetTrueFalseQuestionEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(GetTrueFalseQuestionLoadingState());
    final failureOrQuestions = await trueFalseUC(event.bookName);
    failureOrQuestions.fold(
      (failure) => emit(GetTrueFalseQuestionFaliurState(failure.message)),
      (questions) => emit(GetTrueFalseQuestionSuccessState(questions)),
    );
  }

  Future<void> _onGetShortAnwer(
    GetShortAnswerQuestionEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(GetShortAnswerQuestionLoadingState());
    final failureOrQuestions = await shortAnswerUC(event.bookName);
    failureOrQuestions.fold(
      (failure) => emit(GetShortAnswerQuestionFaliurState(failure.message)),
      (questions) => emit(GetShortAnswerQuestionSuccessState(questions)),
    );
  }
}
