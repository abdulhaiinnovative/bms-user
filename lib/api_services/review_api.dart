import 'dart:convert';
import 'package:app/services/protected_http_client.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// API service for creating reviews
class ReviewAPI {
  /// Create a review for a booking
  /// POST /api/create-review
  ///
  /// Required parameters:
  /// - bookingId: The ID of the booking to review
  /// - rating: Rating from 1-5
  /// - comment: Review comment/feedback
  ///
  /// Returns the created review response
  Future<ReviewResponse> createReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      if (kDebugMode) {
        developer.log(
          'ReviewAPI.createReview called | bookingId=$bookingId | rating=$rating',
          name: 'review.api',
        );
      }

      final body = {
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
      };

      final response = await ProtectedHttpClient.post(
        '/create-review',
        body: body,
      );

      if (kDebugMode) {
        developer.log(
          'ReviewAPI.createReview response | status=${response.statusCode}',
          name: 'review.api',
        );
      }

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewResponse.fromJson(jsonData);
      } else {
        throw Exception(
          jsonData['message'] ??
              'Failed to create review: ${response.statusCode}',
        );
      }
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'ReviewAPI.createReview error | error=$e',
          name: 'review.api',
        );
      }
      rethrow;
    }
  }
}

/// Response model for create review API
class ReviewResponse {
  final bool status;
  final String message;
  final ReviewData? data;

  ReviewResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['response']?['data'] != null
          ? ReviewData.fromJson(json['response']['data'])
          : null,
    );
  }
}

/// Review data model
class ReviewData {
  final int id;
  final int bookingId;
  final int userId;
  final int salonId;
  final int rating;
  final String comment;

  ReviewData({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.salonId,
    required this.rating,
    required this.comment,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}
