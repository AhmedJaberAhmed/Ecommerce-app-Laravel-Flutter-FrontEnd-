
import 'package:laravel/user_entity.dart';

import 'app_exception.dart';
import 'auth_remote_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSourceImpl();

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.login(email: email, password: password);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }
}