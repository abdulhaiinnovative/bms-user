import 'dart:convert';
import 'dart:developer';
import 'package:app/models/update_profile_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../models/MyBookingResponse.dart';
import '../utlis/UtilsExtra.dart';


import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../models/MyBookingResponse.dart';
import '../utlis/UtilsExtra.dart';

class ProfileUpdateAPI {



  static Future<UpdateProfileResponse> updateUserProfile(Map<String, dynamic> body) async {

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


      final requestUrl =  'https://bms.innovativewidget.com/api/auth/completeProfile';
      log('Request URL: $requestUrl');

      final response = await http.put(
        Uri.parse(requestUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      log('getBooking response: statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Decoded JSON: $responseData');
        try {
          final updateProfileResponse = UpdateProfileResponse.fromJson(responseData as Map<String, dynamic>);
          if (updateProfileResponse.status == true) {
            return updateProfileResponse;
          } else {
            throw Exception(updateProfileResponse.message ?? 'Failed to load bookings');
          }
        } catch (e) {
          log('Parsing error: $e, StackTrace: ${StackTrace.current}');
          rethrow;
        }
      } else {
        throw Exception('Failed to update profile: HTTP ${response.statusCode}');
      }
    } catch (e) {
      log('Error in MyBookingsAPI.getBooking: $e, StackTrace: ${StackTrace.current}');
      rethrow;
    }
  }
}