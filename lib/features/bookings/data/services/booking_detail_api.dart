import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../../../services/protected_http_client.dart';
import '../models/booking_detail_response.dart';

class BookingDetailAPI {
  /// Fetch booking detail by ID
  /// API: GET /api/booking-detail/{id}
  Future<BookingDetailResponse> getBookingDetail(int bookingId) async {
    if (kDebugMode) {
      developer.log(
          'BookingDetailAPI.getBookingDetail called | bookingId=$bookingId',
          name: 'booking.api');
    }

    final response =
        await ProtectedHttpClient.get('/booking-detail/$bookingId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (kDebugMode) {
        developer.log(
            'BookingDetailAPI.getBookingDetail success | bookingId=$bookingId | keys=${jsonData.keys.length}',
            name: 'booking.api');
        
        // Log full API response for debugging
        print('\n╔═══════════════════════════════════════════════════════════════╗');
        print('║ 📡 BOOKING DETAIL API RESPONSE                                ║');
        print('╠═══════════════════════════════════════════════════════════════╣');
        print('║ Booking ID: $bookingId');
        print('╠═══════════════════════════════════════════════════════════════╣');
        print('║ Full JSON Response:');
        print('╠═══════════════════════════════════════════════════════════════╣');
        
        // Pretty print JSON
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(jsonData);
        print(prettyJson);
        
        print('╚═══════════════════════════════════════════════════════════════╝\n');
      }

      return BookingDetailResponse.fromJson(jsonData);
    } else {
      if (kDebugMode) {
        developer.log(
            'BookingDetailAPI.getBookingDetail failed | bookingId=$bookingId | status=${response.statusCode}',
            name: 'booking.api');
      }
      throw Exception('Failed to load booking detail: ${response.statusCode}');
    }
  }
}
