import 'package:flutter/material.dart';
import '../../../../api_services/deals_api.dart';
import '../../../../models/deals_response.dart';
import 'package:app/models/HomePageResponse.dart'
    as HomePage; // Deal from old model

class DealsViewModel extends ChangeNotifier {
  final DealsApi _dealsApi = DealsApi();

  // Pagination state
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;

  // Data
  List<HomePage.Deal> _deals = [];
  DealsPaginatedData? _paginationData;

  // Getters
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  List<HomePage.Deal> get deals => _deals;
  int get totalDeals => _paginationData?.total ?? 0;
  int get lastPage => _paginationData?.lastPage ?? 1;

  /// Load initial data
  Future<void> loadDeals() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _deals.clear();
    notifyListeners();

    try {
      final response = await _dealsApi.fetchDeals(page: _currentPage);

      _paginationData = response.response.data;
      _deals = response.response.data.data;
      _hasMoreData = response.response.data.nextPageUrl != null;
    } catch (e) {
      _errorMessage = 'Failed to load deals. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more data (pagination)
  Future<void> loadMoreDeals() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage++;
      final response = await _dealsApi.fetchDeals(page: _currentPage);

      _paginationData = response.response.data;
      _deals.addAll(response.response.data.data);
      _hasMoreData = response.response.data.nextPageUrl != null;
    } catch (e) {
      _errorMessage = 'Failed to load more deals.';
      _currentPage--; // Revert page increment on failure
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refreshDeals() async {
    _currentPage = 1;
    _deals.clear();
    _hasMoreData = true;
    await loadDeals();
  }

  /// Reset state
  void reset() {
    _currentPage = 1;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMoreData = true;
    _errorMessage = null;
    _deals.clear();
    _paginationData = null;
    notifyListeners();
  }
}
