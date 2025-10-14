import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/my_account_response.dart';
import '../utlis/UtilsExtra.dart';


class MyAccountAPI {

  Future<MyAccountResponse?> getMyAccount() async {

    print('obj');
    log('obj');
    try {
      String? token = await UtilsExtra.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No valid token provided');
      }

      log('Token: $token');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };


      final requestUrl = 'https://bms.innovativewidget.com/api/user/get-user-profile';
      log('Request URL: $requestUrl');

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: headers,
      );

      print('getMyAccount response: statusCode=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Decoded JSON: $responseData');
        try {
          final myAccountResponse = MyAccountResponse.fromJson(responseData as Map<String, dynamic>);
          if (myAccountResponse.status == true) {
            return myAccountResponse;
          } else {
            throw Exception(myAccountResponse.message ?? 'Failed to load bookings');
          }
        } catch (e) {
          log('Parsing error: $e, StackTrace: ${StackTrace.current}');
          rethrow;
        }
      } else {
        throw Exception('Failed to fetch bookings: HTTP ${response.statusCode}');
      }
    } catch (e) {
      log('Error in MyBookingsAPI.getBooking: $e, StackTrace: ${StackTrace.current}');
      rethrow;
    }
  }
}