
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/storage_service.dart';
import '../../language/language_controller.dart';
import 'edit_settings_screen.dart'; // Import the edit settings screen
import 'package:restart_app/restart_app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLanguage();
  }

  Future<void> _loadUserData() async {
    final data = await StorageService.getUserData();
    setState(() => userData = data);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language') ?? 'uz';
    setState(() => _selectedLang = code);
  }

  Future<void> _changeLanguage(String langCode) async {
    await LanguageController.setLanguage(langCode);
    setState(() => _selectedLang = langCode);
  }

  Future<void> _navigateToEditSettings() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSettingsScreen(),
      ),
    );

    // If data was updated, reload the user data
    if (result == true) {
      _loadUserData();
    }
  }

  // Helper method to safely get string values
  String _getSafeString(String key, [String defaultValue = 'Not provided']) {
    final value = userData?[key];
    return value?.toString() ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: userData == null
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
        ),
      )
          : Column(
        children: [
          // Header Section with Gradient (consistent with other screens)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[700]!, Colors.green[400]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    // App Bar Content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LanguageController.get('profile_appbar') ?? 'Profile & Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToEditSettings,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  LanguageController.get('profile_edit_button'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Profile Hero Section
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getSafeString('name', 'User')} ${_getSafeString('surname', '')}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _getSafeString('phone', 'No phone number'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selection Card
                  _buildSettingsCard(
                    title: LanguageController.get('language') ?? 'Language',
                    icon: Icons.language,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLang,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.green[600]),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (val) {
                            if (val != null) _changeLanguage(val);
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'uz',
                              child: Row(
                                children: [
                                  Text(LanguageController.get('uz') ?? 'Uzbek'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'ru',
                              child: Row(
                                children: [
                                  Text(LanguageController.get('ru') ?? 'Russian'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Row(
                                children: [
                                  Text(LanguageController.get('en') ?? 'English'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Personal Information Card
                  _buildSettingsCard(
                    title: LanguageController.get('personal_info') ?? 'Personal Information',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          LanguageController.get('age') ?? 'Age',
                          _getSafeString('age', 'Not provided'),
                          Icons.cake_outlined,
                        ),
                        _buildInfoRow(
                          LanguageController.get('email') ?? 'Email',
                          _getSafeString('email', 'Not provided'),
                          Icons.email_outlined,
                        ),
                        _buildInfoRow(
                          LanguageController.get('gender') ?? 'Gender',
                          _getSafeString('gender', 'Not specified'),
                          Icons.wc_outlined,
                        ),
                        _buildInfoRow(
                          LanguageController.get('passport') ?? 'Passport',
                          _getSafeString('passport', 'Not provided'),
                          Icons.credit_card_outlined,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Medical Information Card
                  _buildSettingsCard(
                    title: LanguageController.get('medical_info') ?? 'Medical Information',
                    icon: Icons.medical_information_outlined,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          LanguageController.get('blood_type') ?? 'Blood Type',
                          _getSafeString('blood_type', 'Not specified'),
                          Icons.bloodtype_outlined,
                        ),
                        _buildInfoRow(
                          LanguageController.get('allergies') ?? 'Allergies',
                          _getSafeString('allergies', 'None specified'),
                          Icons.warning_amber_outlined,
                        ),
                        _buildInfoRow(
                          LanguageController.get('illness') ?? 'Medical Conditions',
                          _getSafeString('illness', LanguageController.get('none') ?? 'None'),
                          Icons.local_hospital_outlined,
                        ),
                        if (_getSafeString('additional_info', '').isNotEmpty)
                          _buildInfoRow(
                            LanguageController.get('additional') ?? 'Additional Info',
                            _getSafeString('additional_info'),
                            Icons.info_outline,
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.green.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 24),
                          SizedBox(width: 12),
                          Text(
                            LanguageController.get('logout') ?? 'Logout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          LanguageController.get('confirm_logout') ?? 'Confirm Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(LanguageController.get('logout_message') ?? 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              LanguageController.get('cancel') ?? 'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(LanguageController.get('logout') ?? 'Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await StorageService.clearAll();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      Restart.restartApp();
    }
  }
}