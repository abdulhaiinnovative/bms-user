import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../models/check_user_exists_model.dart';
import '../models/complete_profile_model.dart';
import '../models/social_auth_response.dart';

class SocialAuthAPI {
  static const String baseURL = BASE_URL;

  // API endpoints
  static const String checkUserRegisteredEndpoint =
      '$BASE_URL/auth/checkUserIsAlreadyRegistered';
  static const String completeProfileEndpoint =
      '$BASE_URL/auth/completeProfile';

  /// Check if user is already registered (for social auth)
  /// Returns SocialAuthResponse with user data if exists
  Future<SocialAuthResponse> checkUserIsAlreadyRegistered(
      CheckUserExistsModel data) async {
    try {
      final response = await http.post(
        Uri.parse(checkUserRegisteredEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final socialAuthResponse = SocialAuthResponse.fromJson(responseData);
        return socialAuthResponse;
      } else {
        print('CheckUser API Error: Status ${response.statusCode}, Body: ${response.body}');
        return SocialAuthResponse(
          status: false,
          message: 'Failed to check user registration: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('CheckUser Exception: $e');
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
      final response = await http.put(
        Uri.parse(completeProfileEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final socialAuthResponse = SocialAuthResponse.fromJson(responseData);
        return socialAuthResponse;
      } else {
        return SocialAuthResponse(
          status: false,
          message: 'Failed to complete profile',
        );
      }
    } catch (e) {
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
