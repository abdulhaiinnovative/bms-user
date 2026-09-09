import 'dart:convert';
import 'package:app/models/update_profile_response.dart';
import 'package:app/services/protected_http_client.dart';

class ProfileUpdateAPI {
  static Future<UpdateProfileResponse> updateUserProfile(
      Map<String, dynamic> body) async {
    try {
      final response = await ProtectedHttpClient.put(
        '/auth/completeProfile',
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        try {
          final updateProfileResponse = UpdateProfileResponse.fromJson(
              responseData as Map<String, dynamic>);
          if (updateProfileResponse.status == true) {
            return updateProfileResponse;
          } else {
            throw Exception(updateProfileResponse.message ?? 'Update failed');
          }
        } catch (e) {
          rethrow;
        }
      } else {
        throw Exception(
            'Failed to update profile: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
