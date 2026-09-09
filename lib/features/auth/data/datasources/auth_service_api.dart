import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../constants.dart';
import '../models/login_model.dart';
import '../models/signup_model.dart';
import '../models/auth_response.dart';
import '../../utils/auth_interceptor.dart';

class AuthServiceAPI {
  // Using the base URL from constants
  static const String baseURL = BASE_URL;

  // API endpoints - all prefixed with /auth
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String socialLoginEndpoint = '/auth/social-login';
  static const String appleLoginEndpoint = '/auth/apple-login';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String resendEmailEndpoint = '/auth/resend-email';
  static const String verificationEndpoint = '/auth/verification';
  static const String resendVerificationEndpoint = '/auth/resent_verification';
  static const String checkUserRegisteredEndpoint =
      '/auth/checkUserIsAlreadyRegistered';
  static const String completeProfileEndpoint = '/auth/completeProfile';
  static const String logoutEndpoint = '/auth/logout';
  static const String deleteAccountEndpoint = '/auth/delete-account';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String updateProfileEndpoint = '/auth/update-profile';
  static const String getUserEndpoint = '/auth/user';

  AuthServiceAPI() {
    // Initialize AuthInterceptor with base URL
    AuthInterceptor.initialize(baseUrl: baseURL);
  }

  /// Login user with email and password
  /// Returns AuthResponse containing user data and token on success
  Future<AuthResponse> login(LoginModel loginData) async {
    try {
      final response = await AuthInterceptor.post(
        loginEndpoint,
        data: loginData.toJson(),
        requiresAuth: false, // Login doesn't require existing auth
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        final authResponse = AuthResponse.fromJson(responseData);

        return authResponse;
      } else if (response.statusCode == 400) {
        // Bad request - invalid credentials or validation errors
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // Unauthorized - invalid credentials
        return AuthResponse(
          statusCode: response.statusCode ?? 401,
          success: false,
          message: 'Invalid email or password',
        );
      } else if (response.statusCode == 404) {
        // User not found
        return AuthResponse(
          statusCode: response.statusCode ?? 404,
          success: false,
          message: 'User not found',
        );
      } else {
        // Other server errors
        throw Exception(
            'Login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Request timeout: Please check your internet connection');
      } else if (dioError.type == DioExceptionType.connectionError) {
        throw Exception('Network error: Please check your internet connection');
      } else if (dioError.response != null) {
        // Dio may throw for non-2xx due to validateStatus. Convert the response
        // body into AuthResponse so UI can show the real API message.
        final statusCode = dioError.response!.statusCode ?? 500;
        try {
          final Map<String, dynamic> responseData =
              dioError.response!.data is Map<String, dynamic>
                  ? Map<String, dynamic>.from(dioError.response!.data)
                  : Map<String, dynamic>.from(
                      jsonDecode(dioError.response!.data.toString()),
                    );

          responseData.putIfAbsent('statusCode', () => statusCode);
          return AuthResponse.fromJson(responseData);
        } catch (_) {
          return AuthResponse(
            statusCode: statusCode,
            success: false,
            message: 'Request failed (HTTP $statusCode)',
          );
        }
      } else {
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }

  /// Register new user
  /// Returns AuthResponse containing user data and token on success
  Future<AuthResponse> register(SignupModel signupData) async {
    try {
      final response = await AuthInterceptor.post(
        registerEndpoint,
        data: signupData.toJson(),
        requiresAuth: false, // Registration doesn't require existing auth
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        final authResponse = AuthResponse.fromJson(responseData);

        if (authResponse.success) {
          return authResponse;
        } else {
          return authResponse;
        }
      } else if (response.statusCode == 400) {
        // Bad request - validation errors or user already exists
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 409) {
        // Conflict - user already exists
        return AuthResponse(
          statusCode: response.statusCode ?? 409,
          success: false,
          message: 'User with this email already exists',
        );
      } else if (response.statusCode == 422) {
        // Unprocessable Entity - validation errors
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        return AuthResponse.fromJson(responseData);
      } else {
        // Other server errors
        throw Exception(
            'Registration failed with status code: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Request timeout: Please check your internet connection');
      } else if (dioError.type == DioExceptionType.connectionError) {
        throw Exception('Network error: Please check your internet connection');
      } else if (dioError.response != null) {
        // Dio may throw for non-2xx due to validateStatus. Convert the response
        // body into AuthResponse so UI can show validation errors.
        final statusCode = dioError.response!.statusCode ?? 500;
        try {
          final Map<String, dynamic> responseData =
              dioError.response!.data is Map<String, dynamic>
                  ? Map<String, dynamic>.from(dioError.response!.data)
                  : Map<String, dynamic>.from(
                      jsonDecode(dioError.response!.data.toString()),
                    );

          responseData.putIfAbsent('statusCode', () => statusCode);
          return AuthResponse.fromJson(responseData);
        } catch (_) {
          return AuthResponse(
            statusCode: statusCode,
            success: false,
            message: 'Request failed (HTTP $statusCode)',
          );
        }
      } else {
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Registration failed: ${e.toString()}');
      }
    }
  }

  /// Social Login (Google/Facebook)
  /// Provider: 'google' or 'facebook'
  Future<AuthResponse> socialLogin({
    required String email,
    required String provider,
    required String providerId,
    String? firstName,
    String? lastName,
    String? name,
    String? phone,
    String? deviceId,
    String? image,
    String? fcmToken,
  }) async {
    try {
      final body = {
        'email': email.toLowerCase(),
        'provider': provider,
        'provider_id': providerId,
      };

      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (deviceId != null) body['device_id'] = deviceId;
      if (image != null) body['image'] = image;
      if (fcmToken != null) body['fcm_token'] = fcmToken;

      final response = await AuthInterceptor.post(
        socialLoginEndpoint,
        data: body,
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        final authResponse = AuthResponse.fromJson(responseData);

        if (authResponse.success) {
          return authResponse;
        } else {
          return authResponse;
        }
      } else {
        throw Exception(
            'Social login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'socialLogin');
    } catch (e, stackTrace) {
      throw Exception('Social login failed: ${e.toString()}');
    }
  }

  /// Apple Login
  Future<AuthResponse> appleLogin({
    required String appleUniqueId,
    String? email,
    String? firstName,
    String? lastName,
    String? name,
    String? deviceId,
    String? image,
    String? fcmToken,
  }) async {
    try {
      final body = {
        'apple_unique_id': appleUniqueId,
      };

      if (email != null) body['email'] = email.toLowerCase();
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (name != null) body['name'] = name;
      if (deviceId != null) body['device_id'] = deviceId;
      if (image != null) body['image'] = image;
      if (fcmToken != null) body['fcm_token'] = fcmToken;

      final response = await AuthInterceptor.post(
        appleLoginEndpoint,
        data: body,
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        final authResponse = AuthResponse.fromJson(responseData);

        if (authResponse.success) {
          return authResponse;
        } else {
          return authResponse;
        }
      } else {
        throw Exception(
            'Apple login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'appleLogin');
    } catch (e, stackTrace) {
      throw Exception('Apple login failed: ${e.toString()}');
    }
  }

  /// Forgot Password - Send reset code to email
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await AuthInterceptor.post(
        forgotPasswordEndpoint,
        data: {'email': email},
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Failed to send reset code');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'forgotPassword');
    } catch (e, stackTrace) {
      throw Exception('Failed to send reset code: ${e.toString()}');
    }
  }

  /// Reset Password with verification code
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await AuthInterceptor.post(
        resetPasswordEndpoint,
        data: {
          'email': email,
          'code': code,
          'password': password,
          'confirm_password': confirmPassword,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Password reset failed');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'resetPassword');
    } catch (e, stackTrace) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Resend password reset code
  Future<Map<String, dynamic>> resendResetCode({required String email}) async {
    try {
      final response = await AuthInterceptor.post(
        resendEmailEndpoint,
        data: {'email': email},
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Failed to resend reset code');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'resendResetCode');
    } catch (e, stackTrace) {
      throw Exception('Failed to resend reset code: ${e.toString()}');
    }
  }

  /// Verify email with code
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await AuthInterceptor.post(
        verificationEndpoint,
        data: {
          'email': email,
          'code': code,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Email verification failed');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'verifyEmail');
    } catch (e, stackTrace) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  /// Resend verification code
  Future<Map<String, dynamic>> resendVerificationCode(
      {required String email}) async {
    try {
      final response = await AuthInterceptor.post(
        resendVerificationEndpoint,
        data: {'email': email},
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Failed to resend verification code');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'resendVerificationCode');
    } catch (e, stackTrace) {
      throw Exception('Failed to resend verification code: ${e.toString()}');
    }
  }

  /// Check if user is already registered
  Future<Map<String, dynamic>> checkUserRegistration({
    required String email,
    required String name,
    required String firstName,
    required String lastName,
    String? fcmToken,
  }) async {
    try {
      final body = {
        'email': email,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
      };

      if (fcmToken != null) body['fcm_token'] = fcmToken;

      final response = await AuthInterceptor.post(
        checkUserRegisteredEndpoint,
        data: body,
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Failed to check user registration');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'checkUserRegistration');
    } catch (e, stackTrace) {
      throw Exception('Failed to check user registration: ${e.toString()}');
    }
  }

  /// Complete/Update user profile
  Future<AuthResponse> completeProfile({
    required String email,
    String? firstName,
    String? lastName,
    String? name,
    String? deviceId,
    String? password,
    String? provider,
    String? providerId,
    String? phone,
    String? dob,
    String? gender,
    String? country,
    String? state,
    String? latitude,
    String? longitude,
    String? city,
    String? address,
    bool? appointment,
    bool? emailMarketing,
    bool? marketingNotification,
    String? fcmToken,
  }) async {
    try {
      final body = <String, dynamic>{'email': email};

      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (name != null) body['name'] = name;
      if (deviceId != null) body['device_id'] = deviceId;
      if (password != null) body['password'] = password;
      if (provider != null) body['provider'] = provider;
      if (providerId != null) body['provider_id'] = providerId;
      if (phone != null) body['phone'] = phone;
      if (dob != null) body['dob'] = dob;
      if (gender != null) body['gender'] = gender;
      if (country != null) body['country'] = country;
      if (state != null) body['state'] = state;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (city != null) body['city'] = city;
      if (address != null) body['address'] = address;
      if (appointment != null) body['appointment'] = appointment;
      if (emailMarketing != null) body['email_marketing'] = emailMarketing;
      if (marketingNotification != null) {
        body['marketing_notification'] = marketingNotification;
      }
      if (fcmToken != null) body['fcm_token'] = fcmToken;

      final response = await AuthInterceptor.put(
        completeProfileEndpoint,
        data: body,
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        final authResponse = AuthResponse.fromJson(responseData);

        if (authResponse.success) {
          return authResponse;
        } else {
          return authResponse;
        }
      } else {
        throw Exception(
            'Profile update failed with status code: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'completeProfile');
    } catch (e, stackTrace) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await AuthInterceptor.post(
        logoutEndpoint,
        data: {},
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        return responseData;
      } else {
        throw Exception('Logout failed');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'logout');
    } catch (e, stackTrace) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Get current authenticated user
  Future<AuthResponse> getCurrentUser() async {
    try {
      final response = await AuthInterceptor.get(
        getUserEndpoint,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());
        final authResponse = AuthResponse.fromJson(responseData);

        return authResponse;
      } else {
        throw Exception('Failed to fetch user');
      }
    } on DioException catch (dioError, stackTrace) {
      throw _handleDioError(dioError, context: 'getCurrentUser');
    } catch (e, stackTrace) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  /// Handle Dio errors uniformly with comprehensive logging
  Exception _handleDioError(DioException dioError, {String? context}) {
    // Return appropriate exception based on error type
    if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.receiveTimeout ||
        dioError.type == DioExceptionType.sendTimeout) {
      return Exception(
          'Request timeout: Please check your internet connection');
    } else if (dioError.type == DioExceptionType.connectionError) {
      return Exception('Network error: Please check your internet connection');
    } else if (dioError.response != null) {
      final statusCode = dioError.response!.statusCode ?? 500;
      final responseData = dioError.response!.data;

      // Try to extract error message from response
      String errorMessage = 'Server error: HTTP $statusCode';
      if (responseData is Map && responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      } else if (responseData is String) {
        errorMessage = responseData;
      }

      return Exception(errorMessage);
    } else {
      return Exception('Network error: ${dioError.message}');
    }
  }

  /// Validate login data
  static String? validateLoginData(LoginModel loginData) {
    if (loginData.email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(loginData.email)) {
      return 'Please enter a valid email address';
    }

    if (loginData.password.trim().isEmpty) {
      return 'Password is required';
    }

    if (!isValidPassword(loginData.password)) {
      return 'Password must be at least 6 characters long';
    }

    return null; // No validation errors
  }

  /// Validate signup data
  static String? validateSignupData(SignupModel signupData) {
    if (signupData.firstName.trim().isEmpty) {
      return 'First name is required';
    }

    if (signupData.lastName.trim().isEmpty) {
      return 'Last name is required';
    }

    if (signupData.email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(signupData.email)) {
      return 'Please enter a valid email address';
    }

    if (signupData.password.trim().isEmpty) {
      return 'Password is required';
    }

    if (!isValidPassword(signupData.password)) {
      return 'Password must be at least 6 characters long';
    }

    if (signupData.phone.isNotEmpty && !isValidPhone(signupData.phone)) {
      return 'Please enter a valid phone number';
    }

    return null; // No validation errors
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // Basic validation: at least 6 characters
    // You can make this more complex based on your requirements
    return password.length >= 6;
  }

  /// Validate phone number format
  static bool isValidPhone(String phone) {
    // Basic phone validation
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone);
  }
}
