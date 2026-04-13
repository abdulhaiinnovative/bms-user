import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app/services/protected_http_client.dart';
import '../models/my_account_response.dart';
import '../constants.dart';
import '../features/auth/utils/auth_manager.dart';

class MyAccountAPI {
  Future<MyAccountResponse?> getMyAccount() async {
    try {
      final response = await ProtectedHttpClient.get('/user/get-user-profile');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        try {
          final myAccountResponse =
              MyAccountResponse.fromJson(responseData as Map<String, dynamic>);
          if (myAccountResponse.status == true) {
            return myAccountResponse;
          } else {
            throw Exception(myAccountResponse.message);
          }
        } catch (e) {
          rethrow;
        }
      } else {
        throw Exception('Failed to fetch profile: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  /// Update user profile with multipart/form-data support
  Future<MyAccountResponse?> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dob,
    String? gender,
    String? country,
    String? state,
    String? city,
    String? address,
    File? image,
  }) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null || token.isEmpty) {
        throw UnauthorizedException('Please login to continue');
      }

      final url = Uri.parse('$BASE_URL/user/profile-update');
      final request = http.MultipartRequest('PUT', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add text fields only if they are not null
      if (firstName != null && firstName.isNotEmpty) {
        request.fields['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        request.fields['last_name'] = lastName;
      }
      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        request.fields['phone'] = phone;
      }
      if (dob != null && dob.isNotEmpty) {
        request.fields['dob'] = dob;
      }
      if (gender != null && gender.isNotEmpty) {
        request.fields['gender'] = gender;
      }
      if (country != null && country.isNotEmpty) {
        request.fields['country'] = country;
      }
      if (state != null && state.isNotEmpty) {
        request.fields['state'] = state;
      }
      if (city != null && city.isNotEmpty) {
        request.fields['city'] = city;
      }
      if (address != null && address.isNotEmpty) {
        request.fields['address'] = address;
      }

      // Add image if provided
      if (image != null) {
        final imageStream = http.ByteStream(image.openRead());
        final imageLength = await image.length();
        final multipartFile = http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final myAccountResponse =
            MyAccountResponse.fromJson(responseData as Map<String, dynamic>);
        
        if (myAccountResponse.status == true) {
          return myAccountResponse;
        } else {
          throw Exception(myAccountResponse.message);
        }
      } else if (response.statusCode == 422) {
        // Validation error
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Validation error occurred';
        throw Exception(message);
      } else if (response.statusCode == 401) {
        await AuthManager.clearAuthData();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        throw Exception('Failed to update profile: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
