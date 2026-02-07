import 'dart:convert';
import 'dart:io';
import 'dart:developer' show log;

import 'package:ethio_book_store/core/const/url_const.dart';
import 'package:ethio_book_store/features/auth/data/datasources/local/localdata.dart';
import 'package:ethio_book_store/features/books/data/datasources/local/bookLocal.dart';
import 'package:ethio_book_store/features/books/data/models/bookModel.dart';
import 'package:ethio_book_store/features/books/domain/entities/download_update.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> fetchBooks(int page, int limit);
  Future<BookModel> fetchBook(String id);
  Future<void> uploadBook(BookModel book);
  Stream<DownloadUpdate> downloadBook(String id);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final http.Client httpClient;
  final BookLocalDataSource localDataSource;
  final LocalData localdata;

  BookRemoteDataSourceImpl(
    this.httpClient,
    this.localDataSource,
    this.localdata,
  );

  @override
  Future<List<BookModel>> fetchBooks(int page, int limit) async {
    print("BookRemoteDataSource.fetchBooks(page=$page, limit=$limit)");
    try {
      final token = await localdata.getToken();
      final response = await httpClient.get(
        Uri.parse(
          "${UrlConst.baseUrl}${UrlConst.booksEndpoint}?page=$page&limit=$limit",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );
      print("fetchBooks response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dynamic data = decoded['data'];
        List<dynamic> booksJson;
        if (data is List) {
          booksJson = data;
        } else if (data is Map && data['books'] is List) {
          booksJson = data['books'] as List<dynamic>;
        } else {
          throw Exception("Unexpected data format for books: ${data.runtimeType}");
        }
        final books =
            booksJson.map((bookJson) => BookModel.fromJson(bookJson)).toList();
        return books;
      } else if (response.statusCode == 401) {
        throw Exception(json.decode(response.body)['error']);
      } else {
        throw Exception(
          "Failed to fetch books with response code: ${response.statusCode} , with error message: ${response.body}",
        );
      }
    } catch (e) {
      print("error in remote data source: $e");
      return Future.error(Exception("Failed to fetch books: $e"));
    }
  }

  @override
  Future<BookModel> fetchBook(String id) async {
    try {
      final token = await localdata.getToken();
      final response = await httpClient.get(
        Uri.parse("${UrlConst.baseUrl}${UrlConst.booksEndpoint}/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dynamic data = decoded['data'];
        
        // Backend returns {"data": {"book": {...}}}
        if (data is Map && data['book'] != null) {
          return BookModel.fromJson(data['book']);
        }
        
        return BookModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception(json.decode(response.body)['error']);
      } else {
        throw Exception(
          "Failed to fetch book with response code: ${response.statusCode} , with error message: ${response.body}",
        );
      }
    } catch (e) {
      log("Failed to fetch book: $e");
      return Future.error(Exception("Failed to fetch book: $e"));
    }
  }

  @override
  Future<void> uploadBook(BookModel book) async {
  try {
    final token = await localdata.getToken();

    final uri = Uri.parse(
        "${UrlConst.baseUrl}${UrlConst.uploadBookEndpoint}");

    final request = http.MultipartRequest('POST', uri);

    // 1. AUTH HEADER
    request.headers["Authorization"] = token!;

    // 2. ADD TEXT FIELDS
    request.fields['title'] = book.title;
    request.fields['author'] = book.author;
    request.fields['shared_by'] = book.sharedBy;
    request.fields['category'] = book.category;
    request.fields['price'] = book.price.toString();
    request.fields['rating'] = book.rating.toString();
    if (book.tag != null) {
      request.fields['tag'] = book.tag!;
    }
    request.fields['is_featured'] = book.isFeatured ? 'true' : 'false';



    // 3. ADD COVER IMAGE FILE
    request.files.add(
      await http.MultipartFile.fromPath(
        "cover_url",            // <-- must match backend field name
        book.coverUrl,
      ),
    );
  
    // 4. ADD PDF FILE
    request.files.add(
      await http.MultipartFile.fromPath(
        "book_url",              // <-- must match backend field name
        book.bookUrl,
      ),
    );
  
    // SEND REQUEST
    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception(json.decode(body)['error']);
    } else {
      throw Exception(
          "Failed with ${response.statusCode}. Message: $body");
    }
  } catch (e) {
    log("Failed to upload book: $e");
    return Future.error(Exception("Failed to upload book: $e"));
  }
}

  @override
  Stream<DownloadUpdate> downloadBook(String id) async* {
    try {
      final book = await fetchBook(id);
      final dir = await getApplicationDocumentsDirectory();

      final booksDir = Directory('${dir.path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      final String bookName = '${book.id}.pdf';
      final String coverName = '${book.id}_cover.jpg';
      final bookPath = '${booksDir.path}/$bookName';
      final coverPath = '${booksDir.path}/$coverName';
      final file = File(bookPath);
      final coverFile = File(coverPath);

      String url = book.bookUrl;
      if (!url.startsWith('http')) {
        if (!url.startsWith('/')) {
          url = "/$url";
        }
        url = "${UrlConst.baseUrl}$url";
      }
      String coverUrl = book.coverUrl;
      if (!coverUrl.startsWith('http')) {
        if (!coverUrl.startsWith('/')) {
          coverUrl = "/$coverUrl";
        }
        coverUrl = "${UrlConst.baseUrl}$coverUrl";
      }

      print("🔹 Downloading book from: $url");
      print("🔹 Downloading cover from: $coverUrl");

      // 1. Download cover first (usually small)
      final coverResponse = await httpClient.get(Uri.parse(coverUrl));
      if (coverResponse.statusCode == 200) {
        await coverFile.writeAsBytes(coverResponse.bodyBytes);
        yield DownloadUpdate(progress: 0.05); // 5% done after cover
      } else {
        throw Exception('Failed to download cover: ${coverResponse.statusCode}');
      }

      // 2. Download book with progress
      final request = http.Request('GET', Uri.parse(url));
      final response = await httpClient.send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        int downloadedBytes = 0;
        List<int> bytes = [];

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;
          
          if (totalBytes > 0) {
            double progress = 0.05 + (downloadedBytes / totalBytes * 0.94);
            yield DownloadUpdate(progress: progress);
          }
        }

        await file.writeAsBytes(bytes);
        print("✅ Download successful: $bookPath");
        yield DownloadUpdate(
          progress: 1.0,
          bookPath: bookPath,
          coverPath: coverPath,
          isCompleted: true,
        );
      } else {
        throw Exception('Failed to download book: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Failed to download book: $e");
      throw Exception("Failed to download book: $e");
    }
  }
}
