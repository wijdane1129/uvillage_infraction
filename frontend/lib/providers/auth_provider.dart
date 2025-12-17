import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
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
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> signUp(CreateAccountRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _authService.signUp(request);
      state = state.copyWith(
        isLoading: false,
        successMessage: response.success ? response.message : null,
        error: !response.success ? response.message : null,
        lastResponse: response,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _authService.forgotPassword(request);
      state = state.copyWith(
        isLoading: false,
        successMessage: response.success ? response.message : null,
        error: !response.success ? response.message : null,
        lastResponse: response,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authService.resetPassword(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
  }

  Future<void> verifyCode(VerificationCodeRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authService.verifyCode(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
  }

  Future<AuthResponse> verifyResetCode(VerificationCodeRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authService.verifyResetCode(request);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
    return response;
  }

  Future<AuthResponse> resendVerificationCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authService.resendVerificationCode(email);
    state = state.copyWith(
      isLoading: false,
      lastResponse: response,
      successMessage: response.success ? response.message : null,
      error: !response.success ? response.message : null,
    );
    return response;
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
