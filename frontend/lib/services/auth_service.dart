import 'package:dio/dio.dart';
import '../models/auth_models.dart';

class AuthService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.example.com'; // Replace with actual API

  AuthService(this._dio) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<AuthResponse> signUp(CreateAccountRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Sign up failed',
      );
    }
  }

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Request failed',
      );
    }
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Reset failed',
      );
    }
  }

  Future<AuthResponse> verifyCode(VerificationCodeRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-code',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Verification failed',
      );
    }
  }
}
