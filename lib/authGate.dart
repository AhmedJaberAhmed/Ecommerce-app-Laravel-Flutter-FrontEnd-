import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';
import 'TokenStorage.dart';
import 'auth_remote_data_source.dart';
import 'homepage.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasValidSession() async {
    final tokens = TokenStorage();
    final token = await tokens.read();
    if (token == null) return false;
    try {
      await Dio(BaseOptions(
        baseUrl: AuthRemoteDataSourceImpl.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )).get('/user');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await tokens.clear();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasValidSession(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return snap.data == true ? const HomePage() : const LoginPage();
      },
    );
  }
}