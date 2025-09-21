// data/family_dummy_data.dart
import '../models/family_models.dart';

class FamilyDummyData {
  static String _currentUserId = 'user123'; // This should match the logged-in user
  static FamilyGroup? _currentGroup;
  static Map<String, FamilyMember> _members = {};
  static Map<String, MemberLocation> _locations = {};

  // Predefined dummy family group
  static void _initializeDummyData() {
    if (_currentGroup == null) {
      print('[FAMILY] 🏠 Initializing dummy family data...');

      _currentGroup = FamilyGroup(
        groupId: 'family_abc123',
        groupName: "Kamoliddin's Family",
        ownerId: _currentUserId,
        members: [],
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      // Create some dummy members
      final dummyMembers = [
        FamilyMember(
          memberId: 'member_001',
          name: 'Mom',
          relation: 'mother',
          phone: '+998901234567',
          userId: null,
          medicalInfo: 'diabetic, high blood pressure',
          isEmergencyContact: true,
          createdAt: DateTime.now().subtract(Duration(days: 25)),
          updatedAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        FamilyMember(
          memberId: 'member_002',
          name: 'Dad',
          relation: 'father',
          phone: '+998907654321',
          userId: null,
          medicalInfo: 'asthma',
          isEmergencyContact: true,
          createdAt: DateTime.now().subtract(Duration(days: 25)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        ),
        FamilyMember(
          memberId: 'member_003',
          name: 'Sister Aysha',
          relation: 'sister',
          phone: '+998909876543',
          userId: 'user456',
          medicalInfo: 'allergic to peanuts',
          isEmergencyContact: false,
          createdAt: DateTime.now().subtract(Duration(days: 20)),
          updatedAt: DateTime.now().subtract(Duration(minutes: 30)),
        ),
      ];

      for (var member in dummyMembers) {
        _members[member.memberId] = member;
      }

      // Create dummy locations
      _locations = {
        'member_001': MemberLocation(
          lat: 41.2995,
          lng: 69.2401,
          status: 'ok',
          updatedAt: DateTime.now().subtract(Duration(minutes: 15)),
        ),
        'member_002': MemberLocation(
          lat: 41.3111,
          lng: 69.2797,
          status: 'ok',
          updatedAt: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        'member_003': MemberLocation(
          lat: 41.2856,
          lng: 69.2034,
          status: 'ok',
          updatedAt: DateTime.now().subtract(Duration(minutes: 45)),
        ),
      };

      _currentGroup = _currentGroup!.copyWith(
        members: _members.values.toList(),
      );

      print('[FAMILY] 🏠 Dummy family data initialized with ${_members.length} members');
    }
  }

  static Map<String, dynamic> simulateCreateGroup(CreateGroupRequest request) {
    print('[FAMILY] 🏠 Simulating create group: ${request.groupName}');

    _initializeDummyData();

    // Simulate creating a new group
    final newGroupId = 'family_${DateTime.now().millisecondsSinceEpoch}';
    _currentGroup = FamilyGroup(
      groupId: newGroupId,
      groupName: request.groupName,
      ownerId: _currentUserId,
      members: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _members.clear();
    _locations.clear();

    return {
      'success': true,
      'message': 'Family group created successfully',
      'data': {
        'group_id': newGroupId,
        'group_name': request.groupName,
        'owner_id': _currentUserId,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  static Map<String, dynamic> simulateAddMember(AddMemberRequest request) {
    print('[FAMILY] 👥 Simulating add member: ${request.name} (${request.relation})');

    _initializeDummyData();

    if (_currentGroup == null) {
      return {
        'success': false,
        'message': 'No family group found. Create a group first.',
      };
    }

    final newMemberId = 'member_${DateTime.now().millisecondsSinceEpoch}';
    final newMember = FamilyMember(
      memberId: newMemberId,
      name: request.name,
      relation: request.relation,
      phone: request.phone,
      userId: request.userId,
      medicalInfo: request.medicalInfo,
      isEmergencyContact: request.isEmergencyContact,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _members[newMemberId] = newMember;

    return {
      'success': true,
      'message': 'Family member added successfully',
      'data': newMember.toJson(),
    };
  }

  static Map<String, dynamic> simulateGetMyGroup() {
    print('[FAMILY] 📋 Simulating get my group');

    _initializeDummyData();

    if (_currentGroup == null) {
      return {
        'success': false,
        'message': 'No family group found',
        'data': null,
      };
    }

    // Update group with current members
    final updatedGroup = FamilyGroup(
      groupId: _currentGroup!.groupId,
      groupName: _currentGroup!.groupName,
      ownerId: _currentGroup!.ownerId,
      members: _members.values.toList(),
      createdAt: _currentGroup!.createdAt,
      updatedAt: DateTime.now(),
    );

    return {
      'success': true,
      'message': 'Family group retrieved successfully',
      'data': updatedGroup.toJson(),
    };
  }

  static Map<String, dynamic> simulateUpdateMember(String memberId, UpdateMemberRequest request) {
    print('[FAMILY] ✏️ Simulating update member: $memberId');

    _initializeDummyData();

    if (!_members.containsKey(memberId)) {
      return {
        'success': false,
        'message': 'Family member not found',
      };
    }

    final currentMember = _members[memberId]!;
    final updatedMember = currentMember.copyWith(
      name: request.name ?? currentMember.name,
      relation: request.relation ?? currentMember.relation,
      phone: request.phone ?? currentMember.phone,
      medicalInfo: request.medicalInfo ?? currentMember.medicalInfo,
      isEmergencyContact: request.isEmergencyContact ?? currentMember.isEmergencyContact,
      updatedAt: DateTime.now(),
    );

    _members[memberId] = updatedMember;

    return {
      'success': true,
      'message': 'Family member updated successfully',
      'data': updatedMember.toJson(),
    };
  }

  static Map<String, dynamic> simulateRemoveMember(String memberId) {
    print('[FAMILY] 🗑️ Simulating remove member: $memberId');

    _initializeDummyData();

    if (!_members.containsKey(memberId)) {
      return {
        'success': false,
        'message': 'Family member not found',
      };
    }

    _members.remove(memberId);
    _locations.remove(memberId);

    return {
      'success': true,
      'message': 'Family member removed successfully',
    };
  }

  static Map<String, dynamic> simulateDeleteGroup() {
    print('[FAMILY] 🗑️ Simulating delete group');

    _currentGroup = null;
    _members.clear();
    _locations.clear();

    return {
      'success': true,
      'message': 'Family group deleted successfully',
    };
  }

  static Map<String, dynamic> simulateSetLocation(LocationUpdate locationUpdate) {
    print('[FAMILY] 📍 Simulating set location: ${locationUpdate.lat}, ${locationUpdate.lng}');

    _initializeDummyData();

    // Find current user's member record (if they're in the family)
    final currentUserMember = _members.values
        .where((m) => m.userId == _currentUserId)
        .firstOrNull;

    if (currentUserMember != null) {
      _locations[currentUserMember.memberId] = MemberLocation(
        lat: locationUpdate.lat,
        lng: locationUpdate.lng,
        status: locationUpdate.status,
        updatedAt: DateTime.now(),
      );
    }

    return {
      'success': true,
      'message': 'Location updated successfully',
    };
  }

  static Map<String, dynamic> simulateGetMemberLocations() {
    print('[FAMILY] 🗺️ Simulating get member locations');

    _initializeDummyData();

    final List<Map<String, dynamic>> locations = [];

    for (final member in _members.values) {
      final location = _locations[member.memberId];
      if (location != null) {
        locations.add({
          'member_id': member.memberId,
          'name': member.name,
          'relation': member.relation,
          'lat': location.lat,
          'lng': location.lng,
          'status': location.status,
          'updated_at': location.updatedAt.toIso8601String(),
        });
      }
    }

    return {
      'success': true,
      'message': 'Member locations retrieved successfully',
      'data': locations,
    };
  }

  static Map<String, dynamic> simulateGetSelectableMembers() {
    print('[FAMILY] 👥 Simulating get selectable members');

    _initializeDummyData();

    final List<Map<String, dynamic>> selectableMembers = _members.values
        .map((member) => {
      'member_id': member.memberId,
      'name': member.name,
      'relation': member.relation,
      'phone': member.phone,
      'medical_info': member.medicalInfo,
      'is_emergency_contact': member.isEmergencyContact,
    })
        .toList();

    return {
      'success': true,
      'message': 'Selectable members retrieved successfully',
      'data': selectableMembers,
    };
  }

  static Map<String, dynamic> simulateGetMyRole() {
    print('[FAMILY] 👤 Simulating get my role');

    _initializeDummyData();

    if (_currentGroup == null) {
      return {
        'success': false,
        'message': 'No family group found',
      };
    }

    // Check if current user is the owner
    if (_currentGroup!.ownerId == _currentUserId) {
      return {
        'success': true,
        'message': 'User role retrieved successfully',
        'data': {
          'group_id': _currentGroup!.groupId,
          'role': 'owner',
        }
      };
    }

    // Find user's role from members
    final userMember = _members.values
        .where((m) => m.userId == _currentUserId)
        .firstOrNull;

    if (userMember != null) {
      return {
        'success': true,
        'message': 'User role retrieved successfully',
        'data': {
          'group_id': _currentGroup!.groupId,
          'role': userMember.relation,
        }
      };
    }

    return {
      'success': false,
      'message': 'User not found in family group',
    };
  }

  static Map<String, dynamic> simulateSetRole(String memberId, String relation) {
    print('[FAMILY] 👤 Simulating set role for member: $memberId to $relation');

    _initializeDummyData();

    if (!_members.containsKey(memberId)) {
      return {
        'success': false,
        'message': 'Family member not found',
      };
    }

    final currentMember = _members[memberId]!;
    _members[memberId] = currentMember.copyWith(
      relation: relation,
      updatedAt: DateTime.now(),
    );

    return {
      'success': true,
      'message': 'Member role updated successfully',
    };
  }

  static Map<String, dynamic> simulateSync() {
    print('[FAMILY] 🔄 Simulating family sync');

    _initializeDummyData();

    if (_currentGroup == null) {
      return {
        'success': false,
        'message': 'No family group found',
        'data': null,
      };
    }

    // Update group with current members
    final updatedGroup = FamilyGroup(
      groupId: _currentGroup!.groupId,
      groupName: _currentGroup!.groupName,
      ownerId: _currentGroup!.ownerId,
      members: _members.values.toList(),
      createdAt: _currentGroup!.createdAt,
      updatedAt: DateTime.now(),
    );

    // Get all locations
    final List<MemberLocation> locations = [];
    for (final member in _members.values) {
      final location = _locations[member.memberId];
      if (location != null) {
        locations.add(location);
      }
    }

    final syncResponse = FamilySyncResponse(
      group: updatedGroup,
      locations: locations,
      timestamp: DateTime.now(),
    );

    return {
      'success': true,
      'message': 'Family data synced successfully',
      'data': {
        'group': updatedGroup.toJson(),
        'locations': locations.map((l) => l.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      }
    };
  }

  // Utility method to set current user ID (for testing)
  static void setCurrentUserId(String userId) {
    _currentUserId = userId;
    print('[FAMILY] 👤 Current user ID set to: $userId');
  }

  // Utility method to reset all data
  static void reset() {
    _currentGroup = null;
    _members.clear();
    _locations.clear();
    print('[FAMILY] 🔄 Family dummy data reset');
  }
}