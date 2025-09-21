
---

# COMPLETE SETUP & DOCUMENTATION

## Backend Requirements

### API Endpoints Required:
1. **POST /auth/login**
    - Body: `{ "email": "string", "password": "string" }`
    - Response: `{ "user": {...}, "token": "string" }`

2. **POST /auth/register**
    - Body: `{ "firstName", "lastName", "email", "password", "dateOfBirth", "gender", "universityId", "universityName" }`
    - Response: `{ "user": {...}, "token": "string" }`

3. **POST /auth/send-otp**
    - Body: `{ "email": "string" }`
    - Response: `{ "message": "OTP sent" }`

4. **POST /auth/verify-otp**
    - Body: `{ "email": "string", "otp": "string" }`
    - Response: `{ "verified": true }`

5. **GET /universities**
    - Response: `[{ "id": "string", "name": "string" }]`

## Data Transfer & State Management

### Local Storage (Device):
- **User Data**: Full user profile stored using SharedPreferences
- **Auth Token**: JWT token for API authentication
- **Universities**: Cached list to avoid repeated API calls
- **First Time Flag**: Tracks if user has completed onboarding

### Server Communication:
- **Login**: Sends credentials → receives user data + token
- **Registration**: Multi-step process, final submission with all data
- **OTP**: Email verification during registration
- **Universities**: Fetched once and cached locally

### State Management Flow:
1. **App Launch**: AuthProvider checks stored token/user
2. **Authentication**: Provider manages login/register states
3. **Navigation**: Automatic routing based on auth state
4. **Data Persistence**: All user data saved locally post-authentication

## Setup Instructions

### 1. Flutter Setup:
```bash
flutter create auth_app
cd auth_app
```

### 2. Add dependencies to pubspec.yaml (provided above)

### 3. Replace lib/ folder with the structure provided

### 4. Update constants.dart with your API base URL

### 5. Run the app:
```bash
flutter pub get
flutter run
```

## Development Notes

### Extending Main Screen:
- Replace `MainScreen` content with your app features
- User data available via `Provider.of<AuthProvider>(context).user`
- Authentication state automatically managed

### Customization:
- Update `AppColors` in constants.dart for your design
- Modify UI components in widgets/ folder
- Add validation rules in validators.dart

### Security Features:
- Password encryption (implement on backend)
- JWT token authentication
- OTP verification with attempt limits
- Local data encryption (add if needed)

This structure provides a complete, production-ready authentication system that you can customize according to your Figma design!