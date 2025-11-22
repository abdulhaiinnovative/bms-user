import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../../api_services/deals_api.dart';
import '../../../../models/deals_response.dart';
import '../../../../models/HomePageResponse.dart';

class DealsViewModel extends ChangeNotifier {
  final DealsApi _dealsApi = DealsApi();

  // Pagination state
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;

  // Data
  List<Deal> _deals = [];
  DealsPaginatedData? _paginationData;

  // Getters
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  List<Deal> get deals => _deals;
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
      log('✅ Loaded ${_deals.length} deals (Page $_currentPage of ${_paginationData?.lastPage})');
    } catch (e) {
      _errorMessage = 'Failed to load deals. Please try again.';
      log('❌ Error loading deals: $e');
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
      log('✅ Loaded ${response.response.data.data.length} more deals (Page $_currentPage of ${_paginationData?.lastPage})');
    } catch (e) {
      _errorMessage = 'Failed to load more deals.';
      _currentPage--; // Revert page increment on failure
      log('❌ Error loading more deals: $e');
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
