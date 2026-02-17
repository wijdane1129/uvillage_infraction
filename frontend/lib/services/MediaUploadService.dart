// lib/services/media_upload_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class MediaUploadService {
  final Dio _dio = ApiClient.dio;

  /// Upload a media file to the backend
  /// Returns the media URL on success
  Future<String> uploadMedia({
    required File file,
    required String mediaType,
  }) async {
    try {
      print('📤 [MediaUpload] Uploading file: ${file.path}');
      print('📤 [MediaUpload] Media type: $mediaType');

      // CRITICAL: Create MultipartFile from file path
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'mediaType': mediaType,
      });

      final response = await _dio.post(
        '/media/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final mediaUrl = response.data['mediaUrl'] as String;
        print('✅ [MediaUpload] Upload successful');
        print('✅ [MediaUpload] Server URL: $mediaUrl');
        return mediaUrl;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [MediaUpload] Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ [MediaUpload] Response: ${e.response?.data}');
      }
      throw Exception('Media upload failed: $e');
    }
  }

  /// Upload multiple media files
  Future<List<String>> uploadMultipleMedia({
    required List<File> files,
    required List<String> mediaTypes,
  }) async {
    if (files.length != mediaTypes.length) {
      throw ArgumentError('Files and mediaTypes must have the same length');
    }

    final results = <String>[];

    for (int i = 0; i < files.length; i++) {
      try {
        final result = await uploadMedia(
          file: files[i],
          mediaType: mediaTypes[i],
        );
        results.add(result);
      } catch (e) {
        print('⚠️ [MediaUpload] Failed to upload file $i: $e');
        rethrow;
      }
    }

    return results;
  }

  /// Get media info by ID
  Future<Map<String, dynamic>?> getMediaInfo(int mediaId) async {
    try {
      final response = await _dio.get('/media/$mediaId');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('❌ [MediaUpload] Error getting media info: $e');
      return null;
    }
  }

  /// Delete media by ID
  Future<bool> deleteMedia(int mediaId) async {
    try {
      final response = await _dio.delete('/media/$mediaId');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [MediaUpload] Error deleting media: $e');
      return false;
    }
  }
}