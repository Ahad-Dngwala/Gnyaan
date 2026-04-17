import 'package:dio/dio.dart';
import 'package:gnyaan/core/network/api_client.dart';
import 'package:gnyaan/core/network/api_endpoints.dart';

/// Service layer for document summary API calls.
class SummaryService {
  final ApiClient _api = ApiClient();

  /// Generate (or fetch cached) summary + TL;DR for a given document.
  /// Returns a map with `summary`, `tldr`, `title`, `cached`, `responseTimeMs`.
  Future<Map<String, dynamic>> getSummary(String documentId) async {
    try {
      final response = await _api.dio.post(
        ApiEndpoints.generateSummary,
        data: {'documentId': documentId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Failed to generate summary';
      throw Exception(msg);
    }
  }
}
