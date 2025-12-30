import 'package:dio/dio.dart';
import '../client.dart';
import '../config.dart';
import '../models/profile.dart';

class ProfileService {
  final ApiClient _client = ApiClient();

  Future<bool> hasProfile() async {
    try {
      final profile = await getProfile();
      if (profile.name.isEmpty) return false;
      if (profile.gender.isEmpty) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<ProfileResponse> setupProfile(String name, String gender) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.profilePrefix}/setup',
        data: {'name': name, 'gender': gender},
      );
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Profile> getProfile() async {
    try {
      final response = await _client.dio.get(ApiConfig.profilePrefix);
      return Profile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProfileResponse> updateProfile(String name, String gender) async {
    try {
      final response = await _client.dio.put(
        '${ApiConfig.profilePrefix}/update',
        data: {'name': name, 'gender': gender},
      );
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'An error occurred: ${error.response!.statusCode}';
    }
    return error.message ?? 'An unexpected error occurred';
  }
}
