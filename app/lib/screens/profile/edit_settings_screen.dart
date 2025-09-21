import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api/api_service.dart';
import '../../services/storage_service.dart';

import '../../language/language_controller.dart';

class EditSettingsScreen extends StatefulWidget {
  const EditSettingsScreen({super.key});

  @override
  _EditSettingsScreenState createState() => _EditSettingsScreenState();
}

class _EditSettingsScreenState extends State<EditSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _passportController;
  late TextEditingController _allergiesController;
  late TextEditingController _illnessController;
  late TextEditingController _additionalInfoController;

  String _selectedGender = 'Male';
  String _selectedBloodType = 'A+';

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Map<String, dynamic>? _originalData;

  // Phone number formatting helper
  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // If user enters 9 digits, format as +998 xx xxx xx xx
    if (digitsOnly.length == 9) {
      return '+998$digitsOnly';
    }

    // If already starts with 998, add + prefix
    if (digitsOnly.startsWith('998') && digitsOnly.length == 10) {
      return '+$digitsOnly';
    }

    return phone;
  }

  String _getFormattedPhoneForJson() {
    String phone = _phoneController.text.trim();
    return _formatPhoneNumber(phone);
  }

  // Extract 9 digits from full phone number for display in input field
  String _extractPhoneDigits(String fullPhone) {
    if (fullPhone.startsWith('+998') && fullPhone.length == 13) {
      return fullPhone.substring(4); // Remove +998 prefix
    }
    if (fullPhone.startsWith('998') && fullPhone.length == 10) {
      return fullPhone.substring(3); // Remove 998 prefix
    }
    return fullPhone;
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
    _passportController = TextEditingController();
    _allergiesController = TextEditingController();
    _illnessController = TextEditingController();
    _additionalInfoController = TextEditingController();

    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _surnameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _passportController.addListener(_onFieldChanged);
    _allergiesController.addListener(_onFieldChanged);
    _illnessController.addListener(_onFieldChanged);
    _additionalInfoController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _loadUserData() async {
    final data = await StorageService.getUserData();
    if (data != null) {
      setState(() {
        _originalData = Map.from(data);
        _nameController.text = data['name'] ?? '';
        _surnameController.text = data['surname'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = _extractPhoneDigits(data['phone'] ?? '');
        _ageController.text = data['age']?.toString() ?? '';
        _passportController.text = data['passport'] ?? '';
        _allergiesController.text = data['allergies'] ?? '';
        _illnessController.text = data['illness'] ?? '';
        _additionalInfoController.text = data['additional_info'] ?? '';
        _selectedGender = data['gender'] ?? 'Male';
        _selectedBloodType = data['blood_type'] ?? 'A+';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _getFormattedPhoneForJson(), // Format phone as +998xxxxxxx
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender,
        'passport': _passportController.text.trim(),
        'blood_type': _selectedBloodType,
        'allergies': _allergiesController.text.trim(),
        'illness': _illnessController.text.trim(),
        'additional_info': _additionalInfoController.text.trim(),
      };

      // Update data on server
      final response = await ApiService.updateUserData(updatedData);

      if (response['success']) {
        // Update local storage
        await StorageService.saveUpdatedUserData(updatedData);

        setState(() => _hasChanges = false);

        // Show success message
        _showSnackBar(
          LanguageController.get('data_updated_successfully') ?? 'Profile updated successfully',
          Colors.green,
        );

        // Go back to settings screen
        Navigator.pop(context, true); // true indicates data was updated
      } else {
        _showSnackBar(
          response['message'] ?? LanguageController.get('update_failed') ?? 'Failed to update profile',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        LanguageController.get('network_error') ?? 'Network error. Please try again.',
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          LanguageController.get('unsaved_changes') ?? 'Unsaved Changes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(LanguageController.get('discard_changes_message') ?? 'You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              LanguageController.get('keep_editing') ?? 'Keep Editing',
              style: TextStyle(color: Colors.green[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(LanguageController.get('discard') ?? 'Discard'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            LanguageController.get('edit_profile') ?? 'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green[600],
          iconTheme: IconThemeData(color: Colors.white),
          scrolledUnderElevation: 0,
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: Text(
                  LanguageController.get('save') ?? 'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        body: _originalData == null
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
          ),
        )
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Personal Information Section
                _buildSectionCard(
                  title: LanguageController.get('personal_info') ?? 'Personal Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: LanguageController.get('name') ?? 'Name',
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty == true
                          ? LanguageController.get('field_required') ?? 'This field is required'
                          : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _surnameController,
                      label: LanguageController.get('surname') ?? 'Surname',
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty == true
                          ? LanguageController.get('field_required') ?? 'This field is required'
                          : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextFieldEmail(
                      controller: _emailController,
                      label: LanguageController.get('email') ?? 'Email',
                      icon: Icons.email,
                    ),
                    SizedBox(height: 16),
                    _buildPhoneField(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: LanguageController.get('age') ?? 'Age',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value?.isEmpty == true) {
                                return LanguageController.get('field_required') ?? 'This field is required';
                              }
                              final age = int.tryParse(value!);
                              if (age == null || age < 1 || age > 120) {
                                return LanguageController.get('invalid_age') ?? 'Please enter a valid age (1-120)';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            value: _selectedGender,
                            label: LanguageController.get('gender') ?? 'Gender',
                            icon: Icons.wc,
                            items: _genders,
                            onChanged: (value) {
                              setState(() => _selectedGender = value!);
                              _onFieldChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _passportController,
                      label: LanguageController.get('passport') ?? 'Passport',
                      icon: Icons.credit_card,
                      validator: (value) => value?.isEmpty == true
                          ? LanguageController.get('field_required') ?? 'This field is required'
                          : null,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Medical Information Section
                _buildSectionCard(
                  title: LanguageController.get('medical_info') ?? 'Medical Information',
                  icon: Icons.medical_information_outlined,
                  children: [
                    _buildDropdown(
                      value: _selectedBloodType,
                      label: LanguageController.get('blood_type') ?? 'Blood Type',
                      icon: Icons.bloodtype,
                      items: _bloodTypes,
                      onChanged: (value) {
                        setState(() => _selectedBloodType = value!);
                        _onFieldChanged();
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _allergiesController,
                      label: LanguageController.get('allergies') ?? 'Allergies',
                      icon: Icons.warning_amber,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _illnessController,
                      label: LanguageController.get('illness') ?? 'Medical Conditions',
                      icon: Icons.local_hospital,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _additionalInfoController,
                      label: LanguageController.get('additional') ?? 'Additional Information',
                      icon: Icons.info,
                      maxLines: 3,
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.green.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 24),
                        SizedBox(width: 12),
                        Text(
                          LanguageController.get('save_changes') ?? 'Save Changes',
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
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: LanguageController.get('phone_number') ?? 'Phone Number',
            hintText: LanguageController.get('enter_phone_hint') ?? 'Enter 9 digits',
            prefixIcon: Icon(Icons.phone, color: Colors.green[600]),
            prefixText: '+998 ',
            prefixStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[600]!, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value?.isEmpty == true) {
              return LanguageController.get('field_required') ?? 'This field is required';
            }
            if (value!.length != 9) {
              return LanguageController.get('invalid_phone_length') ?? 'Phone number must be 9 digits';
            }
            return null;
          },
          onChanged: (value) {
            _onFieldChanged();
          },
        ),

        // Show formatted phone preview
        if (_phoneController.text.length == 9) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                SizedBox(width: 8),
                Text(
                  '${LanguageController.get('phone_preview') ?? 'Phone'}: ${_getFormattedPhoneForJson()}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildTextFieldEmail({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 16),
      validator: (value) {
        if (value?.isEmpty == true) {
          return LanguageController.get('field_required') ?? 'This field is required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!))
        {
          return LanguageController.get('invalid_email') ?? 'Please enter a valid email';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passportController.dispose();
    _allergiesController.dispose();
    _illnessController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}