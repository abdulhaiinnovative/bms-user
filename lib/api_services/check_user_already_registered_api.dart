import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../models/UserIsAlreadyRegisteredModel.dart';
import '../models/UserIsAlreadyRegisteredModelResponse.dart';

class CheckUserRegistered {
  Future<UserIsAlreadyRegisteredModelResponse> checkUserRegistered({
    required UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel,
  }) async {
    try {
      // Prepare request data
      Map<String, dynamic> data =
          toCheckUserIsAlreadyRegistered(userIsAlreadyRegisteredModel);

      log('CheckUserRegistered: Checking registration for email=${data['email']}');

      // Public endpoint - no authentication required
      final response = await ProtectedHttpClient.post(
        '/auth/checkUserIsAlreadyRegistered',
        body: data,
        additionalHeaders: {'Content-Type': 'application/json'},
        requiresAuth: false, // Public endpoint
      );

      log('✅ CheckUserRegistered: Response received with status ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        UserIsAlreadyRegisteredModelResponse modelResponse =
            UserIsAlreadyRegisteredModelResponse.fromJson(jsonResponse);

        log('✅ CheckUserRegistered: User registration status checked');
        return modelResponse;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on ApiException catch (e) {
      log('❌ CheckUserRegistered: API Error - $e');
      throw Exception('Failed to check user registration: $e');
    } catch (error) {
      log('❌ CheckUserRegistered: Unexpected error - $error');
      throw Exception('Failed to load data: $error');
    }
  }

  Map<String, dynamic> toCheckUserIsAlreadyRegistered(
      UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel) {
    Map<String, dynamic> data = {
      "id": userIsAlreadyRegisteredModel.id,
      "email": userIsAlreadyRegisteredModel.email,
      "name": userIsAlreadyRegisteredModel.name,
      "first_name": userIsAlreadyRegisteredModel.first_name,
      "last_name": userIsAlreadyRegisteredModel.last_name,
      "profile_image": userIsAlreadyRegisteredModel.profile_image,
    };

    return data;
  }
}
