import 'package:flutter/foundation.dart';
import '../../api_services/auth_service_api.dart';
import '../../models/auth/login_model.dart';
import '../../models/auth/signup_model.dart';
import '../../models/auth/auth_response.dart';
import '../../utlis/authutils/auth_manager.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthServiceAPI _authService = AuthServiceAPI();

  AuthState _state = AuthState.initial;
  UserData? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  UserData? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _currentUser != null;

  /// Initialize the authentication state
  Future<void> initializeAuth() async {
    try {
      _setLoading(true);

      final isLoggedIn = await AuthManager.isLoggedIn();

      if (isLoggedIn) {
        final userData = await AuthManager.getUserData();
        if (userData != null) {
          _currentUser = userData;
          _setState(AuthState.authenticated);
        } else {
          await _clearAuthAndSetUnauthenticated();
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Login user with email and password
  Future<bool> login(String email, String password, {String? fcmToken}) async {
    try {
      _setLoading(true);
      _clearError();

      final loginData = LoginModel(
        email: email.trim(),
        password: password,
        fcmToken: fcmToken,
      );

      // Validate input data
      final validationError = AuthServiceAPI.validateLoginData(loginData);
      if (validationError != null) {
        _setError(validationError);
        return false;
      }

      // Make API call
      final AuthResponse response = await _authService.login(loginData);

      if (response.success && response.data != null) {
        // Save authentication data
        final saved = await AuthManager.saveAuthData(response.data!);

        if (saved) {
          _currentUser = response.data!.user;
          _setState(AuthState.authenticated);
          return true;
        } else {
          _setError('Failed to save login data');
          return false;
        }
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String username,
    required String email,
    required String password,
    String? address,
    String? fcmToken,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final signupData = SignupModel(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone.trim(),
        name: username.trim(),
        email: email.trim(),
        password: password,
        address: address?.trim(),
        fcmToken: fcmToken,
      );

      // Validate input data
      final validationError = AuthServiceAPI.validateSignupData(signupData);
      if (validationError != null) {
        _setError(validationError);
        return false;
      }

      // Make API call
      final AuthResponse response = await _authService.register(signupData);

      if (response.success && response.data != null) {
        // Save authentication data
        final saved = await AuthManager.saveAuthData(response.data!);

        if (saved) {
          _currentUser = response.data!.user;
          _setState(AuthState.authenticated);
          return true;
        } else {
          _setError('Failed to save registration data');
          return false;
        }
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      _setLoading(true);

      final cleared = await AuthManager.clearAuthData();

      if (cleared) {
        _currentUser = null;
        _setState(AuthState.unauthenticated);
        return true;
      } else {
        _setError('Failed to logout');
        return false;
      }
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile data (local storage only)
  Future<bool> updateUserProfile(UserData updatedUser) async {
    try {
      final updated = await AuthManager.updateUserData(updatedUser);

      if (updated) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    }
  }

  /// Save auth data directly from social login response
  Future<bool> saveAuthDataDirectly(AuthData authData) async {
    try {
      final saved = await AuthManager.saveAuthData(authData);

      if (saved) {
        _currentUser = authData.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('Failed to save authentication data');
        return false;
      }
    } catch (e) {
      _setError('Failed to save auth data: ${e.toString()}');
      return false;
    }
  }

  /// Refresh user data from storage
  Future<void> refreshUserData() async {
    try {
      final userData = await AuthManager.getUserData();
      if (userData != null) {
        _currentUser = userData;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    }
  }

  /// Check if user session is still valid
  Future<bool> validateSession() async {
    try {
      final isLoggedIn = await AuthManager.isLoggedIn();

      if (!isLoggedIn) {
        await _clearAuthAndSetUnauthenticated();
        return false;
      }

      return true;
    } catch (e) {
      await _clearAuthAndSetUnauthenticated();
      return false;
    }
  }

  /// Forgot Password - Send reset code to email
  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      if (!AuthServiceAPI.isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      final response = await _authService.forgotPassword(email: email);

      if (response['status'] == true || response['success'] == true) {
        _clearError();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to send reset code');
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset Password with verification code
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (!AuthServiceAPI.isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      if (password.length < 8) {
        _setError('Password must be at least 8 characters');
        return false;
      }

      if (password != confirmPassword) {
        _setError('Passwords do not match');
        return false;
      }

      final response = await _authService.resetPassword(
        email: email,
        code: code,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response['status'] == true || response['success'] == true) {
        _clearError();
        return true;
      } else {
        _setError(response['message'] ?? 'Password reset failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify Email with code
  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (!AuthServiceAPI.isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      final response = await _authService.verifyEmail(
        email: email,
        code: code,
      );

      if (response['status'] == true || response['success'] == true) {
        _clearError();
        return true;
      } else {
        _setError(response['message'] ?? 'Email verification failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend Reset Code
  Future<bool> resendResetCode(String email) async {
    try {
      _setLoading(true);
      _clearError();

      if (!AuthServiceAPI.isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      final response = await _authService.resendResetCode(email: email);

      if (response['status'] == true || response['success'] == true) {
        _clearError();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to resend reset code');
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend Verification Code
  Future<bool> resendVerificationCode(String email) async {
    try {
      _setLoading(true);
      _clearError();

      if (!AuthServiceAPI.isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      final response = await _authService.resendVerificationCode(email: email);

      if (response['status'] == true || response['success'] == true) {
        _clearError();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to resend verification code');
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear authentication and set unauthenticated state
  Future<void> _clearAuthAndSetUnauthenticated() async {
    await AuthManager.clearAuthData();
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set authentication state
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Clear all error messages
  void clearError() {
    _clearError();
  }
}
