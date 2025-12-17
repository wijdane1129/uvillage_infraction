// lib/services/file_upload_service.dart
import 'dart:io';
import 'package:dio/dio.dart';

class FileUploadService {
  final Dio dio;

  final String baseUrl = 'http://localhost:8080/api/contravention/media';

  FileUploadService({required this.dio});
  
  Future<Map<String, dynamic>> uploadEvidenceFile({
    required int rowid,
    required File file,
    required String type,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
        'mediaType': type,
      });

      final response = await dio.post(
        '$baseUrl/upload/$rowid',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );

      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      rethrow;
    }
  }

  // Other helper methods (download/delete/list) can be added similarly if needed by the app.
}