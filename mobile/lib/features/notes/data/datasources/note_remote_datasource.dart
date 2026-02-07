import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/const/url_const.dart';
import '../models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes(String bookId, String token);
  Future<NoteModel> createNote(String bookId, String content, String token);
  Future<NoteModel> generateAINote(String bookId, String text, String token);
  Future<void> deleteNote(String noteId, String token);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final http.Client client;

  NoteRemoteDataSourceImpl({required this.client});

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  @override
  Future<List<NoteModel>> getNotes(String bookId, String token) async {
    final response = await client.get(
      Uri.parse('${UrlConst.baseUrl}${UrlConst.notesEndpoint}/$bookId'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final notesList = data['data']['notes'] as List? ?? [];
      return notesList.map((e) => NoteModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notes: ${response.body}');
    }
  }

  @override
  Future<NoteModel> createNote(String bookId, String content, String token) async {
    final response = await client.post(
      Uri.parse('${UrlConst.baseUrl}${UrlConst.notesEndpoint}'),
      headers: _headers(token),
      body: json.encode({'book_id': bookId, 'content': content}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return NoteModel.fromJson(data['data']['note']);
    } else {
      throw Exception('Failed to create note: ${response.body}');
    }
  }

  @override
  Future<NoteModel> generateAINote(String bookId, String text, String token) async {
    final response = await client.post(
      Uri.parse('${UrlConst.baseUrl}${UrlConst.aiNotesEndpoint}'),
      headers: _headers(token),
      body: json.encode({'book_id': bookId, 'text': text}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return NoteModel.fromJson(data['data']['note']);
    } else {
      throw Exception('Failed to generate AI note: ${response.body}');
    }
  }

  @override
  Future<void> deleteNote(String noteId, String token) async {
    final response = await client.delete(
      Uri.parse('${UrlConst.baseUrl}${UrlConst.notesEndpoint}/$noteId'),
      headers: _headers(token),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete note: ${response.body}');
    }
  }
}
