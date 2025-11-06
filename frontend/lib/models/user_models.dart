class ProfileRequest {
  final String fullName;
  final String email;
  final String password;
  final String language;

  ProfileRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'language': language,
    };
  }

  factory ProfileRequest.fromJson(Map<String, dynamic> json) {
    return ProfileRequest(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      language: json['language'] ?? 'en',
    );
  }
}
