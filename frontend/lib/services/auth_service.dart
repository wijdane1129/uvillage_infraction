import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;

import '../models/auth_models.dart';
import 'storage_service.dart';
import 'api_service.dart';

/// Modèle pour la réponse du backend lors d'un login
class LoginResponse {
  final String token;
  final int? agentRowid;
  final String? nomComplet;
  final String email;
  final String? role;

  LoginResponse({
    required this.token,
    this.agentRowid,
    this.nomComplet,
    required this.email,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final tokenValue = json['token']?.toString() ?? '';
    final agentRowidValue = json['agentRowid'] as int?;
    final nomCompletValue = json['nomComplet'] as String?;
    final emailValue = json['email']?.toString() ?? '';
    final roleValue = json['role'] as String?;

    if (kDebugMode) {
      print('🔍 [AUTH RESPONSE] Données reçues du backend:');
      print(
        '   Token: ${tokenValue.isNotEmpty ? "${tokenValue.substring(0, 20)}..." : "VIDE"}',
      );
      print('   Agent Rowid: $agentRowidValue');
      print('   Nom Complet: $nomCompletValue');
      print('   Email: $emailValue');
      print('   Role: $roleValue');
    }

    return LoginResponse(
      token: tokenValue,
      agentRowid: agentRowidValue,
      nomComplet: nomCompletValue,
      email: emailValue,
      role: roleValue,
    );
  }
}

class AuthService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

  static const String _authBoxName = 'authBox';

  static String get _baseHost {
    if (kIsWeb) {
      // Web (Edge browser): use localhost
      return 'http://localhost:8080';
    } else {
      // Mobile (Android phone): use network IP
      return 'http://192.168.8.167:8080';
    }
  }

  // Login endpoint uses the /api/v1/auth path
  String _authV1(String path) => '$_baseHost/api/v1/auth$path';
  // Other auth endpoints under /api/auth
  String _authLegacy(String path) => '$_baseHost/api/auth$path';

  // --------------------
  // LOGIN
  // --------------------
  Future<LoginResponse> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('📡 [AUTH] Tentative de connexion pour: $email');
      }
      final response = await _dio.post(
        _authV1('/login'),
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      if (loginResponse.token.isNotEmpty) {
        await _saveToken(loginResponse.token);
        // Persist role for frontend routing / UI access control
        final authBox =
            Hive.isBoxOpen(_authBoxName)
                ? Hive.box(_authBoxName)
                : await Hive.openBox(_authBoxName);
        if (loginResponse.role != null) {
          await authBox.put('role', loginResponse.role);
        }
        // Also save to secure storage for other services that read from it
        try {
          final storage = StorageService();
          await storage.saveToken(loginResponse.token);
        } catch (_) {}
      }
      return loginResponse;
    } on DioException catch (e) {
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Request failed';
      throw Exception(message);
    }
  }

  Future<void> _saveToken(String token) async {
    final authBox =
        Hive.isBoxOpen(_authBoxName)
            ? Hive.box(_authBoxName)
            : await Hive.openBox(_authBoxName);
    await authBox.put('jwt_token', token);
    if (kDebugMode) print('🔒 [AUTH] Token sauvegardé dans Hive');
    // Temporary: print full token in debug to allow manual curl testing
    if (kDebugMode) {
      try {
        print('🔐 [AUTH DEBUG] Full token: $token');
      } catch (_) {}
    }
  }

  static Future<String?> getToken() async {
    if (!Hive.isBoxOpen(_authBoxName)) await Hive.openBox(_authBoxName);
    final authBox = Hive.box(_authBoxName);
    final token = authBox.get('jwt_token') as String?;
    if (kDebugMode && token != null) {
      print('🔑 [AUTH] Token récupéré: ${token.substring(0, 20)}...');
    }
    return token;
  }

  static Future<void> logout() async {
    if (!Hive.isBoxOpen(_authBoxName)) await Hive.openBox(_authBoxName);
    final authBox = Hive.box(_authBoxName);
    await authBox.delete('jwt_token');
    if (kDebugMode) print('🔒 [AUTH] Token supprimé de Hive');
  }

  // --------------------
  // SIGN-UP / PASSWORD / VERIFICATION
  // --------------------
  Future<AuthResponse> signUp(CreateAccountRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/sign-up',
        request.toJson(),
      );
      if (response.data['accessToken'] != null) {
        await _storageService.saveToken(response.data['accessToken']);
      }
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> verifyCode(VerificationCodeRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-code',
        request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> verifyResetCode(VerificationCodeRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-reset-code',
        request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> resendVerificationCode(String email) async {
    try {
      final response = await _apiService.post('/auth/resend-code', {
        'email': email,
      });
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  /// Change password while authenticated or as profile update.
  Future<Map<String, dynamic>> changePassword(
    String email,
    String? currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await AuthService.getToken();
      final options = Options(headers: {});
      if (token != null && token.isNotEmpty) {
        options.headers?['Authorization'] = 'Bearer $token';
      }

      final Map<String, dynamic> payload = {
        'email': email,
        'newPassword': newPassword,
      };
      if (currentPassword != null && currentPassword.isNotEmpty) {
        payload['currentPassword'] = currentPassword;
      }

      final response = await _dio.post(
        '$_baseHost/api/auth/change-password',
        data: payload,
        options: options,
      );

      if (response.statusCode == 200) {
        final msg =
            response.data is Map && response.data['message'] != null
                ? response.data['message'].toString()
                : 'Password changed successfully';
        return {'success': true, 'message': msg};
      }

      final fallback = response.data?.toString() ?? 'Unexpected response';
      return {'success': false, 'message': fallback};
    } on DioException catch (e) {
      String msg = 'Network error';
      if (e.response != null) {
        msg = e.response?.data?.toString() ?? 'Server error';
      } else if (e.message != null) {
        msg = e.message as String;
      }
      if (kDebugMode) print('❌ [AUTH] changePassword DioException: $msg');
      return {'success': false, 'message': msg};
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH] changePassword error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
