import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';


abstract class AuthLocalDataSource {

  Future<void> saveToken(String token);


  Future<String?> getToken();


  Future<void> clearToken();


  Future<bool> hasToken();


  Future<void> saveUser(UserModel user);


  Future<UserModel?> getCachedUser();


  Future<void> clearUser();


  Future<void> clearAll();
}


class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;


  static const String _tokenKey = 'auth_token';
  static const String _cachedUserKey = 'cached_user';


  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read auth token: $e');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth token: $e');
    }
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _prefs.setString(_cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user data: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = _prefs.getString(_cachedUserKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {

      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _prefs.remove(_cachedUserKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached user: $e');
    }
  }


  @override
  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
