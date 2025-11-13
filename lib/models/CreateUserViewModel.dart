import 'dart:developer' as developer;
import 'package:app/models/create_user/CreateUserResponse.dart';
import 'package:app/services/protected_http_client.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CreateUserViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? result;

  static Future<CreateUserResponse?> createUser(
    String provider,
    String providerId,
    String googleUniqueId,
    String email,
    String deviceId,
    String phone,
    String name,
    String firstName,
    String lastName,
    String image,
  ) async {
    final body = {
      "provider": provider,
      "provider_id": providerId,
      "google_unique_id": googleUniqueId,
      "email": email,
      "device_id": deviceId,
      "phone": phone,
      "name": name,
      "first_name": firstName,
      "last_name": lastName,
      "image": image,
    };

    try {
      developer.log('CreateUserViewModel: Social login for email=$email');
      developer.log('CreateUserViewModel: Request body = $body');

      // Public endpoint - no authentication required
      final response = await ProtectedHttpClient.post(
        '/auth/social-login',
        body: body,
        additionalHeaders: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        requiresAuth: false, // Public endpoint
      );

      developer.log('✅ CreateUserViewModel: User created successfully');
      final jsonResponse = jsonDecode(response.body);
      developer.log('CreateUserViewModel: Response = $jsonResponse');

      return CreateUserResponse.fromJson(jsonResponse);
    } on ApiException catch (e) {
      developer.log('❌ CreateUserViewModel: API Error - $e');
    } catch (e) {
      developer.log('❌ CreateUserViewModel: Unexpected error - $e');
    }
    return null;
  }
}
