import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../models/my_account_response.dart';

class MyAccountAPI {
  Future<MyAccountResponse?> getMyAccount() async {
    log('MyAccountAPI: Fetching user profile');
    try {
      final response = await ProtectedHttpClient.get('/user/get-user-profile');

      log('MyAccountAPI: Response received with status ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('✅ MyAccountAPI: Decoded JSON successfully');
        try {
          final myAccountResponse =
              MyAccountResponse.fromJson(responseData as Map<String, dynamic>);
          if (myAccountResponse.status == true) {
            return myAccountResponse;
          } else {
            throw Exception(myAccountResponse.message);
          }
        } catch (e) {
          log('❌ MyAccountAPI: Parsing error - $e');
          rethrow;
        }
      } else {
        log('❌ MyAccountAPI: Unexpected status ${response.statusCode}');
        throw Exception('Failed to fetch profile: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException catch (e) {
      log('❌ MyAccountAPI: Unauthorized - $e');
      rethrow;
    } on ApiException catch (e) {
      log('❌ MyAccountAPI: API Error - $e');
      rethrow;
    } catch (e) {
      log('❌ MyAccountAPI: Error - $e');
      rethrow;
    }
  }
}
