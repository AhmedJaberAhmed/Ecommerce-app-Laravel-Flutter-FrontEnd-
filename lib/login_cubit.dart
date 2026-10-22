import 'package:flutter_bloc/flutter_bloc.dart';

import 'AuthState.dart';
import 'auth_repository.dart';
import 'auth_repository_impl.dart';

class LoginCubit extends Cubit<AuthState> {
  LoginCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl(),
        super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(email: email, password: password);
      if (isClosed) return;
      emit(AuthSuccess(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthFailure(e.toString()));
    }
  }
}