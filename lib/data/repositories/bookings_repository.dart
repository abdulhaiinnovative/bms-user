import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/MyBookingsAPI.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Repository for bookings operations
class BookingsRepository extends BaseRepository {
  final MyBookingsAPI _bookingsAPI;

  BookingsRepository({MyBookingsAPI? bookingsAPI})
      : _bookingsAPI = bookingsAPI ?? MyBookingsAPI();

  /// Get list of user bookings with pagination
  Future<dynamic> getBookingsList({
    required int page,
    String? url,
    String? status,
  }) async {
    if (kDebugMode) {
      developer.log(
          'BookingsRepository.getBookingsList called | page=$page | url=$url',
          name: 'bookings.repository');
    }

    final result = await execute(
      operation: () => _bookingsAPI.getBooking(page: page, url: url, status: status),
      errorContext: 'Get bookings list',
    );

    if (kDebugMode) {
      try {
        developer.log(
            'BookingsRepository.getBookingsList result | status=${result?.status} | dataLength=${result?.response?.data?.data?.length ?? 0}',
            name: 'bookings.repository');
      } catch (_) {}
    }

    return result;
  }
}
