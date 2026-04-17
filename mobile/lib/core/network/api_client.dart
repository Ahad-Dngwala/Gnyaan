import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

/// Singleton Dio wrapper that automatically attaches the JWT token
/// to every outgoing request via an interceptor.
class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  bool _initialised = false;

  // ── SharedPreferences keys ──────────────────────────────────────────────────
  static const String _tokenKey = 'jwt_token';
  static const String _nameKey  = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _idKey    = 'user_id';

  // ── Initialise (call once in main) ──────────────────────────────────────────
  Future<void> init() async {
    if (_initialised) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Auth interceptor ────────────────────────────────────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Optional: auto-logout on 401
          return handler.next(error);
        },
      ),
    );

    _initialised = true;
  }

  // ── Convenience getters ─────────────────────────────────────────────────────
  Dio get dio => _dio;

  // ── Token persistence helpers ───────────────────────────────────────────────
  Future<void> saveAuthData({
    required String token,
    required String name,
    required String email,
    required String id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_idKey, id);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_idKey);
  }
}
