import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/bookings_repository.dart';
import 'package:app/models/MyBookingResponse.dart';
import 'package:intl/intl.dart';

/// ViewModel for Bookings Screen
/// Manages state for user bookings with pagination and filtering
class BookingsViewModel extends BaseViewModel {
  final BookingsRepository _repository;

  BookingsViewModel({BookingsRepository? repository})
      : _repository = repository ?? BookingsRepository();

  // State
  List<Booking> _allBookings = [];
  final List<Booking> _upcomingBookings = [];
  final List<Booking> _pastBookings = [];
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalBookings = 0;
  String? _nextPageUrl;

  // Getters
  List<Booking> get allBookings => _allBookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  List<Booking> get pastBookings => _pastBookings;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalBookings => _totalBookings;
  bool get hasMorePages => _nextPageUrl != null;
  bool get isEmpty => _allBookings.isEmpty && !isLoading;

  /// Load bookings list
  Future<void> loadBookings({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
      _currentPage = 1;
      _nextPageUrl = null;
      _allBookings.clear();
      notifyListeners();
    }

    await executeAsync(
      operation: () async {
        log('Loading bookings - Page: $_currentPage');

        final response = await _repository.getBookingsList(
          page: _currentPage,
          url: _nextPageUrl,
        );

        log('Bookings response received - Status: ${response.status}');

        if (response.status == 1 && response.paginatedData != null) {
          final newBookings = response.paginatedData?.data ?? [];

          if (!refresh) {
            if (newBookings.isNotEmpty) {
              _allBookings.addAll(newBookings);
            }
          } else {
            _allBookings = newBookings;
          }

          _currentPage = response.paginatedData?.currentPage ?? 1;
          _lastPage = response.paginatedData?.lastPage ?? 1;
          _totalBookings = response.paginatedData?.total ?? 0;
          _nextPageUrl = response.paginatedData?.nextPageUrl;

          log('Bookings loaded successfully - Total: $totalBookings, Current Page: $currentPage, Last Page: $lastPage');

          // Filter bookings into upcoming and past
          _filterBookings();
        }

        notifyListeners();
      },
    );

    _isRefreshing = false;
  }

  /// Filter bookings into upcoming and past
  void _filterBookings() {
    final now = DateTime.now();
    log('Filtering bookings, current time: $now');

    _upcomingBookings.clear();
    _pastBookings.clear();

    for (var booking in _allBookings) {
      if (booking.date == null) {
        log('Skipping booking ID ${booking.id} with null date');
        continue;
      }

      DateTime? bookingDateTime;
      try {
        final date = DateTime.tryParse(booking.date!);
        if (date == null) {
          log('Invalid date for booking ID ${booking.id}: ${booking.date}');
          continue;
        }

        final time = booking.time != null
            ? DateFormat('HH:mm:ss').parse(booking.time!).toLocal()
            : DateTime(1970, 1, 1, 0, 0);

        bookingDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        log('Booking ID ${booking.id} dateTime: $bookingDateTime, isBefore now: ${bookingDateTime.isBefore(now)}');
      } catch (e, stackTrace) {
        log('Error parsing date/time for booking ID ${booking.id}: $e\nStack: $stackTrace');
        continue;
      }

      // Upcoming: status is 'booked' and time is in the future
      if (booking.status == 'booked' && !bookingDateTime.isBefore(now)) {
        _upcomingBookings.add(booking);
        log('Added booking ID ${booking.id} to upcomingBookings');
      }
      // Past: not booked or time is in the past
      else if (booking.status != 'booked' || bookingDateTime.isBefore(now)) {
        _pastBookings.add(booking);
        log('Added booking ID ${booking.id} to pastBookings');
      }
    }

    log('Upcoming bookings: ${_upcomingBookings.length}');
    log('Past bookings: ${_pastBookings.length}');

    // Sort bookings by date descending
    _sortBookingsList(_allBookings);
    _sortBookingsList(_upcomingBookings);
    _sortBookingsList(_pastBookings);
  }

  /// Sort bookings list by date descending
  void _sortBookingsList(List<Booking> bookings) {
    bookings.sort((a, b) {
      try {
        final dateA = DateTime.tryParse(a.date ?? '');
        final dateB = DateTime.tryParse(b.date ?? '');

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA); // Descending order
      } catch (e) {
        return 0;
      }
    });
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!hasMorePages || isLoading || _isLoadingMore) return;

    log('Loading next page of bookings');
    _isLoadingMore = true;
    notifyListeners();

    await loadBookings(refresh: false);

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Refresh bookings list
  Future<void> refresh() async {
    await loadBookings(refresh: true);
  }
}
