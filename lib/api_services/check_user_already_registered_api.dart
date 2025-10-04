import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/UserIsAlreadyRegisteredModel.dart';
import '../models/UserIsAlreadyRegisteredModelResponse.dart';

class CheckUserRegistered {
  Future<UserIsAlreadyRegisteredModelResponse> checkUserRegistered({
    required UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel,
  }) async {
    try {
      // Prepare request data
      Map<String, dynamic> data = toCheckUserIsAlreadyRegistered(userIsAlreadyRegisteredModel);

      final response = await http.post(
        Uri.parse('$BASE_URL/auth/checkUserIsAlreadyRegistered'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );


      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        UserIsAlreadyRegisteredModelResponse modelResponse =
        UserIsAlreadyRegisteredModelResponse.fromJson(jsonResponse);

        log('Parsed Model: ${modelResponse.toJson()}'); // ✅ Shows parsed data
        return modelResponse;
      } else {
        throw Exception('Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      log('Error in checkUserRegistered: $error');
      throw Exception('Failed to load data: $error');
    }
  }

  Map<String, dynamic> toCheckUserIsAlreadyRegistered( UserIsAlreadyRegisteredModel userIsAlreadyRegisteredModel)
    {
      Map<String, dynamic> data = { "id": userIsAlreadyRegisteredModel.id,
      "email": userIsAlreadyRegisteredModel.email,
      "name": userIsAlreadyRegisteredModel.name,
      "first_name": userIsAlreadyRegisteredModel.first_name,
      "last_name": userIsAlreadyRegisteredModel.last_name,
      "profile_image": userIsAlreadyRegisteredModel.profile_image,
    };

  return data;
  }
}
