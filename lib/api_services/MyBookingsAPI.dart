import 'dart:convert';
import 'package:app/services/protected_http_client.dart';
import '../../models/MyBookingResponse.dart';

class MyBookingsAPI {
  Future<MyBookingResponse?> getBooking({int page = 1, String? url, String? status}) async {
    try {
      String endpoint = '/appointments?page=$page';
      if (status != null && status.isNotEmpty) {
        endpoint += '&status=${Uri.encodeComponent(status)}';
      }

      final response = await ProtectedHttpClient.get(endpoint);

      if (response.statusCode == 200 || response.statusCode == 404) {
        final responseData = jsonDecode(response.body);

        try {
          if (responseData is! Map<String, dynamic>) {
            if (responseData is List) {
              final wrappedResponse = {
                'status': true,
                'message': 'Success',
                'response': {
                  'data': {
                    'current_page': 1,
                    'data': responseData,
                    'first_page_url': null,
                    'from': 1,
                    'last_page': 1,
                    'last_page_url': null,
                    'links': [],
                    'next_page_url': null,
                    'path': null,
                    'per_page': responseData.length,
                    'prev_page_url': null,
                    'to': responseData.length,
                    'total': responseData.length,
                  }
                }
              };
              final bookingResponse =
              MyBookingResponse.fromJson(wrappedResponse);
              return bookingResponse;
            }
            throw Exception(
                'Unexpected response format: ${responseData.runtimeType}');
          }

          final bookingResponse = MyBookingResponse.fromJson(responseData);

          if (response.statusCode == 404) {
            return bookingResponse;
          }

          if (bookingResponse.status == true) {
            return bookingResponse;
          } else {
            if (bookingResponse.response?.data?.data?.isEmpty ?? true) {
              return bookingResponse;
            }
            throw Exception(
                bookingResponse.message ?? 'Failed to load bookings');
          }
        } catch (e) {
          rethrow;
        }
      } else {
        throw Exception(
            'Failed to fetch bookings: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await ProtectedHttpClient.post(
        '/cancel-booking',
        body: {'bookingId': bookingId},
      );

      final responseData = jsonDecode(response.body);
      print("RESSS: $responseData");
      if (response.statusCode == 200 && responseData['status'] == true) {
        return true;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to cancel booking');
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