class CreateAccountRequest {
  final String username;
  final String email;
  final String password;
  CreateAccountRequest({
    required this.username,
    required this.email,
    required this.password,
  });
  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'password': password};
  }
}

class ResetPasswordRequest {
  final String password;
  final String confirmPassword;
  final String token;
  ResetPasswordRequest({
    required this.password,
    required this.confirmPassword,
    required this.token,
  });
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'confirmPassword': confirmPassword,
      'token': token,
    };
  }
}

class ForgotPasswordRequest {
  final String email;
  ForgotPasswordRequest({required this.email});
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class VerificationCodeRequest {
  final String email;
  final String code;
  VerificationCodeRequest({required this.email, required this.code});
  Map<String, dynamic> toJson() {
    return {'email': email, 'code': code};
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final dynamic data;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      token: json['token'],
      data: json['data'],
    );
  }
}
