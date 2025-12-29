import 'package:dio/dio.dart';
import '../client.dart';
import '../config.dart';
import '../models/group.dart';

class GroupService {
  final ApiClient _client = ApiClient();

  Future<List<Group>> getGroups() async {
    try {
      final response = await _client.dio.get(ApiConfig.groupPrefix);
      final List<dynamic> data = response.data;
      return data.map((json) => Group.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Group> getGroupById(String id) async {
    try {
      final response = await _client.dio.get('${ApiConfig.groupPrefix}/$id');
      return Group.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<GroupMember>> getGroupMembers(String id) async {
    try {
      final response = await _client.dio.get('${ApiConfig.groupPrefix}/$id/members');
      final List<dynamic> data = response.data;
      return data.map((json) => GroupMember.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Invitation>> getInvites() async {
    try {
      final response = await _client.dio.get('${ApiConfig.groupPrefix}/invites');
      final List<dynamic> data = response.data;
      return data.map((json) => Invitation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Group> createGroup(String name) async {
    try {
      final response = await _client.dio.post(
        ApiConfig.groupPrefix,
        data: {'name': name},
      );
      return Group.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> inviteToGroup(String groupId, String email) async {
    try {
      await _client.dio.post(
        '${ApiConfig.groupPrefix}/$groupId/invite',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    try {
      await _client.dio.post('${ApiConfig.groupPrefix}/invites/$invitationId/accept', data: {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _client.dio.post('${ApiConfig.groupPrefix}/invites/$invitationId/reject');
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


