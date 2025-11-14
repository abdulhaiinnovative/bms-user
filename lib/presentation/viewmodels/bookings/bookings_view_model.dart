import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/bookings_repository.dart';
import 'package:app/models/MyBookingResponse.dart';

/// ViewModel for Bookings Screen
/// Manages state for user bookings with pagination and filtering
class BookingsViewModel extends BaseViewModel {
  final BookingsRepository _repository;

  BookingsViewModel({BookingsRepository? repository})
      : _repository = repository ?? BookingsRepository();

  // State
  List<Booking> _bookings = [];
  bool _isRefreshing = false;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalBookings = 0;
  String? _nextPageUrl;

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isRefreshing => _isRefreshing;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalBookings => _totalBookings;
  bool get hasMorePages => _nextPageUrl != null;
  bool get isEmpty => _bookings.isEmpty && !isLoading;

  /// Load bookings list
  Future<void> loadBookings({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
      _currentPage = 1;
      _nextPageUrl = null;
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
          if (refresh) {
            _bookings = response.paginatedData?.data ?? [];
          } else {
            if (response.paginatedData?.data != null &&
                response.paginatedData!.data!.isNotEmpty) {
              _bookings.addAll(response.paginatedData!.data!);
            }
          }

          _currentPage = response.paginatedData?.currentPage ?? 1;
          _lastPage = response.paginatedData?.lastPage ?? 1;
          _totalBookings = response.paginatedData?.total ?? 0;
          _nextPageUrl = response.paginatedData?.nextPageUrl;

          log('Bookings loaded successfully - Total: $totalBookings, Current Page: $currentPage, Last Page: $lastPage');
        }

        notifyListeners();
      },
    );

    _isRefreshing = false;
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!hasMorePages || isLoading) return;

    _currentPage++;
    await loadBookings();
  }

  /// Refresh bookings list
  Future<void> refresh() async {
    await loadBookings(refresh: true);
  }
}
