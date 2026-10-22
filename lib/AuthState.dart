
import 'package:laravel/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}