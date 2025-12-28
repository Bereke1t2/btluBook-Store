import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

abstract class LocalData {
  Future<void> cacheUser(UserModel user , String token);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<String?> getToken();
}

class LocaldataImpl implements LocalData {
  final SharedPreferences sharedPreferences;

  LocaldataImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(UserModel user , String token) async {
    await sharedPreferences.setString('user', json.encode(user.toJson()));
    await sharedPreferences.setString('token', token);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString('user');
    if (userJson != null) {
      try{
        return UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        // Handle error
        return throw Exception('Failed to parse cached user: $e');
      }
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove('user');
    await sharedPreferences.remove('token');
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString('token');
  }
}