import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../models/MyBookingResponse.dart';
import '../utlis/UtilsExtra.dart';


import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../models/MyBookingResponse.dart';
import '../utlis/UtilsExtra.dart';

class MyBookingsAPI {
  Future<MyBookingResponse?> getBooking({int page = 1, String? url}) async {


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


      final requestUrl = url ?? 'https://bms.innovativewidget.com/api/appointments?page=$page';
      log('Request URL: $requestUrl');

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: headers,
      );

      log('getBooking response: statusCode=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Decoded JSON: $responseData');
        try {
          final bookingResponse = MyBookingResponse.fromJson(responseData as Map<String, dynamic>);
          if (bookingResponse.status == true) {
            return bookingResponse;
          } else {
            throw Exception(bookingResponse.message ?? 'Failed to load bookings');
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