import 'dart:convert';
import 'dart:developer';
import '../constants.dart';
import '../models/auth/check_user_exists_model.dart';
import '../models/auth/complete_profile_model.dart';
import '../models/auth/social_auth_response.dart';
import '../services/protected_http_client.dart';

class SocialAuthAPI {
  static const String baseURL = BASE_URL;

  // API endpoints
  static const String checkUserRegisteredEndpoint =
      '/auth/checkUserIsAlreadyRegistered';
  static const String completeProfileEndpoint = '/auth/completeProfile';

  /// Check if user is already registered (for social auth)
  /// Returns SocialAuthResponse with user data if exists
  Future<SocialAuthResponse> checkUserIsAlreadyRegistered(
      CheckUserExistsModel data) async {
    try {
      log('🔍 SocialAuthAPI: Checking if user exists: ${data.email}');

      final response = await ProtectedHttpClient.post(
        checkUserRegisteredEndpoint,
        body: data.toJson(),
        requiresAuth: false,
      );

      log('🔍 SocialAuthAPI: Response status: ${response.statusCode}');
      log('🔍 SocialAuthAPI: Response data: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final socialAuthResponse = SocialAuthResponse.fromJson(responseData);
        log('✅ SocialAuthAPI: User check successful - isComplete: ${socialAuthResponse.isComplete}');
        return socialAuthResponse;
      } else {
        log('❌ SocialAuthAPI: Unexpected status code: ${response.statusCode}');
        return SocialAuthResponse(
          status: false,
          message: 'Failed to check user registration',
        );
      }
    } on UnauthorizedException catch (e) {
      log('❌ SocialAuthAPI: UnauthorizedException - ${e.message}');
      return SocialAuthResponse(
        status: false,
        message: 'Authentication failed',
      );
    } on ApiException catch (e) {
      log('❌ SocialAuthAPI: ApiException - ${e.message}');

      // Handle validation errors (422)
      if (e.statusCode == 422) {
        return SocialAuthResponse(
          status: false,
          message: e.message ?? 'Validation failed',
        );
      }

      return SocialAuthResponse(
        status: false,
        message: e.message ?? 'Server error occurred',
      );
    } catch (e) {
      log('❌ SocialAuthAPI: Unexpected error - $e');
      return SocialAuthResponse(
        status: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Complete user profile (for social auth)
  /// Returns SocialAuthResponse with updated user data
  Future<SocialAuthResponse> completeProfile(CompleteProfileModel data) async {
    try {
      log('📝 SocialAuthAPI: Completing profile for: ${data.email}');

      final response = await ProtectedHttpClient.put(
        completeProfileEndpoint,
        body: data.toJson(),
        requiresAuth: false,
      );

      log('📝 SocialAuthAPI: Response status: ${response.statusCode}');
      log('📝 SocialAuthAPI: Response data: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final socialAuthResponse = SocialAuthResponse.fromJson(responseData);
        log('✅ SocialAuthAPI: Profile completion successful');
        return socialAuthResponse;
      } else {
        log('❌ SocialAuthAPI: Unexpected status code: ${response.statusCode}');
        return SocialAuthResponse(
          status: false,
          message: 'Failed to complete profile',
        );
      }
    } on UnauthorizedException catch (e) {
      log('❌ SocialAuthAPI: UnauthorizedException - ${e.message}');
      return SocialAuthResponse(
        status: false,
        message: 'Authentication failed',
      );
    } on ApiException catch (e) {
      log('❌ SocialAuthAPI: ApiException - ${e.message}');

      // Handle user not found (404)
      if (e.statusCode == 404) {
        return SocialAuthResponse(
          status: false,
          message: e.message,
        );
      }

      // Handle validation errors (422)
      if (e.statusCode == 422) {
        return SocialAuthResponse(
          status: false,
          message: e.message,
        );
      }

      return SocialAuthResponse(
        status: false,
        message: e.message,
      );
    } catch (e) {
      log('❌ SocialAuthAPI: Unexpected error - $e');
      return SocialAuthResponse(
        status: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Validate check user exists data
  static String? validateCheckUserData(CheckUserExistsModel data) {
    if (data.email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(data.email)) {
      return 'Invalid email format';
    }

    if (data.email.length > 100) {
      return 'Email must be less than 100 characters';
    }

    if (data.name.isEmpty) {
      return 'Name is required';
    }

    if (data.name.length > 255) {
      return 'Name must be less than 255 characters';
    }

    if (data.firstName.isEmpty) {
      return 'First name is required';
    }

    if (data.firstName.length > 255) {
      return 'First name must be less than 255 characters';
    }

    if (data.lastName.isEmpty) {
      return 'Last name is required';
    }

    if (data.lastName.length > 255) {
      return 'Last name must be less than 255 characters';
    }

    return null;
  }
}
