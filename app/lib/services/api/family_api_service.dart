// services/family_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/family_models.dart';
import '../../data/family_dummy_data.dart';
import '../storage_service.dart';
import './url.dart';

class FamilyApiService {
  static const String _baseUrl = Urls.apiBaseUrl;
  static const String _familyEndpoint = '/api/family';

  // For development/testing - set to true to use dummy data
  static const bool _useDummyData = true;

  // Get authorization header
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getUserToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Handle HTTP errors
  static Map<String, dynamic> _handleHttpError(http.Response response) {
    print('[FAMILY_API] ❌ HTTP Error ${response.statusCode}: ${response.body}');

    try {
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'An error occurred',
        'error_code': response.statusCode,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Server error occurred',
        'error_code': response.statusCode,
        'data': null,
      };
    }
  }

  // Create a new family group
  static Future<Map<String, dynamic>> createGroup(
      CreateGroupRequest request) async {
    print('[FAMILY_API] 🏠 Creating family group: ${request.groupName}');

    if (_useDummyData) {
      await Future.delayed(
          Duration(milliseconds: 500)); // Simulate network delay
      return FamilyDummyData.simulateCreateGroup(request);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_familyEndpoint/create'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 🏠 Family group created successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 🏠 Error creating family group: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to create family group',
        'data': null,
      };
    }
  }

  // Get user's family group
  static Future<Map<String, dynamic>> getMyGroup() async {
    print('[FAMILY_API] 📋 Getting my family group...');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 300));
      return FamilyDummyData.simulateGetMyGroup();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_familyEndpoint/my-group'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 📋 Family group retrieved successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 📋 Error getting family group: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to retrieve family group',
        'data': null,
      };
    }
  }

  // Add a member to the family group
  static Future<Map<String, dynamic>> addMember(
      AddMemberRequest request) async {
    print('[FAMILY_API] 👥 Adding family member: ${request.name}');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 400));
      return FamilyDummyData.simulateAddMember(request);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_familyEndpoint/members'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 👥 Family member added successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 👥 Error adding family member: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to add family member',
        'data': null,
      };
    }
  }

  // Update a family member
  static Future<Map<String, dynamic>> updateMember(String memberId,
      UpdateMemberRequest request) async {
    print('[FAMILY_API] ✏️ Updating family member: $memberId');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 350));
      return FamilyDummyData.simulateUpdateMember(memberId, request);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl$_familyEndpoint/members/$memberId'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] ✏️ Family member updated successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] ✏️ Error updating family member: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to update family member',
        'data': null,
      };
    }
  }

  // Remove a family member
  static Future<Map<String, dynamic>> removeMember(String memberId) async {
    print('[FAMILY_API] 🗑️ Removing family member: $memberId');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 300));
      return FamilyDummyData.simulateRemoveMember(memberId);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl$_familyEndpoint/members/$memberId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('[FAMILY_API] 🗑️ Family member removed successfully');
        return {
          'success': true,
          'message': 'Family member removed successfully',
        };
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 🗑️ Error removing family member: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to remove family member',
      };
    }
  }

  // Delete the entire family group
  static Future<Map<String, dynamic>> deleteGroup() async {
    print('[FAMILY_API] 🗑️ Deleting family group...');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 400));
      return FamilyDummyData.simulateDeleteGroup();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl$_familyEndpoint/group'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('[FAMILY_API] 🗑️ Family group deleted successfully');
        return {
          'success': true,
          'message': 'Family group deleted successfully',
        };
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 🗑️ Error deleting family group: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to delete family group',
      };
    }
  }

  // Update user's location
  static Future<Map<String, dynamic>> setLocation(
      LocationUpdate locationUpdate) async {
    print('[FAMILY_API] 📍 Setting location: ${locationUpdate
        .lat}, ${locationUpdate.lng}');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 200));
      return FamilyDummyData.simulateSetLocation(locationUpdate);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$_familyEndpoint/location'),
        headers: headers,
        body: json.encode(locationUpdate.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 📍 Location updated successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 📍 Error setting location: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to update location',
        'data': null,
      };
    }
  }

  // Get all member locations
  static Future<Map<String, dynamic>> getMemberLocations() async {
    print('[FAMILY_API] 🗺️ Getting member locations...');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 250));
      return FamilyDummyData.simulateGetMemberLocations();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_familyEndpoint/locations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 🗺️ Member locations retrieved successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 🗺️ Error getting member locations: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to get member locations',
        'data': null,
      };
    }
  }

  // Get selectable members (for emergency contacts, etc.)
  static Future<Map<String, dynamic>> getSelectableMembers() async {
    print('[FAMILY_API] 👥 Getting selectable members...');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 200));
      return FamilyDummyData.simulateGetSelectableMembers();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_familyEndpoint/members/selectable'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 👥 Selectable members retrieved successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 👥 Error getting selectable members: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to get selectable members',
        'data': null,
      };
    }
  }

  // Get user's role in the family
  static Future<Map<String, dynamic>> getMyRole() async {
    print('[FAMILY_API] 👤 Getting my role...');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 150));
      return FamilyDummyData.simulateGetMyRole();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_familyEndpoint/my-role'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 👤 User role retrieved successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 👤 Error getting user role: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to get user role',
        'data': null,
      };
    }
  }

  // Set role for a family member
  static Future<Map<String, dynamic>> setRole(String memberId,
      String relation) async {
    print('[FAMILY_API] 👤 Setting role for member: $memberId to $relation');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 300));
      return FamilyDummyData.simulateSetRole(memberId, relation);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl$_familyEndpoint/members/$memberId/role'),
        headers: headers,
        body: json.encode({'relation': relation}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 👤 Member role updated successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 👤 Error setting member role: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to set member role',
        'data': null,
      };
    }
  }

  // Sync all family data
  static Future<Map<String, dynamic>> syncFamilyData() async {
    print('[FAMILY_API] 🔄 Syncing family data...');

    if (_useDummyData) {
      await Future.delayed(Duration(milliseconds: 600));
      return FamilyDummyData.simulateSync();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$_familyEndpoint/sync'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[FAMILY_API] 🔄 Family data synced successfully');
        return data;
      } else {
        return _handleHttpError(response);
      }
    } catch (e) {
      print('[FAMILY_API] 🔄 Error syncing family data: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to sync family data',
        'data': null,
      };
    }
  }
}