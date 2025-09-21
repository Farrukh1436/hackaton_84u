import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api/api_service.dart';
import 'register_medical_screen.dart';
import 'dart:async';
import '../../models/user_model.dart';
import '../../language/language_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passportController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Timer? _otpTimer;
  int _otpCountdown = 0;
  bool _canResendOtp = true;

  String _selectedGender = 'Male';
  bool _emailOtpSent = false;
  bool _emailOtpVerified = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isVerifyingOtp = false;
  bool _isSendingOtp = false;

  // Phone number formatting helper
  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // If user enters 9 digits, format as +998xxxxxxx
    if (digitsOnly.length == 9) {
      return '+998$digitsOnly';
    }

    // If already starts with 998, add + prefix
    if (digitsOnly.startsWith('998') && digitsOnly.length == 10) {
      return '+$digitsOnly';
    }

    return phone;
  }

  void _startOtpTimer() {
    setState(() {
      _otpCountdown = 90; // 1:30 minutes
      _canResendOtp = false;
    });

    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_otpCountdown > 0) {
          _otpCountdown--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }


  String _getFormattedPhoneForJson() {
    String phone = _phoneController.text.trim();
    return _formatPhoneNumber(phone);
  }

  // Send OTP to email

  Future<void> _sendEmailOtp() async {
    if (_emailController.text.trim().isEmpty) {
      _showError(LanguageController.get('enter_email') ?? 'Please enter your email');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      _showError(LanguageController.get('invalid_email') ?? 'Please enter a valid email');
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final response = await ApiService.sendOtpToEmail(_emailController.text.trim());

      if (response['success']) {
        setState(() {
          _emailOtpSent = true;
          _isSendingOtp = false;
        });
        _startOtpTimer(); // Start the timer
        _showSuccess(LanguageController.get('otp_sent_success') ?? 'Verification code sent to your email');
      } else {
        setState(() => _isSendingOtp = false);
        _showError(response['message'] ?? (LanguageController.get('otp_send_failed') ?? 'Failed to send OTP'));
      }
    } catch (e) {
      setState(() => _isSendingOtp = false);
      _showError(LanguageController.get('network_error') ?? 'Network error. Please try again.');
    }
  }


  // Verify OTP
  Future<void> _verifyEmailOtp() async {
    if (_otpController.text.trim().isEmpty) {
      _showError(LanguageController.get('enter_otp') ?? 'Please enter the OTP code');
      return;
    }

    if (_otpController.text.trim().length != 6) {
      _showError(LanguageController.get('invalid_otp_length') ?? 'OTP must be 6 digits');
      return;
    }

    setState(() => _isVerifyingOtp = true);

    try {
      // Use ApiService to verify OTP
      final response = await ApiService.verifyEmailOtp(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );

      if (response['success']) {
        setState(() {
          _emailOtpVerified = true;
          _isVerifyingOtp = false;
        });
        _showSuccess(LanguageController.get('email_verified_success') ?? 'Email verified successfully');
      } else {
        setState(() => _isVerifyingOtp = false);
        _showError(response['message'] ?? (LanguageController.get('otp_verification_failed') ?? 'OTP verification failed'));
      }
    } catch (e) {
      setState(() => _isVerifyingOtp = false);
      _showError(LanguageController.get('network_error') ?? 'Network error. Please try again.');
    }
  }

  // Resend OTP

  Future<void> _resendOtp() async {
    if (!_canResendOtp) return;

    setState(() {
      _otpController.clear();
      _emailOtpSent = false;
    });
    await _sendEmailOtp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    children: [
                      // Back Button
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Registration Icon
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Title
                      Text(
                        LanguageController.get('create_account') ?? 'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),

                      // Subtitle
                      Text(
                        LanguageController.get('register_subtitle') ?? 'Step 1 of 2 - Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Registration Form
              Container(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Verification Section
                      Container(
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
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _emailOtpVerified ? Colors.green[50] : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _emailOtpVerified ? Icons.verified_user : Icons.email_outlined,
                                      color: _emailOtpVerified ? Colors.green[600] : Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    LanguageController.get('email_verification') ?? 'Email Verification',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  if (_emailOtpVerified) ...[
                                    SizedBox(width: 8),
                                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                  ],
                                ],
                              ),
                              SizedBox(height: 20),

                              // Email input
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !_emailOtpVerified,
                                decoration: InputDecoration(
                                  labelText: LanguageController.get('email_address') ?? 'Email address',
                                  hintText: LanguageController.get('enter_email') ?? 'Enter your email',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _emailOtpVerified ? Colors.green[50] : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _emailOtpVerified ? Icons.verified : Icons.email,
                                      color: _emailOtpVerified ? Colors.green[600] : Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _emailOtpVerified ? Colors.green[300]! : Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _emailOtpVerified ? Colors.green[600]! : Colors.blue[600]!,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: _emailOtpVerified ? Colors.green[50] : Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value?.isEmpty == true) return LanguageController.get('required') ?? 'Required';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                    return LanguageController.get('invalid_email') ?? 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16),

                              // Send OTP Button or verification status
                              if (!_emailOtpVerified) ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: (_isSendingOtp || (_emailOtpSent && !_canResendOtp)) ? null : _sendEmailOtp,
                                    icon: _isSendingOtp
                                        ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                        : Icon(Icons.send, size: 18),
                                    label: Text(
                                      _isSendingOtp
                                          ? (LanguageController.get('sending_otp') ?? 'Sending...')
                                          : (_emailOtpSent
                                          ? (!_canResendOtp
                                          ? 'Resend in ${_formatTime(_otpCountdown)}'
                                          : (LanguageController.get('resend_otp') ?? 'Resend Code'))
                                          : (LanguageController.get('send_otp') ?? 'Send Verification Code')),
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                // Email verified status
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                      SizedBox(width: 12),
                                      Text(
                                        LanguageController.get('email_verified') ?? 'Email Verified Successfully',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // OTP input field (show only if OTP is sent but not verified)
                              if (_emailOtpSent && !_emailOtpVerified) ...[

                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: LanguageController.get('otp_code') ?? 'Verification Code',
                                    hintText: LanguageController.get('enter_otp') ?? 'Enter 6-digit code',
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(12),
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.pin,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (!_emailOtpVerified && value?.isEmpty == true) {
                                      return LanguageController.get('enter_otp') ?? 'Please enter OTP code';
                                    }
                                    if (!_emailOtpVerified && value!.length != 6) {
                                      return LanguageController.get('invalid_otp_length') ?? 'OTP must be 6 digits';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),

                                // Verify OTP Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isVerifyingOtp ? null : _verifyEmailOtp,
                                    icon: _isVerifyingOtp
                                        ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                        : Icon(Icons.verified_user, size: 18),
                                    label: Text(
                                      _isVerifyingOtp
                                          ? (LanguageController.get('verifying') ?? 'Verifying...')
                                          : (LanguageController.get('verify_code') ?? 'Verify Code'),
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 12),

                                // OTP info message

// OTP info and resend section
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.email_outlined, color: Colors.blue[600], size: 20),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Code sent to ${_emailController.text.trim()}',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!_canResendOtp) ...[
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.timer_outlined, color: Colors.blue[600], size: 16),
                                            SizedBox(width: 8),
                                            Text(
                                              'Resend available in ${_formatTime(_otpCountdown)}',
                                              style: TextStyle(
                                                color: Colors.blue[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton.icon(
                                              onPressed: _isSendingOtp ? null : _resendOtp,
                                              icon: Icon(Icons.refresh, size: 16),
                                              label: Text(
                                                LanguageController.get('resend_otp') ?? 'Resend Code',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.blue[600],
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Personal Information Section
                      Container(
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
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    LanguageController.get('personal_information') ?? 'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Name and Surname Row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: LanguageController.get('name') ?? 'Name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      validator: (value) => value?.isEmpty == true ?
                                      (LanguageController.get('required') ?? 'Required') : null,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _surnameController,
                                      decoration: InputDecoration(
                                        labelText: LanguageController.get('surname') ?? 'Surname',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      validator: (value) => value?.isEmpty == true ?
                                      (LanguageController.get('required') ?? 'Required') : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Phone Field (moved here)
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(9),
                                ],
                                decoration: InputDecoration(
                                  labelText: LanguageController.get('phone_number') ?? 'Phone Number',
                                  hintText: LanguageController.get('enter_phone_hint') ?? 'Enter 9 digits',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.phone,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  prefixText: '+998 ',
                                  prefixStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value?.isEmpty == true) return LanguageController.get('required') ?? 'Required';
                                  if (value!.length != 9) {
                                    return LanguageController.get('invalid_phone_length') ?? 'Phone number must be 9 digits';
                                  }
                                  return null;
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

                              SizedBox(height: 20),

                              // Age and Gender Row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: LanguageController.get('age') ?? 'Age',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty == true) return LanguageController.get('required') ?? 'Required';
                                        int? age = int.tryParse(value!);
                                        if (age == null || age < 1 || age > 120) {
                                          return LanguageController.get('invalid_age') ?? 'Please enter a valid age (1-120)';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedGender,
                                      decoration: InputDecoration(
                                        labelText: LanguageController.get('gender') ?? 'Gender',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                      items: [
                                        DropdownMenuItem(value: 'Male', child: Text(LanguageController.get('male') ?? 'Male')),
                                        DropdownMenuItem(value: 'Female', child: Text(LanguageController.get('female') ?? 'Female')),
                                      ],
                                      onChanged: (value) => setState(() => _selectedGender = value!),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Passport Field
                              TextFormField(
                                controller: _passportController,
                                decoration: InputDecoration(
                                  labelText: LanguageController.get('passport_series') ?? 'Passport Series',
                                  hintText: LanguageController.get('enter_passport') ?? 'Enter passport series',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.badge,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) => value?.isEmpty == true ?
                                (LanguageController.get('required') ?? 'Required') : null,
                              ),
                              SizedBox(height: 20),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: LanguageController.get('password') ?? 'Password',
                                  hintText: LanguageController.get('enter_password') ?? 'Enter your password',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) => value?.isEmpty == true ?
                                (LanguageController.get('required') ?? 'Required') : null,
                              ),
                              SizedBox(height: 20),

                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: LanguageController.get('confirm_password') ?? 'Confirm Password',
                                  hintText: LanguageController.get('confirm_password_hint') ?? 'Confirm your password',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value?.isEmpty == true) return LanguageController.get('required') ?? 'Required';
                                  if (value != _passwordController.text) return LanguageController.get('password_mismatch') ?? 'Passwords don\'t match';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _isLoading
                            ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[600]!, Colors.blue[400]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                            : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[600]!, Colors.blue[400]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _proceedToMedical,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_forward, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  LanguageController.get('next_medical') ?? 'Next: Medical Data',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToMedical() {
    if (!_formKey.currentState!.validate()) return;

    // Check if email is verified
    if (!_emailOtpVerified) {
      _showError(LanguageController.get('email_verification_required') ?? 'Please verify your email first');
      return;
    }

    final personalData = PersonalData(
      email: _emailController.text.trim(),
      phone: _getFormattedPhoneForJson(), // This will format as +998xxxxxxx
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      passport: _passportController.text.trim(),
      password: _passwordController.text,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterMedicalScreen(personalData: personalData)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _passportController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}