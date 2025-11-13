import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../../models/MyBookingResponse.dart';

class MyBookingsAPI {
  Future<MyBookingResponse?> getBooking({int page = 1, String? url}) async {
    try {
      log('MyBookingsAPI: Fetching bookings for page $page');

      final String endpoint = url != null
          ? url.replaceFirst('https://bms.innovativewidget.com/api', '')
          : '/appointments?page=$page';

      log('MyBookingsAPI: Request endpoint: $endpoint');

      final response = await ProtectedHttpClient.get(endpoint);

      log('✅ MyBookingsAPI: Response status ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        log('✅ MyBookingsAPI: Decoded JSON successfully');

        try {
          // Check if responseData is a Map
          if (responseData is! Map<String, dynamic>) {
            log('⚠️ MyBookingsAPI: Response is ${responseData.runtimeType}, wrapping...');
            // If it's a List, wrap it in the expected structure
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

          // Handle 404 - No bookings found is a valid empty state
          if (response.statusCode == 404) {
            log('⚠️ MyBookingsAPI: No bookings found (404)');
            return bookingResponse;
          }

          if (bookingResponse.status == true) {
            log('✅ MyBookingsAPI: Success with ${bookingResponse.response?.data?.data?.length ?? 0} bookings');
            return bookingResponse;
          } else {
            if (bookingResponse.response?.data?.data?.isEmpty ?? true) {
              log('⚠️ MyBookingsAPI: Returning empty bookings');
              return bookingResponse;
            }
            throw Exception(
                bookingResponse.message ?? 'Failed to load bookings');
          }
        } catch (e) {
          log('❌ MyBookingsAPI: Parsing error - $e');
          rethrow;
        }
      } else {
        log('❌ MyBookingsAPI: Unexpected status ${response.statusCode}');
        throw Exception(
            'Failed to fetch bookings: HTTP ${response.statusCode}');
      }
    } on UnauthorizedException catch (e) {
      log('❌ MyBookingsAPI: Unauthorized - $e');
      rethrow;
    } on ApiException catch (e) {
      log('❌ MyBookingsAPI: API Error - $e');
      rethrow;
    } catch (e) {
      log('❌ MyBookingsAPI: Error - $e');
      rethrow;
    }
  }
}
