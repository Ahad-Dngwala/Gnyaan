import 'package:dio/dio.dart';
import 'package:gnyaan/core/network/api_client.dart';
import 'package:gnyaan/core/network/api_endpoints.dart';

/// Service layer for authentication API calls.
class AuthService {
  final ApiClient _api = ApiClient();

  /// Register a new user. Returns a Map with user data + token on success.
  /// Throws on network / validation errors.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['token'] != null) {
        await _api.saveAuthData(
          token: data['token'],
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          id: data['_id'] ?? '',
        );
      }

      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed';
      throw Exception(msg);
    }
  }

  /// Login an existing user. Returns a Map with user data + token on success.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['token'] != null) {
        await _api.saveAuthData(
          token: data['token'],
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          id: data['_id'] ?? '',
        );
      }

      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Login failed';
      throw Exception(msg);
    }
  }

  /// Logout — clears persisted auth data.
  Future<void> logout() async {
    await _api.clearAuth();
  }
}
