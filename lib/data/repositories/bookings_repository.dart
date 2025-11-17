import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/MyBookingsAPI.dart';
import 'package:app/api_services/BookingService.dart';
import 'package:flutter/material.dart';
import '../../models/home/Professional.dart';

/// Repository for bookings operations
class BookingsRepository extends BaseRepository {
  final MyBookingsAPI _bookingsAPI;
  final BookingService _bookingService;

  BookingsRepository({
    MyBookingsAPI? bookingsAPI,
    BookingService? bookingService,
  })  : _bookingsAPI = bookingsAPI ?? MyBookingsAPI(),
        _bookingService = bookingService ?? BookingService();

  /// Get list of user bookings with pagination
  Future<dynamic> getBookingsList({
    required int page,
    String? url,
  }) async {
    return await execute(
      operation: () => _bookingsAPI.getBooking(page: page, url: url),
      errorContext: 'Get bookings list',
    );
  }

  /// Create a new booking
  Future<void> createBooking({
    required BuildContext context,
    required Map<dynamic, int>? cartItems,
    required DateTime? selectedDay,
    required String? selectedTime,
    required List<Professional> selectedProfessionals,
    required String? paymentMethod,
    required String bookingType,
  }) async {
    return await _bookingService.createBooking(
      context: context,
      cartItems: cartItems,
      selectedDay: selectedDay,
      selectedTime: selectedTime,
      selectedProfessionals: selectedProfessionals,
      paymentMethod: paymentMethod,
      bookingType: bookingType,
    );
  }
}
