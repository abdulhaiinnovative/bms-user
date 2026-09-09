import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
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
      // Laravel doesn't support PUT with multipart/form-data
      // Use POST with _method=PUT (Laravel method spoofing)
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Laravel method spoofing - tells Laravel to treat this as PUT
      request.fields['_method'] = 'PUT';

      // Sab fields hamesha bhejo (empty string bhi)
      request.fields['first_name'] = firstName ?? '';
      request.fields['last_name']  = lastName ?? '';
      request.fields['email']      = email ?? '';
      request.fields['phone']      = phone ?? '';
      request.fields['dob']        = dob ?? '';
      request.fields['gender']     = gender ?? '';
      request.fields['country']    = country ?? '';
      request.fields['state']      = state ?? '';
      request.fields['city']       = city ?? '';
      request.fields['address']    = address ?? '';

      // Image upload
      if (image != null) {
        final fileName = path.basename(image.path);
        final ext = path.extension(image.path).toLowerCase();
        
        // Determine content type based on extension
        String contentType;
        switch (ext) {
          case '.jpg':
          case '.jpeg':
            contentType = 'image/jpeg';
            break;
          case '.png':
            contentType = 'image/png';
            break;
          case '.gif':
            contentType = 'image/gif';
            break;
          case '.webp':
            contentType = 'image/webp';
            break;
          default:
            contentType = 'image/jpeg';
        }

        final multipartFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        );
        request.files.add(multipartFile);
        print('📸 Image attached: $fileName ($contentType)');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔄 Profile Update Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('🔍 FULL BACKEND RESPONSE: $responseData');

        final myAccountResponse = MyAccountResponse.fromJson(responseData as Map<String, dynamic>);

        if (myAccountResponse.status == true) {
          print('✅ Backend says success');
          return myAccountResponse;
        } else {
          throw Exception(myAccountResponse.message ?? 'Update failed');
        }
      } else {
        print('❌ Response Body: ${response.body}');
        throw Exception('Failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Update Profile API Error: $e');
      rethrow;
    }
  }
}
