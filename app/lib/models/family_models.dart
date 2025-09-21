// models/family_models.dart

class FamilyGroup {
  final String groupId;
  final String groupName;
  final String ownerId;
  final List<FamilyMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyGroup({
    required this.groupId,
    required this.groupName,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  FamilyGroup copyWith({
    String? groupId,
    String? groupName,
    String? ownerId,
    List<FamilyMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyGroup(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FamilyGroup.fromJson(Map<String, dynamic> json) {
    return FamilyGroup(
      groupId: json['group_id'] ?? '',
      groupName: json['group_name'] ?? '',
      ownerId: json['owner_id'] ?? '',
      members: (json['members'] as List<dynamic>?)
          ?.map((m) => FamilyMember.fromJson(m))
          .toList() ?? [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'owner_id': ownerId,
      'members': members.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class FamilyMember {
  final String memberId;
  final String name;
  final String relation;
  final String? phone;
  final String? userId; // null if not a registered user
  final String? medicalInfo;
  bool isEmergencyContact; // Changed from 'late final' to just 'bool'
  final MemberLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMember({
    required this.memberId,
    required this.name,
    required this.relation,
    this.phone,
    this.userId,
    this.medicalInfo,
    this.isEmergencyContact = false,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      memberId: json['member_id'] ?? '',
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      phone: json['phone'],
      userId: json['user_id'],
      medicalInfo: json['medical_info'],
      isEmergencyContact: json['is_emergency_contact'] ?? false,
      location: json['location'] != null
          ? MemberLocation.fromJson(json['location'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'name': name,
      'relation': relation,
      'phone': phone,
      'user_id': userId,
      'medical_info': medicalInfo,
      'is_emergency_contact': isEmergencyContact,
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FamilyMember copyWith({
    String? memberId,
    String? name,
    String? relation,
    String? phone,
    String? userId,
    String? medicalInfo,
    bool? isEmergencyContact,
    MemberLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyMember(
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
class MemberLocation {
  final double lat;
  final double lng;
  final String status; // "ok", "in_emergency", "offline"
  final DateTime updatedAt;

  MemberLocation({
    required this.lat,
    required this.lng,
    required this.status,
    required this.updatedAt,
  });

  factory MemberLocation.fromJson(Map<String, dynamic> json) {
    return MemberLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'offline',
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'status': status,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreateGroupRequest {
  final String groupName;

  CreateGroupRequest({required this.groupName});

  Map<String, dynamic> toJson() {
    return {'group_name': groupName};
  }
}

class AddMemberRequest {
  final String name;
  final String relation;
  final String? phone;
  final String? userId;
  final String? medicalInfo;
  final bool isEmergencyContact;

  AddMemberRequest({
    required this.name,
    required this.relation,
    this.phone,
    this.userId,
    this.medicalInfo,
    this.isEmergencyContact = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'phone': phone,
      'user_id': userId,
      'medical_info': medicalInfo,
      'is_emergency_contact': isEmergencyContact,
    };
  }
}

class UpdateMemberRequest {
  final String? name;
  final String? relation;
  final String? phone;
  final String? medicalInfo;
  final bool? isEmergencyContact;

  UpdateMemberRequest({
    this.name,
    this.relation,
    this.phone,
    this.medicalInfo,
    this.isEmergencyContact,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (relation != null) json['relation'] = relation;
    if (phone != null) json['phone'] = phone;
    if (medicalInfo != null) json['medical_info'] = medicalInfo;
    if (isEmergencyContact != null) json['is_emergency_contact'] = isEmergencyContact;
    return json;
  }
}

class LocationUpdate {
  final double lat;
  final double lng;
  final String status;

  LocationUpdate({
    required this.lat,
    required this.lng,
    this.status = 'ok',
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'status': status,
    };
  }
}

class UserRole {
  final String groupId;
  final String role;

  UserRole({
    required this.groupId,
    required this.role,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      groupId: json['group_id'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'role': role,
    };
  }
}

class FamilySyncResponse {
  final FamilyGroup? group;
  final List<MemberLocation> locations;
  final DateTime timestamp;

  FamilySyncResponse({
    this.group,
    required this.locations,
    required this.timestamp,
  });

  factory FamilySyncResponse.fromJson(Map<String, dynamic> json) {
    return FamilySyncResponse(
      group: json['group'] != null ? FamilyGroup.fromJson(json['group']) : null,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((l) => MemberLocation.fromJson(l))
          .toList() ?? [],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}