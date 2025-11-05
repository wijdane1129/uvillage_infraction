import '../models/auth_models.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

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
}
