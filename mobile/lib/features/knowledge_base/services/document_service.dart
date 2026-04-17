import 'package:dio/dio.dart';
import 'package:gnyaan/core/network/api_client.dart';
import 'package:gnyaan/core/network/api_endpoints.dart';

/// Service layer for document upload and retrieval API calls.
class DocumentService {
  final ApiClient _api = ApiClient();

  /// Fetch all documents uploaded by the current user.
  Future<List<Map<String, dynamic>>> getUserDocuments() async {
    try {
      final response = await _api.dio.get(ApiEndpoints.userDocuments);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final docs = data['documents'] as List<dynamic>;
        return docs.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Failed to fetch documents';
      throw Exception(msg);
    }
  }

  /// Upload one or more files via multipart form-data.
  /// [filePaths] is a list of absolute file paths on device.
  /// [fileNames] is the corresponding list of original file names.
  Future<Map<String, dynamic>> uploadFiles({
    required List<String> filePaths,
    required List<String> fileNames,
  }) async {
    try {
      final formData = FormData();

      for (var i = 0; i < filePaths.length; i++) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              filePaths[i],
              filename: fileNames[i],
            ),
          ),
        );
      }

      final response = await _api.dio.post(
        ApiEndpoints.uploadIngestion,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Upload failed';
      throw Exception(msg);
    }
  }
}
