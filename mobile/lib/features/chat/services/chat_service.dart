import 'package:dio/dio.dart';
import 'package:gnyaan/core/network/api_client.dart';
import 'package:gnyaan/core/network/api_endpoints.dart';

/// Service layer for chat API calls.
class ChatService {
  final ApiClient _api = ApiClient();

  /// Send a query to the RAG chat engine.
  /// Returns the response map with `answer`, `isFallback`, `responseTimeMs`, `sources`.
  Future<Map<String, dynamic>> sendQuery(String query) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.chat,
        data: {'query': query},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Chat request failed';
      throw Exception(msg);
    }
  }

  /// Fetch entire chat history for the current user.
  /// Returns a list of message maps with `role`, `text`, `timestamp`, etc.
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.chatHistory);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['messages'] != null) {
        final messages = data['messages'] as List<dynamic>;
        return messages.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Failed to fetch chat history';
      throw Exception(msg);
    }
  }
}
