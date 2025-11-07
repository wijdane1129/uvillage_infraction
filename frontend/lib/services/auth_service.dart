import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import '../models/auth_models.dart';
import 'storage_service.dart';

class LoginResponse {
  final String token;
  final String? email;

  LoginResponse({required this.token, this.email});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: (json['token'] ?? json['accessToken'] ?? '') as String,
      email: json['email'] as String?,
    );
  }
}

class AuthService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  static String get _baseHost {
    if (kIsWeb) return 'http://127.0.0.1:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  // Login endpoint uses the /api/v1/auth path (backend has mixed controllers; login is under v1)
  String _authV1(String path) => '$_baseHost/api/v1/auth$path';
  // Other auth endpoints (signup/forgot/reset/verify) are under /api/auth in the backend
  String _authLegacy(String path) => '$_baseHost/api/auth$path';

  Future<LoginResponse> login(String email, String password) async {
    try {
      final resp = await _dio.post(
        _authV1('/login'),
        data: {'email': email, 'password': password},
      );
      final lr = LoginResponse.fromJson(Map<String, dynamic>.from(resp.data));
      if (lr.token.isNotEmpty) {
        await _storage.saveToken(lr.token);
      }
      return lr;
    } on DioException catch (e) {
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Request failed';
      throw Exception(message);
    }
  }

  static Future<String?> getToken() async {
    final s = StorageService();
    return await s.getToken();
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  // The following methods return AuthResponse which matches the provider expectations
  Future<AuthResponse> signUp(CreateAccountRequest request) async {
    try {
      final resp = await _dio.post(
        _authLegacy('/sign-up'),
        data: request.toJson(),
      );
      return AuthResponse.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.response?.data?.toString() ?? e.message ?? 'Request failed',
      );
    }
  }

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final resp = await _dio.post(
        _authLegacy('/forgot-password'),
        data: request.toJson(),
      );
      return AuthResponse.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.response?.data?.toString() ?? e.message ?? 'Request failed',
      );
    }
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final resp = await _dio.post(
        _authLegacy('/reset-password'),
        data: request.toJson(),
      );
      return AuthResponse.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.response?.data?.toString() ?? e.message ?? 'Request failed',
      );
    }
  }

  Future<AuthResponse> verifyCode(VerificationCodeRequest request) async {
    try {
      final resp = await _dio.post(
        _authLegacy('/verify-code'),
        data: request.toJson(),
      );
      return AuthResponse.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.response?.data?.toString() ?? e.message ?? 'Request failed',
      );
    }
  }

  Future<AuthResponse> verifyResetCode(VerificationCodeRequest request) async {
    try {
      final resp = await _dio.post(
        _authLegacy('/verify-reset-code'),
        data: request.toJson(),
      );
      return AuthResponse.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.response?.data?.toString() ?? e.message ?? 'Request failed',
      );
    }
  }
}
