import '../../data/models/note_model.dart';

abstract class NoteRepository {
  Future<List<NoteModel>> getNotes(String bookId, String token);
  Future<NoteModel> createNote(String bookId, String content, String token);
  Future<NoteModel> generateAINote(String bookId, String text, String token);
  Future<void> deleteNote(String noteId, String token);
}
