import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

final dioProvider = Provider((ref) => Dio());

final authServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});


class AuthState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final AuthResponse? lastResponse;

  AuthState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.lastResponse,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    AuthResponse? lastResponse,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService) : super(AuthState());

  Future<void> signUp(CreateAccountRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await authService.signUp(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await authService.forgotPassword(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await authService.resetPassword(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
  }

  Future<void> verifyCode(VerificationCodeRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await authService.verifyCode(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
