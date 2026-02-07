import 'package:bloc/bloc.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getMultipleQeustionsUsecase.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getResponseUsecase.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getShortAnswerUseacase.dart';
import 'package:ethio_book_store/features/chat/domain/usecases/getTrueFalseUsecase.dart';
import 'package:meta/meta.dart';

import 'package:ethio_book_store/features/chat/domain/usecases/streamChatResponseUsecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatResponseUseCase chatResponseUC;
  final StreamChatResponseUseCase streamChatResponseUC; // Added
  final GetMultipleQuestionsUseCase multipleChooseUC;
  final GetShortAnswerUseCase shortAnswerUC;
  final GetTrueFalseUseCase trueFalseUC;

  ChatBloc({
    required this.chatResponseUC,
    required this.streamChatResponseUC, // Added
    required this.multipleChooseUC,
    required this.shortAnswerUC,
    required this.trueFalseUC,
  }) : super(ChatInitial()) {
    on<GetChatResponseEvent>(_onLoadingResponse);
    on<GetChatResponseStreamEvent>(_onStreamingResponse); // Added
    on<GetMultipleQuestionsEvent>(_onGetingMultipleQeustions);
    on<GetTrueFalseQuestionEvent>(_onGetingTrueFlase);
    on<GetShortAnswerQuestionEvent>(_onGetShortAnwer);
  }

  Future<void> _onLoadingResponse(
    GetChatResponseEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Keep for backward compatibility if needed, or remove
    emit(GetChatResponseLoadingState());
    final failureOrResponse = await chatResponseUC(event.prompt , event.bookName);
    failureOrResponse.fold(
      (failure) => emit(GetChatResponseFaliurState(failure.message)),
      (response) => emit(GetChatResponseSuccessState(response)),
    );
  }

  Future<void> _onStreamingResponse(
    GetChatResponseStreamEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(GetChatResponseLoadingState());
    
    await emit.forEach(
      streamChatResponseUC(event.prompt, event.bookName),
      onData: (either) => either.fold(
        (failure) => GetChatResponseFaliurState(failure.message),
        (chunk) => GetChatResponseStreamingState(chunk),
      ),
      onError: (error, stackTrace) => GetChatResponseFaliurState(error.toString()),
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
