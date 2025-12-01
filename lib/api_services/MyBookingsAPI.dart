import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../../models/MyBookingResponse.dart';

class MyBookingsAPI {
  Future<MyBookingResponse?> getBooking({int page = 1, String? url}) async {
    try {
      log('📅 ========== BOOKINGS API REQUEST ==========');
      log('📅 Page: $page');
      log('📅 Custom URL: ${url ?? "None (using default)"}');

      final String endpoint = url != null
          ? url.replaceFirst('https://bms.innovativewidget.com/api', '')
          : '/appointments?page=$page';

      log('📅 Final Endpoint: $endpoint');
      log('📅 Making GET request...');

      final response = await ProtectedHttpClient.get(endpoint);

      log('📅 ========== BOOKINGS API RESPONSE ==========');
      log('📅 Status Code: ${response.statusCode}');
      log('📅 Response Headers: ${response.headers}');
      log('📅 Response Body Length: ${response.body.length} characters');

      if (response.statusCode == 200 || response.statusCode == 404) {
        log('📅 Raw Response Body: ${response.body}');

        final responseData = jsonDecode(response.body);
        log('📅 Decoded JSON Type: ${responseData.runtimeType}');
        log('📅 Decoded JSON Keys: ${responseData is Map ? responseData.keys.toList() : "N/A (not a Map)"}');

        try {
          // Check if responseData is a Map
          if (responseData is! Map<String, dynamic>) {
            log('⚠️ Response is ${responseData.runtimeType}, attempting to wrap...');
            log('⚠️ Response content: $responseData');
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

          log('📅 ========== PARSED RESPONSE ==========');
          log('📅 Status: ${bookingResponse.status}');
          log('📅 Message: ${bookingResponse.message}');
          log('📅 Has Response Data: ${bookingResponse.response != null}');

          if (bookingResponse.response?.data != null) {
            final pData = bookingResponse.response!.data!;
            log('📅 ========== PAGINATION INFO ==========');
            log('📅 Current Page: ${pData.currentPage}');
            log('📅 Last Page: ${pData.lastPage}');
            log('📅 Per Page: ${pData.perPage}');
            log('📅 Total: ${pData.total}');
            log('📅 From: ${pData.from}');
            log('📅 To: ${pData.to}');
            log('📅 Next Page URL: ${pData.nextPageUrl}');
            log('📅 Prev Page URL: ${pData.prevPageUrl}');
            log('📅 First Page URL: ${pData.firstPageUrl}');
            log('📅 Last Page URL: ${pData.lastPageUrl}');
            log('📅 Path: ${pData.path}');
            log('📅 Bookings Count: ${pData.data?.length ?? 0}');

            if (pData.data != null && pData.data!.isNotEmpty) {
              log('📅 ========== BOOKING DETAILS ==========');
              for (var i = 0; i < pData.data!.length; i++) {
                final booking = pData.data![i];
                log('📅 Booking #${i + 1}:');
                log('   ID: ${booking.id}');
                log('   Title: ${booking.title}');
                log('   Status: ${booking.status}');
                log('   Date: ${booking.date}');
                log('   Time: ${booking.time}');
                log('   Payment: ${booking.payment}');
                log('   Payment Status: ${booking.paymentStatus}');
                log('   Payment Method: ${booking.paymentMethod}');
                log('   Booking Type: ${booking.bookingType}');
                log('   Commission: ${booking.commission}');
                log('   Used Loyalty Points: ${booking.usedLoyaltyPoints}');
                log('   Salon ID: ${booking.salonId}');
                log('   User ID: ${booking.userId}');
                log('   Team ID: ${booking.teamId}');
                if (booking.salon != null) {
                  log('   Salon Info:');
                  log('     - ID: ${booking.salon!.id}');
                  log('     - Name: ${booking.salon!.name}');
                  log('     - Address: ${booking.salon!.address}');
                  log('     - Logo: ${booking.salon!.logo}');
                  log('     - Image: ${booking.salon!.image}');
                  log('     - Average Rating: ${booking.salon!.averageRating}');
                  log('     - Review Count: ${booking.salon!.reviewCount}');
                  log('     - Active Days: ${booking.salon!.activeDays?.length ?? 0}');
                }
              }
            } else {
              log('📅 No bookings in response data');
            }
          } else {
            log('📅 No response.data found in booking response');
          }

          // Handle 404 - No bookings found is a valid empty state
          if (response.statusCode == 404) {
            log('⚠️ No bookings found (404)');
            return bookingResponse;
          }

          if (bookingResponse.status == true) {
            log('✅ SUCCESS: Returning ${bookingResponse.response?.data?.data?.length ?? 0} bookings');
            return bookingResponse;
          } else {
            if (bookingResponse.response?.data?.data?.isEmpty ?? true) {
              log('⚠️ Returning empty bookings');
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
