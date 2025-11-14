import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/MyBookingsAPI.dart';

/// Repository for bookings operations
class BookingsRepository extends BaseRepository {
  final MyBookingsAPI _bookingsAPI;

  BookingsRepository({MyBookingsAPI? bookingsAPI})
      : _bookingsAPI = bookingsAPI ?? MyBookingsAPI();

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
}
