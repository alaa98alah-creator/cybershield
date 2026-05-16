import 'package:cybershield/core/constants/api_constants.dart';
import 'package:cybershield/models/auth_models.dart';
import 'package:cybershield/services/network_service.dart';
import 'package:cybershield/services/token_storage.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  factory AuthService() => instance;

  final _network = NetworkService();
  final _tokenStorage = TokenStorage();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _network.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _tokenStorage.saveToken(authResponse.token);
      await _tokenStorage.saveUserId(authResponse.userId);
      return authResponse;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String residence,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        residence: residence,
        password: password,
      );
      print('🔴 REGISTER REQUEST: ${request.toJson()}');
      final response = await _network.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      print('🟢 REGISTER RESPONSE: ${response.statusCode} ${response.data}');
      final authResponse = AuthResponse.fromJson(response.data);
      await _tokenStorage.saveToken(authResponse.token);
      await _tokenStorage.saveUserId(authResponse.userId);
      return authResponse;
    } on DioException catch (e) {
      print('🔴 DIO ERROR: ${e.response?.statusCode} ${e.response?.data} ${e.message}');
      rethrow;
    } catch (e, stack) {
      print('🔴 CATCH ERROR: $e\n$stack');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasToken();
  }
}
