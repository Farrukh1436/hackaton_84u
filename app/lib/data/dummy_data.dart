import '../models/user_model.dart';
import '../models/emergency_request.dart';

class DummyData {
  static Map<String, dynamic> simulateLogin(String login, String password) {
    // Simulate some test users
    if ((login == 'AB1234567' || login == 'test@gmail.com') && password == 'test') {
      return {
        'success': true,
        'token': 'dummy_token_12345',
        'message': 'Login successful',
        'user_data': {
          'name': 'Test',
          'surname': 'User',
          'phone': '+998901234567',
          'email': 'kamoliddinsharopov1@gmail.com',
          'age': 25,
          'gender': 'Male',
          'passport': 'AD1234567',
          'blood_type': 'A+',
          'allergies': 'none',
          'illness': 'none',
          'additional_info': 'none'
        }
      };
    }
    return {
      'success': false,
      'message': 'Invalid credentials',
    };
  }

  static Map<String, dynamic> simulateSendOtp(String phone) {
    return {
      'success': true,
      'message': 'OTP sent successfully'
    };
  }

  static Map<String, dynamic> simulateVerifyOtp(String phone, String otp) {
    // Accept any 4-digit OTP for testing
    if (otp == '123456') {
      return {
        'success': true,
        'registration_token': 'reg_token_1234'
      };
    }
    return {
      'success': false,
      'message': 'Invalid OTP'
    };
  }

  static Map<String, dynamic> simulateRegistration(PersonalData personal, MedicalData medical) {
    return {
      'success': true,
      'token': 'user_token_1234',
      'message': 'Registration completed successfully'
    };
  }

  static Map<String, dynamic> simulateEmergencyRequest(EmergencyRequest request) {
    return {
      'success': true,
      'request_id': 'ER${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Emergency request received and being processed'
    };
  }

  // New method for simulating user data update
  static Map<String, dynamic> simulateUpdateUserData(Map<String, dynamic> userData) {
    // Simulate validation
    List<String> errors = [];

    if (userData['name']?.toString().isEmpty == true) {
      errors.add('Name is required');
    }
    if (userData['surname']?.toString().isEmpty == true) {
      errors.add('Surname is required');
    }
    if (userData['phone']?.toString().isEmpty == true) {
      errors.add('Phone is required');
    }
    if (userData['age'] == null || userData['age'] < 1 || userData['age'] > 120) {
      errors.add('Invalid age');
    }
    if (userData['passport']?.toString().isEmpty == true) {
      errors.add('Passport is required');
    }

    // Return error if validation fails
    if (errors.isNotEmpty) {
      return {
        'success': false,
        'message': 'Validation failed: ${errors.join(', ')}'
      };
    }

    // Simulate successful update
    return {
      'success': true,
      'message': 'Profile updated successfully',
      'updated_data': userData
    };
  }

}