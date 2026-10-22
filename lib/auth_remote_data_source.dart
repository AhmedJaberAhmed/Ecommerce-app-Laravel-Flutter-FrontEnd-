import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:laravel/user_model.dart';

import 'TokenStorage.dart';
import 'app_exception.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({Dio? dio, TokenStorage? tokenStorage})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ),
        _tokens = tokenStorage ?? TokenStorage();

  final Dio _dio;
  final TokenStorage _tokens;

  // CHANGE THIS to your PC's IPv4 address (run `ipconfig`).
  // Phone and PC must be on the same Wi-Fi, and the server must run with:
  //   php artisan serve --host=0.0.0.0 --port=8000
  static const String _pcIp = '192.168.1.4';

  // Set to true only when running on the Android emulator.
  static const bool _useEmulator = false;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _useEmulator
          ? 'http://10.0.2.2:8000/api'
          : 'http://$_pcIp:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _post('/login', {'email': email, 'password': password});
    await _tokens.save(data['token'].toString());
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _post('/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _post(
      String path,
      Map<String, dynamic> body,
      ) async {
    try {
      final res = await _dio.post(path, data: body);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('DIO ERROR: ${e.type} | ${e.message} | ${e.error}');
      throw AppException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Cannot reach the server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}