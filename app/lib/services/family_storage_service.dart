// services/family_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/family_models.dart';

class FamilyStorageService {
  static const String _familyGroupKey = 'family_group_data';
  static const String _familyMembersKey = 'family_members_data';
  static const String _memberLocationsKey = 'member_locations_data';
  static const String _userRoleKey = 'user_role_data';
  static const String _lastSyncKey = 'family_last_sync';
  static const String _locationSharingEnabledKey = 'location_sharing_enabled';

  // Save family group data
  static Future<void> saveFamilyGroup(FamilyGroup group) async {
    print('[FAMILY_STORAGE] 🏠 Saving family group: ${group.groupName}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_familyGroupKey, json.encode(group.toJson()));

    print('[FAMILY_STORAGE] 🏠 Family group saved successfully');
  }

  // Get family group data
  static Future<FamilyGroup?> getFamilyGroup() async {
    print('[FAMILY_STORAGE] 🏠 Retrieving family group...');

    final prefs = await SharedPreferences.getInstance();
    final groupJson = prefs.getString(_familyGroupKey);

    if (groupJson != null) {
      try {
        final groupData = json.decode(groupJson);
        final group = FamilyGroup.fromJson(groupData);
        print('[FAMILY_STORAGE] 🏠 Family group retrieved: ${group.groupName}');
        return group;
      } catch (e) {
        print('[FAMILY_STORAGE] 🏠 Error parsing family group: $e');
        return null;
      }
    }

    print('[FAMILY_STORAGE] 🏠 No family group found');
    return null;
  }

  // Save family members
  static Future<void> saveFamilyMembers(List<FamilyMember> members) async {
    print('[FAMILY_STORAGE] 👥 Saving ${members.length} family members');

    final prefs = await SharedPreferences.getInstance();
    final membersJson = members.map((m) => m.toJson()).toList();
    await prefs.setString(_familyMembersKey, json.encode(membersJson));

    print('[FAMILY_STORAGE] 👥 Family members saved successfully');
  }

  // Get family members
  static Future<List<FamilyMember>> getFamilyMembers() async {
    print('[FAMILY_STORAGE] 👥 Retrieving family members...');

    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getString(_familyMembersKey);

    if (membersJson != null) {
      try {
        final List<dynamic> membersList = json.decode(membersJson);
        final members = membersList.map((m) => FamilyMember.fromJson(m)).toList();
        print('[FAMILY_STORAGE] 👥 Retrieved ${members.length} family members');
        return members;
      } catch (e) {
        print('[FAMILY_STORAGE] 👥 Error parsing family members: $e');
        return [];
      }
    }

    print('[FAMILY_STORAGE] 👥 No family members found');
    return [];
  }

  // Save member locations
  static Future<void> saveMemberLocations(Map<String, MemberLocation> locations) async {
    print('[FAMILY_STORAGE] 📍 Saving locations for ${locations.length} members');

    final prefs = await SharedPreferences.getInstance();
    final locationsJson = <String, dynamic>{};

    locations.forEach((memberId, location) {
      locationsJson[memberId] = location.toJson();
    });

    await prefs.setString(_memberLocationsKey, json.encode(locationsJson));
    print('[FAMILY_STORAGE] 📍 Member locations saved successfully');
  }

  // Get member locations
  static Future<Map<String, MemberLocation>> getMemberLocations() async {
    print('[FAMILY_STORAGE] 📍 Retrieving member locations...');

    final prefs = await SharedPreferences.getInstance();
    final locationsJson = prefs.getString(_memberLocationsKey);

    if (locationsJson != null) {
      try {
        final Map<String, dynamic> locationsData = json.decode(locationsJson);
        final Map<String, MemberLocation> locations = {};

        locationsData.forEach((memberId, locationData) {
          locations[memberId] = MemberLocation.fromJson(locationData);
        });

        print('[FAMILY_STORAGE] 📍 Retrieved locations for ${locations.length} members');
        return locations;
      } catch (e) {
        print('[FAMILY_STORAGE] 📍 Error parsing member locations: $e');
        return {};
      }
    }

    print('[FAMILY_STORAGE] 📍 No member locations found');
    return {};
  }

  // Save user role
  static Future<void> saveUserRole(UserRole userRole) async {
    print('[FAMILY_STORAGE] 👤 Saving user role: ${userRole.role}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, json.encode(userRole.toJson()));

    print('[FAMILY_STORAGE] 👤 User role saved successfully');
  }

  // Get user role
  static Future<UserRole?> getUserRole() async {
    print('[FAMILY_STORAGE] 👤 Retrieving user role...');

    final prefs = await SharedPreferences.getInstance();
    final roleJson = prefs.getString(_userRoleKey);

    if (roleJson != null) {
      try {
        final roleData = json.decode(roleJson);
        final userRole = UserRole.fromJson(roleData);
        print('[FAMILY_STORAGE] 👤 User role retrieved: ${userRole.role}');
        return userRole;
      } catch (e) {
        print('[FAMILY_STORAGE] 👤 Error parsing user role: $e');
        return null;
      }
    }

    print('[FAMILY_STORAGE] 👤 No user role found');
    return null;
  }

  // Save last sync timestamp
  static Future<void> saveLastSync(DateTime timestamp) async {
    print('[FAMILY_STORAGE] ⏰ Saving last sync timestamp: ${timestamp.toIso8601String()}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, timestamp.toIso8601String());

    print('[FAMILY_STORAGE] ⏰ Last sync timestamp saved successfully');
  }

  // Get last sync timestamp
  static Future<DateTime?> getLastSync() async {
    print('[FAMILY_STORAGE] ⏰ Retrieving last sync timestamp...');

    final prefs = await SharedPreferences.getInstance();
    final syncJson = prefs.getString(_lastSyncKey);

    if (syncJson != null) {
      try {
        final timestamp = DateTime.parse(syncJson);
        print('[FAMILY_STORAGE] ⏰ Last sync timestamp retrieved: ${timestamp.toIso8601String()}');
        return timestamp;
      } catch (e) {
        print('[FAMILY_STORAGE] ⏰ Error parsing last sync timestamp: $e');
        return null;
      }
    }

    print('[FAMILY_STORAGE] ⏰ No last sync timestamp found');
    return null;
  }

  // Save location sharing preference
  static Future<void> saveLocationSharingEnabled(bool enabled) async {
    print('[FAMILY_STORAGE] 📡 Saving location sharing preference: $enabled');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationSharingEnabledKey, enabled);

    print('[FAMILY_STORAGE] 📡 Location sharing preference saved successfully');
  }

  // Get location sharing preference
  static Future<bool> getLocationSharingEnabled() async {
    print('[FAMILY_STORAGE] 📡 Retrieving location sharing preference...');

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_locationSharingEnabledKey) ?? true; // Default to true

    print('[FAMILY_STORAGE] 📡 Location sharing preference: $enabled');
    return enabled;
  }

  // Save complete family sync data
  static Future<void> saveFamilySyncData(FamilySyncResponse syncResponse) async {
    print('[FAMILY_STORAGE] 🔄 Saving complete family sync data...');

    try {
      // Save group data
      if (syncResponse.group != null) {
        await saveFamilyGroup(syncResponse.group!);
        await saveFamilyMembers(syncResponse.group!.members);
      }

      // Save locations
      final Map<String, MemberLocation> locationMap = {};
      for (int i = 0; i < syncResponse.locations.length; i++) {
        // Assuming locations are in same order as members
        if (syncResponse.group != null && i < syncResponse.group!.members.length) {
          locationMap[syncResponse.group!.members[i].memberId] = syncResponse.locations[i];
        }
      }
      await saveMemberLocations(locationMap);

      // Save sync timestamp
      await saveLastSync(syncResponse.timestamp);

      print('[FAMILY_STORAGE] 🔄 Complete family sync data saved successfully');
    } catch (e) {
      print('[FAMILY_STORAGE] 🔄 Error saving family sync data: $e');
      rethrow;
    }
  }

  // Get complete family data
  static Future<Map<String, dynamic>> getCompleteFamilyData() async {
    print('[FAMILY_STORAGE] 📊 Retrieving complete family data...');

    try {
      final group = await getFamilyGroup();
      final members = await getFamilyMembers();
      final locations = await getMemberLocations();
      final userRole = await getUserRole();
      final lastSync = await getLastSync();
      final locationSharingEnabled = await getLocationSharingEnabled();

      final data = {
        'group': group?.toJson(),
        'members': members.map((m) => m.toJson()).toList(),
        'locations': locations.map((key, value) => MapEntry(key, value.toJson())),
        'user_role': userRole?.toJson(),
        'last_sync': lastSync?.toIso8601String(),
        'location_sharing_enabled': locationSharingEnabled,
      };

      print('[FAMILY_STORAGE] 📊 Complete family data retrieved successfully');
      return data;
    } catch (e) {
      print('[FAMILY_STORAGE] 📊 Error retrieving complete family data: $e');
      return {};
    }
  }

  // Update specific member in storage
  static Future<void> updateMemberInStorage(FamilyMember updatedMember) async {
    print('[FAMILY_STORAGE] ✏️ Updating member in storage: ${updatedMember.name}');

    try {
      final members = await getFamilyMembers();
      final memberIndex = members.indexWhere((m) => m.memberId == updatedMember.memberId);

      if (memberIndex != -1) {
        members[memberIndex] = updatedMember;
        await saveFamilyMembers(members);
        print('[FAMILY_STORAGE] ✏️ Member updated in storage successfully');
      } else {
        print('[FAMILY_STORAGE] ✏️ Member not found in storage, adding as new member');
        members.add(updatedMember);
        await saveFamilyMembers(members);
      }
    } catch (e) {
      print('[FAMILY_STORAGE] ✏️ Error updating member in storage: $e');
      rethrow;
    }
  }

  // Remove member from storage
  static Future<void> removeMemberFromStorage(String memberId) async {
    print('[FAMILY_STORAGE] 🗑️ Removing member from storage: $memberId');

    try {
      final members = await getFamilyMembers();
      members.removeWhere((m) => m.memberId == memberId);
      await saveFamilyMembers(members);

      // Also remove location data for this member
      final locations = await getMemberLocations();
      locations.remove(memberId);
      await saveMemberLocations(locations);

      print('[FAMILY_STORAGE] 🗑️ Member removed from storage successfully');
    } catch (e) {
      print('[FAMILY_STORAGE] 🗑️ Error removing member from storage: $e');
      rethrow;
    }
  }

  // Update member location in storage
  static Future<void> updateMemberLocation(String memberId, MemberLocation location) async {
    print('[FAMILY_STORAGE] 📍 Updating member location: $memberId');

    try {
      final locations = await getMemberLocations();
      locations[memberId] = location;
      await saveMemberLocations(locations);
      print('[FAMILY_STORAGE] 📍 Member location updated successfully');
    } catch (e) {
      print('[FAMILY_STORAGE] 📍 Error updating member location: $e');
      rethrow;
    }
  }

  // Clear all family data
  static Future<void> clearAllFamilyData() async {
    print('[FAMILY_STORAGE] 🧹 Clearing all family data...');

    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_familyGroupKey),
        prefs.remove(_familyMembersKey),
        prefs.remove(_memberLocationsKey),
        prefs.remove(_userRoleKey),
        prefs.remove(_lastSyncKey),
        prefs.remove(_locationSharingEnabledKey),
      ]);

      print('[FAMILY_STORAGE] 🧹 All family data cleared successfully');
    } catch (e) {
      print('[FAMILY_STORAGE] 🧹 Error clearing family data: $e');
      rethrow;
    }
  }

  // Check if family data exists
  static Future<bool> hasFamilyData() async {
    print('[FAMILY_STORAGE] 🔍 Checking if family data exists...');

    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.containsKey(_familyGroupKey);

    print('[FAMILY_STORAGE] 🔍 Family data exists: $hasData');
    return hasData;
  }

  // Get storage info for debugging
  static Future<Map<String, dynamic>> getStorageInfo() async {
    print('[FAMILY_STORAGE] 📊 Getting storage info...');

    final prefs = await SharedPreferences.getInstance();

    final info = {
      'has_family_group': prefs.containsKey(_familyGroupKey),
      'has_family_members': prefs.containsKey(_familyMembersKey),
      'has_member_locations': prefs.containsKey(_memberLocationsKey),
      'has_user_role': prefs.containsKey(_userRoleKey),
      'has_last_sync': prefs.containsKey(_lastSyncKey),
      'has_location_sharing_pref': prefs.containsKey(_locationSharingEnabledKey),
      'last_sync': prefs.getString(_lastSyncKey),
      'location_sharing_enabled': prefs.getBool(_locationSharingEnabledKey),
    };

    print('[FAMILY_STORAGE] 📊 Storage info retrieved: $info');
    return info;
  }
}