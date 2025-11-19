# Authentication Feature - Clean Architecture

This feature module contains all authentication-related code organized in a clean architecture pattern.

## 📁 Folder Structure

```
features/auth/
├── data/                          # Data Layer
│   ├── datasources/              # External data sources
│   │   ├── auth_service_api.dart       # Email/Password authentication API
│   │   └── social_auth_api.dart        # Social authentication (Google, Facebook)
│   │
│   └── models/                   # Data models
│       ├── auth_response.dart           # Authentication response model
│       ├── login_model.dart             # Login request/response model
│       ├── signup_model.dart            # Signup request/response model
│       ├── social_auth_response.dart    # Social auth response model
│       ├── forgot_password_model.dart   # Password reset model
│       ├── check_user_exists_model.dart # User existence check model
│       └── complete_profile_model.dart  # Profile completion model
│
├── presentation/                  # Presentation Layer
│   ├── providers/                # State management
│   │   └── auth_provider.dart           # Main auth provider (ChangeNotifier)
│   │
│   ├── screens/                  # UI Screens
│   │   ├── auth/                        # Main auth screen
│   │   │   └── auth_screen.dart
│   │   ├── sign_in/                     # Login screens
│   │   │   └── modern_login_screen.dart
│   │   ├── otp/                         # OTP verification
│   │   │   ├── otp_screen.dart
│   │   │   └── components/
│   │   │       └── otp_form.dart
│   │   ├── forgot_password/             # Password recovery
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── components/
│   │   │       └── forgot_pass_form.dart
│   │   ├── reset_password/              # Password reset
│   │   │   └── reset_password_screen.dart
│   │   ├── verification/                # Email verification
│   │   │   └── verification_screen.dart
│   │   ├── complete_profile/            # Profile completion
│   │   │   ├── complete_profile_screen.dart
│   │   │   └── components/
│   │   │       └── complete_profile_form.dart
│   │   └── login_success/               # Login success screen
│   │       └── login_success_screen.dart
│   │
│   └── widgets/                  # Reusable auth widgets (currently empty)
│
└── utils/                         # Auth Utilities
    ├── auth_app.dart                    # Auth app initialization
    ├── auth_guard.dart                  # Route guard for protected routes
    ├── auth_initializer.dart            # Auth system initializer
    ├── auth_interceptor.dart            # HTTP request interceptor
    ├── auth_manager.dart                # Auth token & session manager
    └── auth_middleware.dart             # Auth middleware
```

## 🔑 Key Components

### Data Layer

#### **Datasources**

- **auth_service_api.dart**: Handles email/password authentication endpoints

  - Login
  - Register
  - Logout
  - Email verification
  - Password reset

- **social_auth_api.dart**: Handles social authentication
  - Google Sign-In
  - Facebook Login
  - Apple Sign-In (if implemented)

#### **Models**

All data models for authentication operations, including request/response structures.

---

### Presentation Layer

#### **Providers**

- **auth_provider.dart**: Main authentication state manager
  - User authentication state
  - Login/Logout operations
  - Session management
  - Social authentication handlers

#### **Screens**

All authentication-related UI screens organized by feature:

- Login & Registration
- OTP verification
- Email verification
- Password recovery & reset
- Profile completion
- Success screens

---

### Utils

Authentication utilities and helpers:

- **auth_guard.dart**: Protects routes that require authentication
- **auth_manager.dart**: Manages tokens, sessions, and auth state
- **auth_interceptor.dart**: Intercepts HTTP requests to add auth headers
- **auth_middleware.dart**: Middleware for auth operations
- **auth_initializer.dart**: Initializes auth system on app start
- **auth_app.dart**: Auth app configuration

---

## 🔄 Authentication Flow

### 1. Login Flow

```
User enters credentials
    ↓
AuthProvider.login()
    ↓
auth_service_api.dart → Backend API
    ↓
Receive auth_response
    ↓
AuthManager stores token
    ↓
Navigate to home
```

### 2. Registration Flow

```
User fills signup form
    ↓
AuthProvider.register()
    ↓
auth_service_api.dart → Backend API
    ↓
Email verification sent
    ↓
Navigate to OTP screen
    ↓
Verify OTP
    ↓
Complete profile (optional)
    ↓
Navigate to home
```

### 3. Social Authentication Flow

```
User clicks Google/Facebook
    ↓
AuthProvider.loginWithGoogle/Facebook()
    ↓
Get social auth token
    ↓
social_auth_api.dart → Backend API
    ↓
Receive auth_response
    ↓
Check if profile complete
    ↓
Navigate to home or complete profile
```

### 4. Password Reset Flow

```
User enters email (Forgot Password)
    ↓
AuthProvider.forgotPassword()
    ↓
auth_service_api.dart → Send reset OTP
    ↓
User enters OTP
    ↓
Navigate to Reset Password
    ↓
User enters new password
    ↓
AuthProvider.resetPassword()
    ↓
Navigate to login
```

---

## 🛡️ Security Features

1. **Token Management**

   - Secure token storage (via AuthManager)
   - Automatic token refresh
   - Token expiration handling

2. **Route Protection**

   - AuthGuard protects authenticated routes
   - Automatic redirect to login if unauthenticated

3. **HTTP Interception**

   - AuthInterceptor adds auth headers to requests
   - Handles 401 unauthorized responses
   - Auto-logout on token expiration

4. **Session Management**
   - Persistent login sessions
   - Secure logout
   - Session timeout handling

---

## 📝 Usage Examples

### Using AuthProvider in a Screen

```dart
import 'package:provider/provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return ElevatedButton(
      onPressed: () async {
        try {
          await authProvider.login(
            email: emailController.text,
            password: passwordController.text,
          );
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          // Handle error
        }
      },
      child: Text('Login'),
    );
  }
}
```

### Protecting Routes with AuthGuard

```dart
import '../features/auth/utils/auth_guard.dart';

final routes = {
  '/profile': (context) => AuthGuard(
    child: ProfileScreen(),
  ),
};
```

### Using AuthManager

```dart
import '../features/auth/utils/auth_manager.dart';

// Check if user is authenticated
if (await AuthManager.isAuthenticated()) {
  // User is logged in
}

// Get current token
final token = await AuthManager.getToken();

// Logout
await AuthManager.logout();
```

---

## 🔧 Configuration

### Required Environment Variables

- API Base URL (configured in datasources)
- Google Client ID (for Google Sign-In)
- Facebook App ID (for Facebook Login)

### Firebase Setup

- Firebase Auth must be initialized in `main.dart`
- Google Sign-In configuration required
- Social auth credentials configured

---

## 📦 Dependencies

### Required Packages

- `provider` - State management
- `http` - HTTP requests
- `firebase_auth` - Firebase authentication
- `google_sign_in` - Google authentication
- `shared_preferences` - Local storage for tokens

---

## 🚀 Future Enhancements

- [ ] Biometric authentication (Face ID, Fingerprint)
- [ ] Two-factor authentication (2FA)
- [ ] Apple Sign-In
- [ ] Remember me functionality
- [ ] Account deletion
- [ ] Email change with verification
- [ ] Phone number authentication

---

## 📖 Documentation References

- Main project documentation: `/PROJECT_DOCUMENTATION.md`
- API documentation: Check backend API docs
- Firebase Auth: https://firebase.google.com/docs/auth

---

**Last Updated**: November 18, 2025  
**Version**: 1.0  
**Maintainer**: BMS Team
