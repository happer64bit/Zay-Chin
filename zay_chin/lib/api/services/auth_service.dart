import 'package:dio/dio.dart';
import '../client.dart';
import '../config.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.authPrefix}/create',
        data: {
          'email': email,
          'password': password,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      _client.setAccessToken(authResponse.data.auth.accessToken);
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.authPrefix}/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        _client.setAccessToken(authResponse.data.auth.accessToken);
        return authResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getSession() async {
    try {
      final response = await _client.dio.get('${ApiConfig.authPrefix}/session');
      return UserResponse.fromJson(response.data).data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    _client.clearToken();
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'An error occurred: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      print(error);
      return 'Unable to connect to server. Please check your connection.';
    }
    return error.message ?? 'An unexpected error occurred';
  }
}
