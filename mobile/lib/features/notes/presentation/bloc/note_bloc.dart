import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/note_model.dart';
import '../../domain/repositories/note_repository.dart';

// Events
abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  final String bookId;
  final String token;
  const LoadNotes({required this.bookId, required this.token});
  @override
  List<Object?> get props => [bookId, token];
}

class CreateNote extends NoteEvent {
  final String bookId;
  final String content;
  final String token;
  const CreateNote({required this.bookId, required this.content, required this.token});
  @override
  List<Object?> get props => [bookId, content, token];
}

class GenerateAINote extends NoteEvent {
  final String bookId;
  final String text;
  final String token;
  const GenerateAINote({required this.bookId, required this.text, required this.token});
  @override
  List<Object?> get props => [bookId, text, token];
}

class DeleteNote extends NoteEvent {
  final String noteId;
  final String bookId;
  final String token;
  const DeleteNote({required this.noteId, required this.bookId, required this.token});
  @override
  List<Object?> get props => [noteId, bookId, token];
}

// States
abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<NoteModel> notes;
  const NoteLoaded({required this.notes});
  @override
  List<Object?> get props => [notes];
}

class NoteCreating extends NoteState {}

class NoteError extends NoteState {
  final String message;
  const NoteError({required this.message});
  @override
  List<Object?> get props => [message];
}

class AINotePending extends NoteState {}

class AINoteDone extends NoteState {
  final NoteModel note;
  const AINoteDone({required this.note});
  @override
  List<Object?> get props => [note];
}

// Bloc
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc({required this.repository}) : super(NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<GenerateAINote>(_onGenerateAINote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await repository.getNotes(event.bookId, event.token);
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(NoteError(message: e.toString()));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NoteState> emit) async {
    emit(NoteCreating());
    try {
      await repository.createNote(event.bookId, event.content, event.token);
      add(LoadNotes(bookId: event.bookId, token: event.token));
    } catch (e) {
      emit(NoteError(message: e.toString()));
    }
  }

  Future<void> _onGenerateAINote(GenerateAINote event, Emitter<NoteState> emit) async {
    emit(AINotePending());
    try {
      final note = await repository.generateAINote(event.bookId, event.text, event.token);
      emit(AINoteDone(note: note));
      // Reload notes after AI generation
      add(LoadNotes(bookId: event.bookId, token: event.token));
    } catch (e) {
      emit(NoteError(message: e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await repository.deleteNote(event.noteId, event.token);
      add(LoadNotes(bookId: event.bookId, token: event.token));
    } catch (e) {
      emit(NoteError(message: e.toString()));
    }
  }
}
