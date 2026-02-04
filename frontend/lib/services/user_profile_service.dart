import '../models/user_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserProfileService {
  final Dio dio;

  // Use the auth path on the backend: GET /api/auth/profile and PUT /api/auth/edit-profile
  late final String baseUrl =
      kIsWeb
          ? 'http://localhost:8080/api/auth'
          : 'http://192.168.68.191:8080/api/auth';

  UserProfileService({required this.dio});

  /// Fetch current user profile. Requires Authorization header configured on Dio instance.
  Future<ProfileRequest?> getProfile() async {
    try {
      final response = await dio.get('$baseUrl/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ProfileRequest.fromJson(data);
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  /// Edit the user profile. Returns true on success.
  Future<bool> editProfile(
    String fullName,
    String email,
    String password,
    String language,
    String username,
  ) async {
    try {
      final response = await dio.put(
        '$baseUrl/edit-profile',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'language': language,
          'username': username,
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      // ignore
    }
    return false;
  }
}
