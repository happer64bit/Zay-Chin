class Group {
  final String id;
  final String name;
  final int totalMembers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    required this.id,
    required this.name,
    required this.totalMembers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      totalMembers: (json['total_members'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class GroupMember {
  final String id;
  final String groupId;
  final String profileId;
  final DateTime createdAt;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.profileId,
    required this.createdAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      profileId: json['profile_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Invitation {
  final String id;
  final String groupId;
  final String status;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.groupId,
    required this.status,
    required this.createdAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

