class Team {
  final int id;
  final String name;
  final String description;
  final int teamLeader;
  final String teamLeaderName;
  final int maxMembers;
  final String memberCount;
  final String availableSpots;
  final String isFull;
  final bool isActive;
  final int createdBy;
  final String createdByName;
  final List<TeamMember> members;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.teamLeader,
    required this.teamLeaderName,
    required this.maxMembers,
    required this.memberCount,
    required this.availableSpots,
    required this.isFull,
    required this.isActive,
    required this.createdBy,
    required this.createdByName,
    required this.members,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      teamLeader: json['team_leader'] ?? 0,
      teamLeaderName: json['team_leader_name'] ?? '',
      maxMembers: json['max_members'] ?? 0,
      memberCount: json['member_count']?.toString() ?? '0',
      availableSpots: json['available_spots']?.toString() ?? '0',
      isFull: json['is_full']?.toString() ?? 'false',
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'] ?? 0,
      createdByName: json['created_by_name'] ?? '',
      members: json['members'] != null
          ? (json['members'] as List)
              .map((memberJson) => TeamMember.fromJson(memberJson))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'team_leader': teamLeader,
      'team_leader_name': teamLeaderName,
      'max_members': maxMembers,
      'member_count': memberCount,
      'available_spots': availableSpots,
      'is_full': isFull,
      'is_active': isActive,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'members': members.map((member) => member.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  int get currentMemberCount => members.length;
  int get actualAvailableSpots => maxMembers - currentMemberCount;
  bool get hasAvailableSpots => actualAvailableSpots > 0;
  bool get isUserTeamLeader => teamLeader != 0;
}

class TeamMember {
  final int id;
  final User user;
  final String role;
  final DateTime joinedAt;
  final bool isActive;

  TeamMember({
    required this.id,
    required this.user,
    required this.role,
    required this.joinedAt,
    required this.isActive,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      role: json['role'] ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  // Helper methods
  bool get isLeader => role.toLowerCase() == 'leader';
  bool get isMember => role.toLowerCase() == 'member';
  String get displayRole => role.toUpperCase();
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class TeamCreateRequest {
  final String name;
  final String description;
  final int maxMembers;

  TeamCreateRequest({
    required this.name,
    required this.description,
    required this.maxMembers,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'max_members': maxMembers,
    };
  }
}

class TeamUpdateRequest {
  final String? name;
  final String? description;
  final int? maxMembers;
  final bool? isActive;

  TeamUpdateRequest({
    this.name,
    this.description,
    this.maxMembers,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (maxMembers != null) data['max_members'] = maxMembers;
    if (isActive != null) data['is_active'] = isActive;
    return data;
  }
}