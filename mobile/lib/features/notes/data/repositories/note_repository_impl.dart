import '../models/note_model.dart';
import '../datasources/note_remote_datasource.dart';
import '../../domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NoteModel>> getNotes(String bookId, String token) {
    return remoteDataSource.getNotes(bookId, token);
  }

  @override
  Future<NoteModel> createNote(String bookId, String content, String token) {
    return remoteDataSource.createNote(bookId, content, token);
  }

  @override
  Future<NoteModel> generateAINote(String bookId, String text, String token) {
    return remoteDataSource.generateAINote(bookId, text, token);
  }

  @override
  Future<void> deleteNote(String noteId, String token) {
    return remoteDataSource.deleteNote(noteId, token);
  }
}
