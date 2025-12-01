import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';

class RatingAPI {
  /// Submit a rating/review for a salon
  ///
  /// Required parameters:
  /// - [salonId]: ID of the salon being rated
  /// - [bookingId]: ID of the booking (required for verified reviews)
  /// - [rating]: Rating value (1-5)
  /// - [comment]: Review text/comment
  Future<Map<String, dynamic>> submitRating({
    required int salonId,
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      log('════════════════════════════════════════════════════════');
      log('⭐ RATING API - SUBMIT REVIEW');
      log('════════════════════════════════════════════════════════');
      log('📤 Request Details:');
      log('   Salon ID: $salonId');
      log('   Booking ID: $bookingId');
      log('   Rating: $rating/5');
      log('   Comment: $comment');
      log('════════════════════════════════════════════════════════');

      final response = await ProtectedHttpClient.post(
        '/reviews',
        body: {
          'salon_id': salonId,
          'booking_id': bookingId,
          'rating': rating,
          'comment': comment,
        },
      );

      log('');
      log('════════════════════════════════════════════════════════');
      log('📥 RATING API - RESPONSE');
      log('════════════════════════════════════════════════════════');
      log('Status Code: ${response.statusCode}');
      log('');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      try {
        final prettyJson =
            const JsonEncoder.withIndent('  ').convert(responseData);
        log('Response Body:');
        log(prettyJson);
      } catch (e) {
        log('Response Body: ${response.body}');
      }

      log('════════════════════════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('');
        log('✅ SUCCESS - Review submitted successfully!');
        log('════════════════════════════════════════════════════════');

        return {
          'success': true,
          'message': responseData['message'] ?? 'Review submitted successfully',
          'data': responseData['response'] ?? responseData['data'],
        };
      } else {
        log('');
        log('❌ ERROR - Failed to submit review');
        log('════════════════════════════════════════════════════════');

        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to submit review',
          'errors': responseData['errors'] ?? [],
        };
      }
    } on UnauthorizedException catch (e) {
      log('');
      log('════════════════════════════════════════════════════════');
      log('🔒 UNAUTHORIZED - User not logged in');
      log('════════════════════════════════════════════════════════');
      log('Error: $e');
      log('════════════════════════════════════════════════════════');

      return {
        'success': false,
        'message': 'Please login to submit a review',
        'unauthorized': true,
      };
    } catch (error, stackTrace) {
      log('');
      log('════════════════════════════════════════════════════════');
      log('💥 EXCEPTION IN RATING API');
      log('════════════════════════════════════════════════════════');
      log('Error: $error');
      log('Stack Trace: $stackTrace');
      log('════════════════════════════════════════════════════════');

      return {
        'success': false,
        'message': 'An error occurred while submitting review',
        'error': error.toString(),
      };
    }
  }

  /// Get reviews for a specific salon
  Future<Map<String, dynamic>> getSalonReviews({
    required int salonId,
    int page = 1,
  }) async {
    try {
      log('════════════════════════════════════════════════════════');
      log('📖 RATING API - GET REVIEWS');
      log('════════════════════════════════════════════════════════');
      log('   Salon ID: $salonId');
      log('   Page: $page');
      log('════════════════════════════════════════════════════════');

      final response = await ProtectedHttpClient.get(
        '/salons/$salonId/reviews?page=$page',
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        log('✅ SUCCESS - Reviews fetched successfully');
        return {
          'success': true,
          'data': responseData['response'] ?? responseData['data'],
        };
      } else {
        log('❌ ERROR - Failed to fetch reviews');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch reviews',
        };
      }
    } catch (error) {
      log('💥 EXCEPTION: $error');
      return {
        'success': false,
        'message': 'An error occurred while fetching reviews',
      };
    }
  }
}
