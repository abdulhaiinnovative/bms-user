import 'dart:convert';
import 'dart:developer';
import 'package:app/models/update_profile_response.dart';
import 'package:app/services/protected_http_client.dart';

class ProfileUpdateAPI {
  static Future<UpdateProfileResponse> updateUserProfile(
      Map<String, dynamic> body) async {
    try {
      log('ProfileUpdateAPI: Updating user profile');
      log('ProfileUpdateAPI: Request body - $body');

      final response = await ProtectedHttpClient.put(
        '/auth/completeProfile',
        body: body,
      );

      log('✅ ProfileUpdateAPI: Response status ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('✅ ProfileUpdateAPI: Decoded JSON successfully');
        try {
          final updateProfileResponse = UpdateProfileResponse.fromJson(
              responseData as Map<String, dynamic>);
          if (updateProfileResponse.status == true) {
            log('✅ ProfileUpdateAPI: Profile updated successfully');
            return updateProfileResponse;
          } else {
            throw Exception(updateProfileResponse.message ?? 'Update failed');
          }
        } catch (e) {
          log('❌ ProfileUpdateAPI: Parsing error - $e');
          rethrow;
        }
      } else {
        log('❌ ProfileUpdateAPI: Unexpected status ${response.statusCode}');
        throw Exception(
            'Failed to update profile: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException catch (e) {
      log('❌ ProfileUpdateAPI: Unauthorized - $e');
      rethrow;
    } on ApiException catch (e) {
      log('❌ ProfileUpdateAPI: API Error - $e');
      rethrow;
    } catch (e) {
      log('❌ ProfileUpdateAPI: Error - $e');
      rethrow;
    }
  }
}
