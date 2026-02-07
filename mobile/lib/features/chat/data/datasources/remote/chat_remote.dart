import 'dart:convert';

import 'package:ethio_book_store/core/const/url_const.dart';
import 'package:ethio_book_store/features/auth/data/datasources/local/localdata.dart';
import 'package:ethio_book_store/features/chat/data/datasources/local/chat_local.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart';
import 'package:ethio_book_store/features/chat/data/models/short_answer_model.dart';
import 'package:ethio_book_store/features/chat/data/models/true_false_model.dart';
import 'package:ethio_book_store/features/chat/data/models/multiple_questions_model.dart';
import 'package:http/http.dart' as http;

abstract class ChatRemoteDataSource {
  Future<String> getChatResponse(String prompt , String bookName);
  Stream<String> streamChatResponse(String prompt, String bookName);
  Future<List<TrueFalse>> getTrueFalseQuestion(String bookName);
  Future<List<MultipleQuestions>> getMultipleQuestions(String bookName);
  Future<List<ShortAnswer>> getShortAnswerQuestion(String bookName);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final LocalData localData;
  final ChatLocalDataSource localDataSource;
  final http.Client client;

  ChatRemoteDataSourceImpl(this.localData, this.localDataSource, this.client);

  static const Duration _delayDuration = Duration(seconds: 30);
  Future<void> _delay() => Future.delayed(_delayDuration);

  @override
  Future<String> getChatResponse(String prompt , String bookName) async {
    try{
      final token = await localData.getToken();
      final response = await client.post(
        Uri.parse('${UrlConst.baseUrl}${UrlConst.chatResponseEndpoint}/1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'prompt': prompt, 'book_name': bookName}),
      );
      print('Chat response status code: ${response.statusCode}');
      print('Chat response body: ${response.body}');
      if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
        return data['message'];
      } else {
        throw Exception('Failed to get chat response');
      }
    } catch (e) {
      print('Error getting chat response: $e');
      rethrow;
    }
  }

  @override
  Stream<String> streamChatResponse(String prompt, String bookName) async* {
    try {
      final token = await localData.getToken();
      final request = http.Request(
        'GET',
        Uri.parse('${UrlConst.baseUrl}/stream?prompt=$prompt'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Cache-Control'] = 'no-cache';
      request.headers['Accept'] = 'text/event-stream';

      final response = await client.send(request);

      if (response.statusCode == 200) {
        await for (final chunk in response.stream.transform(utf8.decoder)) {
            // Parse SSE format: "event: message\ndata: <content>\n\n"
            final lines = chunk.split('\n');
            for (final line in lines) {
              if (line.startsWith('data: ')) {
                yield line.substring(6);
              }
            }
        }
      } else {
        throw Exception('Failed to stream chat response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error streaming chat: $e');
      throw Exception('Connection failed');
    }
  }

  @override
  Future<List<TrueFalse>> getTrueFalseQuestion(String bookName) async {
    try {
      final token = await localData.getToken();
      final response =  await client.post(
        Uri.parse('${UrlConst.baseUrl}${UrlConst.trueFalseQuestionsEndpoint}/1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'book_name': bookName}),
      );
      print('True/False question status code: ${response.statusCode}');
      print('True/False question body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => TrueFalseModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get true/false questions');
      }
    } catch (e) {
      print('Error getting true/false questions: $e');
      rethrow;
    }
  }

  @override
  Future<List<MultipleQuestions>> getMultipleQuestions(String bookName) async {
    try {
      final token = await localData.getToken();
      final response = await client.post(
        Uri.parse('${UrlConst.baseUrl}${UrlConst.multipleChoiceQuestionsEndpoint}/1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'book_name': bookName}),
      );
      print('Multiple choice question status code: ${response.statusCode}');
      print('Multiple choice question body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => MultipleQuestionsModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get multiple choice questions');
      }
    } catch (e) {
      print('Error getting multiple choice questions: $e');
      rethrow;
    }
  }

  @override
  Future<List<ShortAnswer>> getShortAnswerQuestion(String bookName) async {
    try {
      final token = await localData.getToken();
      final response = await client.post(
        Uri.parse('${UrlConst.baseUrl}${UrlConst.shortAnswerQuestionsEndpoint}/1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'book_name': bookName}),
      );
      print('Short answer question status code: ${response.statusCode}');
      print('Short answer question body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => ShortAnswerModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to get short answer questions');
      }
    } catch (e) {
      print('Error getting short answer questions: $e');
      rethrow;
    }
  }
}