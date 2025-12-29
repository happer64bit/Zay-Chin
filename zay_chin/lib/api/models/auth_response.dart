class AuthResponse {
  final String message;
  final AuthData data;

  AuthResponse({
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      data: AuthData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class AuthData {
  final Auth auth;

  AuthData({required this.auth});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      auth: Auth.fromJson(json['auth'] as Map<String, dynamic>),
    );
  }
}

class Auth {
  final String accessToken;

  Auth({required this.accessToken});

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      accessToken: json['access_token'] as String,
    );
  }
}

