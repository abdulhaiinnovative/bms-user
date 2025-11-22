import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../../api_services/top_salons_api.dart';
import '../../../../models/top_salons_response.dart';

class TopSalonsViewModel extends ChangeNotifier {
  final TopSalonsApi _topSalonsApi = TopSalonsApi();

  // Pagination state
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;

  // Data
  List<TopSalonItem> _salons = [];
  TopSalonsPaginatedData? _paginationData;

  // Getters
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  List<TopSalonItem> get salons => _salons;
  int get totalSalons => _paginationData?.total ?? 0;
  int get lastPage => _paginationData?.lastPage ?? 1;

  /// Load initial data
  Future<void> loadTopSalons() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _salons.clear();
    notifyListeners();

    try {
      final response =
          await _topSalonsApi.fetchTopRatedSalons(page: _currentPage);

      _paginationData = response.response.data;
      _salons = response.response.data.data;
      _hasMoreData = response.response.data.nextPageUrl != null;
      log('✅ Loaded ${_salons.length} salons (Page $_currentPage of ${_paginationData?.lastPage})');
    } catch (e) {
      _errorMessage = 'Failed to load salons. Please try again.';
      log('❌ Error loading salons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more data (pagination)
  Future<void> loadMoreSalons() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage++;
      final response =
          await _topSalonsApi.fetchTopRatedSalons(page: _currentPage);

      _paginationData = response.response.data;
      _salons.addAll(response.response.data.data);
      _hasMoreData = response.response.data.nextPageUrl != null;
      log('✅ Loaded ${response.response.data.data.length} more salons (Page $_currentPage of ${_paginationData?.lastPage})');
    } catch (e) {
      _errorMessage = 'Failed to load more salons.';
      _currentPage--; // Revert page increment on failure
      log('❌ Error loading more salons: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refreshSalons() async {
    _currentPage = 1;
    _salons.clear();
    _hasMoreData = true;
    await loadTopSalons();
  }

  /// Reset state
  void reset() {
    _currentPage = 1;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMoreData = true;
    _errorMessage = null;
    _salons.clear();
    _paginationData = null;
    notifyListeners();
  }
}
