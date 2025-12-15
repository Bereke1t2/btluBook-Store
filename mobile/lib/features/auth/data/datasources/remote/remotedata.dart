import 'dart:convert';

import 'package:ethio_book_store/features/auth/data/datasources/local/localdata.dart';
import 'package:http/http.dart' as http;

import 'package:ethio_book_store/features/auth/data/models/user.dart';

import '../../../../../core/const/url_const.dart';

abstract class RemoteData {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String email, String password, String username);
  Future<void> logout();
  Future<UserModel> getCurrentUser(String token);
}

class RemoteDataSourceImpl implements RemoteData {
  final http.Client httpClient;
  final LocalData localDataSource;

  RemoteDataSourceImpl(this.httpClient, this.localDataSource);

@override
Future<UserModel> login(String email, String password) async {
  try {
    final response = await httpClient.post(
      Uri.parse("${UrlConst.baseUrl}${UrlConst.loginEndpoint}"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(
        {
          "email": email,
          "password": password,
        },
      ),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final token = decoded['data']['token'];
      final user = decoded['data']['user'];

      localDataSource.cacheUser(UserModel.fromJson(user), token);
      return UserModel.fromJson(user);
    } else {
      throw Exception("Failed to login with response code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Failed to login: $e");
  }
}

  @override
  Future<UserModel> signup(String email, String password, String username) async {
   final response = await httpClient.post(
      Uri.parse("${UrlConst.baseUrl}${UrlConst.signupEndpoint}"),
  
      body: {
        "email": email,
        "password": password,
        "username": username,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      localDataSource.cacheUser(UserModel.fromJson(data['user']), data['token']);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception("Failed to signup");
    }
  }

  @override
  Future<void> logout() async {
    final response = await httpClient.post(
      Uri.parse("${UrlConst.baseUrl}${UrlConst.logoutEndpoint}"),
      headers: {
        "Authorization": "Bearer ${localDataSource.getToken()}",
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception("Failed to logout");
    }
  }
  @override
  Future<UserModel> getCurrentUser(String token) async {
    final response = await httpClient.get(
      Uri.parse("${UrlConst.baseUrl}${UrlConst.userProfileEndpoint}"),
      headers: {
        "Authorization": token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return UserModel.fromJson(data);
    }else if(response.statusCode == 401){
      throw Exception(json.decode(response.body)['error']);
    }
     else {
      throw Exception("Failed to fetch current user");
    }
  }
}