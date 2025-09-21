import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Storage keys
  static const String _tokenKey = 'user_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _locationSharingKey = 'location_sharing_enabled';

  // Initialize storage service
  static Future<void> init() async {
    print('[APP] 🚀 StorageService.init() - Starting...');

    _prefs = await SharedPreferences.getInstance();
    print('[APP] 🚀 SharedPreferences instance initialized');
    print('[APP] 🚀 StorageService.init() - Completed');
  }

  // ==========================================
  // TOKEN MANAGEMENT
  // ==========================================

  // Save user access token
  static Future<void> saveUserToken(String token) async {
    print('[APP] 🔐 StorageService.saveUserToken() - Starting...');
    print('[APP] 🔐 Access token to save: $token');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔐 SharedPreferences instance obtained');

    await prefs.setString(_tokenKey, token);
    print('[APP] 🔐 Access token saved successfully: $token');

    await prefs.setBool(_isLoggedInKey, true);
    print('[APP] 🔐 Login state saved: true');
    print('[APP] 🔐 StorageService.saveUserToken() - Completed');
  }

  // Get user access token
  static Future<String?> getUserToken() async {
    print('[APP] 🔑 StorageService.getUserToken() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    print('[APP] 🔑 Retrieved access token: ${token != null ? '[TOKEN_EXISTS]' : 'null'}');
    print('[APP] 🔑 StorageService.getUserToken() - Completed');
    return token;
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    print('[APP] 🔄 StorageService.saveRefreshToken() - Starting...');
    print('[APP] 🔄 Refresh token to save: $refreshToken');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔄 SharedPreferences instance obtained');

    await prefs.setString(_refreshTokenKey, refreshToken);
    print('[APP] 🔄 Refresh token saved successfully');
    print('[APP] 🔄 StorageService.saveRefreshToken() - Completed');
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    print('[APP] 🔄 StorageService.getRefreshToken() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);

    print('[APP] 🔄 Retrieved refresh token: ${refreshToken != null ? '[REFRESH_TOKEN_EXISTS]' : 'null'}');
    print('[APP] 🔄 StorageService.getRefreshToken() - Completed');
    return refreshToken;
  }

  // Clear access token
  static Future<void> clearUserToken() async {
    print('[APP] 🔐 StorageService.clearUserToken() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔐 SharedPreferences instance obtained');

    await prefs.remove(_tokenKey);
    print('[APP] 🔐 Access token cleared successfully');
    print('[APP] 🔐 StorageService.clearUserToken() - Completed');
  }

  // Clear refresh token
  static Future<void> clearRefreshToken() async {
    print('[APP] 🔄 StorageService.clearRefreshToken() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔄 SharedPreferences instance obtained');

    await prefs.remove(_refreshTokenKey);
    print('[APP] 🔄 Refresh token cleared successfully');
    print('[APP] 🔄 StorageService.clearRefreshToken() - Completed');
  }

  // Clear all tokens
  static Future<void> clearAllTokens() async {
    print('[APP] 🔥 StorageService.clearAllTokens() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔥 SharedPreferences instance obtained');

    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoggedInKey, false);

    print('[APP] 🔥 All tokens cleared successfully');
    print('[APP] 🔥 Login state set to false');
    print('[APP] 🔥 StorageService.clearAllTokens() - Completed');
  }

  // Save both tokens at once (for login/registration)
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    print('[APP] 🔐 StorageService.saveTokens() - Starting...');
    print('[APP] 🔐 Saving access and refresh tokens');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔐 SharedPreferences instance obtained');

    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setBool(_isLoggedInKey, true);

    print('[APP] 🔐 Both tokens saved successfully');
    print('[APP] 🔐 Login state saved: true');
    print('[APP] 🔐 StorageService.saveTokens() - Completed');
  }

  // ==========================================
  // USER DATA MANAGEMENT
  // ==========================================

  // Save login user data (from login response)
  static Future<void> saveLoginUserData(Map<String, dynamic> userData) async {
    print('[APP] 👤 StorageService.saveLoginUserData() - Starting...');
    print('[APP] 👤 User data to save: ${json.encode(userData)}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 👤 SharedPreferences instance obtained');

    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] 👤 Login user data saved successfully');
    print('[APP] 👤 StorageService.saveLoginUserData() - Completed');
  }

  // Save registration user data (from registration flow)
  static Future<void> saveUserData(PersonalData personal, MedicalData medical) async {
    print('[APP] 📋 StorageService.saveUserData() - Starting...');
    print('[APP] 📋 Personal data: name=${personal.name}, surname=${personal.surname}, email=${personal.email}');
    print('[APP] 📋 Medical data: bloodType=${medical.bloodType}, allergies=${medical.allergies}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📋 SharedPreferences instance obtained');

    final userData = {
      'name': personal.name,
      'surname': personal.surname,
      'email': personal.email,
      'phone': personal.phone,
      'age': personal.age,
      'gender': personal.gender,
      'passport': personal.passport,
      'blood_type': medical.bloodType,
      'allergies': medical.allergies,
      'illness': medical.illness,
      'additional_info': medical.additionalInfo,
    };

    print('[APP] 📋 Saving registration data: ${json.encode(userData)}');
    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] 📋 Registration data saved successfully');
    print('[APP] 📋 StorageService.saveUserData() - Completed');
  }

  // Save updated user data (from edit settings)
  static Future<void> saveUpdatedUserData(Map<String, dynamic> userData) async {
    print('[APP] ✏️ StorageService.saveUpdatedUserData() - Starting...');
    print('[APP] ✏️ Updated user data: ${json.encode(userData)}');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] ✏️ SharedPreferences instance obtained');

    await prefs.setString(_userDataKey, json.encode(userData));
    print('[APP] ✏️ Updated user data saved successfully');
    print('[APP] ✏️ StorageService.saveUpdatedUserData() - Completed');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    print('[APP] 📖 StorageService.getUserData() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📖 SharedPreferences instance obtained');

    final userDataString = prefs.getString(_userDataKey);
    print('[APP] 📖 Raw user data string: ${userDataString != null ? '[DATA_EXISTS]' : 'null'}');

    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString);
        print('[APP] 📖 User data decoded successfully');
        print('[APP] 📖 StorageService.getUserData() - Completed with data');
        return userData;
      } catch (e) {
        print('[APP] 📖 Error decoding user data: $e');
        print('[APP] 📖 StorageService.getUserData() - Completed with error');
        return null;
      }
    }

    print('[APP] 📖 No user data found');
    print('[APP] 📖 StorageService.getUserData() - Completed with null');
    return null;
  }

  // ==========================================
  // AUTHENTICATION STATUS
  // ==========================================

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    print('[APP] 🔍 StorageService.isLoggedIn() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔍 SharedPreferences instance obtained');

    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final hasAccessToken = prefs.getString(_tokenKey) != null;

    // User is logged in if both flag is true AND token exists
    final actuallyLoggedIn = isLoggedIn && hasAccessToken;

    print('[APP] 🔍 Login flag: $isLoggedIn');
    print('[APP] 🔍 Has access token: $hasAccessToken');
    print('[APP] 🔍 Actually logged in: $actuallyLoggedIn');
    print('[APP] 🔍 StorageService.isLoggedIn() - Completed');

    return actuallyLoggedIn;
  }

  // Set login status
  static Future<void> setLoginStatus(bool status) async {
    print('[APP] 🔧 StorageService.setLoginStatus() - Starting...');
    print('[APP] 🔧 Setting login status to: $status');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔧 SharedPreferences instance obtained');

    await prefs.setBool(_isLoggedInKey, status);
    print('[APP] 🔧 Login status updated successfully');
    print('[APP] 🔧 StorageService.setLoginStatus() - Completed');
  }

  // ==========================================
  // EMERGENCY CONTACTS
  // ==========================================

  // Save emergency contacts
  static Future<void> saveEmergencyContacts(List<Map<String, dynamic>> contacts) async {
    print('[APP] 🆘 StorageService.saveEmergencyContacts() - Starting...');
    print('[APP] 🆘 Emergency contacts to save: ${contacts.length} contacts');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🆘 SharedPreferences instance obtained');

    await prefs.setString(_emergencyContactsKey, json.encode(contacts));
    print('[APP] 🆘 Emergency contacts saved successfully');
    print('[APP] 🆘 StorageService.saveEmergencyContacts() - Completed');
  }

  // Get emergency contacts
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    print('[APP] 🆘 StorageService.getEmergencyContacts() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🆘 SharedPreferences instance obtained');

    final contactsString = prefs.getString(_emergencyContactsKey);
    print('[APP] 🆘 Raw contacts string: ${contactsString != null ? '[CONTACTS_EXIST]' : 'null'}');

    if (contactsString != null) {
      try {
        final contacts = List<Map<String, dynamic>>.from(json.decode(contactsString));
        print('[APP] 🆘 Emergency contacts decoded: ${contacts.length} contacts');
        print('[APP] 🆘 StorageService.getEmergencyContacts() - Completed with data');
        return contacts;
      } catch (e) {
        print('[APP] 🆘 Error decoding emergency contacts: $e');
        print('[APP] 🆘 StorageService.getEmergencyContacts() - Completed with error');
        return [];
      }
    }

    print('[APP] 🆘 No emergency contacts found');
    print('[APP] 🆘 StorageService.getEmergencyContacts() - Completed with empty list');
    return [];
  }

  // ==========================================
  // LOCATION SHARING
  // ==========================================

  // Save location sharing preference
  static Future<void> setLocationSharingEnabled(bool enabled) async {
    print('[APP] 📍 StorageService.setLocationSharingEnabled() - Starting...');
    print('[APP] 📍 Setting location sharing to: $enabled');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📍 SharedPreferences instance obtained');

    await prefs.setBool(_locationSharingKey, enabled);
    print('[APP] 📍 Location sharing preference saved successfully');
    print('[APP] 📍 StorageService.setLocationSharingEnabled() - Completed');
  }

  // Get location sharing preference
  static Future<bool> isLocationSharingEnabled() async {
    print('[APP] 📍 StorageService.isLocationSharingEnabled() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 📍 SharedPreferences instance obtained');

    final enabled = prefs.getBool(_locationSharingKey) ?? false;
    print('[APP] 📍 Location sharing enabled: $enabled');
    print('[APP] 📍 StorageService.isLocationSharingEnabled() - Completed');

    return enabled;
  }

  // ==========================================
  // CLEANUP METHODS
  // ==========================================

  // Clear user data only (keep tokens)
  static Future<void> clearUserData() async {
    print('[APP] 🧹 StorageService.clearUserData() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🧹 SharedPreferences instance obtained');

    await prefs.remove(_userDataKey);
    print('[APP] 🧹 User data cleared successfully');
    print('[APP] 🧹 StorageService.clearUserData() - Completed');
  }

  // Clear emergency contacts
  static Future<void> clearEmergencyContacts() async {
    print('[APP] 🧹 StorageService.clearEmergencyContacts() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🧹 SharedPreferences instance obtained');

    await prefs.remove(_emergencyContactsKey);
    print('[APP] 🧹 Emergency contacts cleared successfully');
    print('[APP] 🧹 StorageService.clearEmergencyContacts() - Completed');
  }

  // Logout user (clear tokens and set login status to false)
  static Future<void> logout() async {
    print('[APP] 🚪 StorageService.logout() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🚪 SharedPreferences instance obtained');

    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoggedInKey, false);

    print('[APP] 🚪 User logged out successfully');
    print('[APP] 🚪 All tokens cleared and login status set to false');
    print('[APP] 🚪 StorageService.logout() - Completed');
  }

  // Clear all data (complete reset)
  static Future<void> clearAll() async {
    print('[APP] 🔥 StorageService.clearAll() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    print('[APP] 🔥 SharedPreferences instance obtained');

    await prefs.clear();
    print('[APP] 🔥 All data cleared successfully');
    print('[APP] 🔥 StorageService.clearAll() - Completed');
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  // Get all stored keys (for debugging)
  static Future<Set<String>> getAllKeys() async {
    print('[APP] 🔍 StorageService.getAllKeys() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    print('[APP] 🔍 Stored keys: $keys');
    print('[APP] 🔍 StorageService.getAllKeys() - Completed');

    return keys;
  }

  // Check if a specific key exists
  static Future<bool> hasKey(String key) async {
    print('[APP] 🔍 StorageService.hasKey() - Starting...');
    print('[APP] 🔍 Checking for key: $key');

    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey(key);

    print('[APP] 🔍 Key exists: $exists');
    print('[APP] 🔍 StorageService.hasKey() - Completed');

    return exists;
  }

  // Get storage stats (for debugging)
  static Future<Map<String, dynamic>> getStorageStats() async {
    print('[APP] 📊 StorageService.getStorageStats() - Starting...');

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final stats = {
      'total_keys': keys.length,
      'has_access_token': prefs.containsKey(_tokenKey),
      'has_refresh_token': prefs.containsKey(_refreshTokenKey),
      'has_user_data': prefs.containsKey(_userDataKey),
      'is_logged_in': prefs.getBool(_isLoggedInKey) ?? false,
      'has_emergency_contacts': prefs.containsKey(_emergencyContactsKey),
      'location_sharing_enabled': prefs.getBool(_locationSharingKey) ?? false,
      'all_keys': keys.toList(),
    };

    print('[APP] 📊 Storage stats: $stats');
    print('[APP] 📊 StorageService.getStorageStats() - Completed');

    return stats;
  }
}