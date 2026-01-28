class LoginModel {
  final String accessToken;
  final String tokenType;

  const LoginModel({
    required this.accessToken,
    required this.tokenType,
  });

  /// Parse from API response
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  /// Convert to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  /// Copy with updated values
  LoginModel copyWith({
    String? accessToken,
    String? tokenType,
  }) {
    return LoginModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }
}
