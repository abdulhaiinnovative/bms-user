import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/bookings_repository.dart';
import 'package:app/models/MyBookingResponse.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class BookingTabState {
  List<Booking> bookings = [];
  int currentPage = 1;
  int lastPage = 1;
  int totalBookings = 0;
  String? nextPageUrl;
  bool hasMorePages = false;
  bool isLoadingMore = false;
  bool isFirstLoad = true;
  bool hasError = false;
  String? errorMessage;
}

/// ViewModel for Bookings Screen
/// Manages state for user bookings with pagination and filtering
class BookingsViewModel extends BaseViewModel {
  final BookingsRepository _repository;

  BookingsViewModel({BookingsRepository? repository})
      : _repository = repository ?? BookingsRepository();

  final Map<String, BookingTabState> _tabStates = {};

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  BookingTabState getTabState(String status) {
    if (!_tabStates.containsKey(status)) {
      _tabStates[status] = BookingTabState();
    }
    return _tabStates[status]!;
  }

  /// Load bookings list for a given status
  Future<void> loadBookings(String status, {bool refresh = false}) async {
    final tabState = getTabState(status);

    if (kDebugMode) {
      developer.log(
          'BookingsViewModel.loadBookings called | status=$status | refresh=$refresh | page=${tabState.currentPage}',
          name: 'bookings.viewModel');
    }

    if (refresh) {
      _isRefreshing = true;
      tabState.currentPage = 1;
      tabState.nextPageUrl = null;
      tabState.bookings.clear();
      tabState.hasMorePages = false;
      tabState.hasError = false;
      tabState.errorMessage = null;
      notifyListeners();
    }

    if (tabState.bookings.isEmpty && !tabState.isLoadingMore && tabState.isFirstLoad) {
      setLoading();
    }

    await executeAsync(
      operation: () async {
        final targetPage = refresh ? 1 : (tabState.currentPage + 1);
        final response = await _repository.getBookingsList(
          page: targetPage,
          url: tabState.nextPageUrl,
          status: status == 'all' ? '' : status,
        );

        if (response.status == true && response.response?.data != null) {
          final bookingData = response.response!.data!;
          final newBookings = bookingData.data ?? [];

          if (kDebugMode) {
            developer.log(
                'BookingsViewModel: API returned ${newBookings.length} bookings for status=$status | currentPage=${bookingData.currentPage} | total=${bookingData.total}',
                name: 'bookings.viewModel');
          }

          if (!refresh) {
            if (newBookings.isNotEmpty) {
              tabState.bookings.addAll(newBookings);
            }
          } else {
            tabState.bookings = newBookings;
          }

          tabState.currentPage = bookingData.currentPage ?? 1;
          tabState.lastPage = bookingData.lastPage ?? 1;
          tabState.totalBookings = bookingData.total ?? 0;
          tabState.nextPageUrl = bookingData.nextPageUrl;
          tabState.hasMorePages = tabState.nextPageUrl != null;
          tabState.isFirstLoad = false;
          tabState.hasError = false;
          tabState.errorMessage = null;
        }

        if (tabState.isFirstLoad && tabState.bookings.isEmpty) {
            tabState.isFirstLoad = false;
        }

        setSuccess();
        notifyListeners();
      },
      onError: (error) {
        tabState.isFirstLoad = false;
        if (error.contains('404')) {
          tabState.bookings = [];
          tabState.currentPage = 1;
          tabState.nextPageUrl = null;
          tabState.hasMorePages = false;
          tabState.hasError = false;
          tabState.errorMessage = null;
          setSuccess();
        } else {
          tabState.hasError = true;
          tabState.errorMessage = error;
          setError(error);
        }
        notifyListeners();
      },
    );

    _isRefreshing = false;
  }

  /// Load next page for a given status
  Future<void> loadNextPage(String status) async {
    final tabState = getTabState(status);
    if (!tabState.hasMorePages || isLoading || tabState.isLoadingMore) return;

    tabState.isLoadingMore = true;
    notifyListeners();

    await loadBookings(status, refresh: false);

    tabState.isLoadingMore = false;
    notifyListeners();
  }

  /// Refresh bookings list for a given status
  Future<void> refreshStatus(String status) async {
    await loadBookings(status, refresh: true);
  }

  /// Refresh all booking tab states
  Future<void> refresh() async {
    _isRefreshing = true;
    for (final state in _tabStates.values) {
      state.currentPage = 1;
      state.nextPageUrl = null;
      state.bookings.clear();
      state.hasMorePages = false;
      state.hasError = false;
      state.errorMessage = null;
      state.isFirstLoad = true;
    }
    notifyListeners();
    _isRefreshing = false;
  }
}
