import 'package:cybershield/models/user_model.dart';
import 'package:cybershield/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _authService = AuthService.instance;

  Future<void> checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    state = state.copyWith(
      status: isLoggedIn
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated);
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.response?.data?['message'] as String? ?? 'فشل تسجيل الدخول',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.register(
        firstName: data['first_name'] as String,
        lastName: data['last_name'] as String,
        username: data['username'] as String,
        email: data['email'] as String,
        phoneNumber: data['phone_number'] as String,
        gender: data['gender'] as String,
        dateOfBirth: data['date_of_birth'] as String,
        residence: data['residence'] as String,
        password: data['password'] as String,
      );
      state = state.copyWith(status: AuthStatus.authenticated);
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.response?.data?['message'] as String? ?? 'فشل إنشاء الحساب',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier()..checkAuth(),
);
