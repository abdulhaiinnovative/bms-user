import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../../api_services/services_api.dart';
import '../../../../models/services_response.dart';
import '../../../../models/HomePageResponse.dart';

enum ServiceGender { men, women }

class ServicesViewModel extends ChangeNotifier {
  final ServicesApi _servicesApi = ServicesApi();
  final ServiceGender gender;

  // Pagination state
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;

  // Data
  List<Service> _services = [];
  ServicesPaginatedData? _paginationData;

  // Getters
  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  List<Service> get services => _services;
  int get totalServices => _paginationData?.total ?? 0;
  int get lastPage => _paginationData?.lastPage ?? 1;
  String get title =>
      gender == ServiceGender.men ? "Men's Services" : "Women's Services";

  ServicesViewModel({required this.gender});

  /// Load initial data
  Future<void> loadServices() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _services.clear();
    notifyListeners();

    try {
      final response = gender == ServiceGender.men
          ? await _servicesApi.fetchMenServices(page: _currentPage)
          : await _servicesApi.fetchWomenServices(page: _currentPage);

      _paginationData = response.response.data;
      _services = response.response.data.data;
      _hasMoreData = response.response.data.nextPageUrl != null;
      log('✅ Loaded ${_services.length} ${gender == ServiceGender.men ? "men" : "women"} services (Page $_currentPage of ${_paginationData?.lastPage})');
    } catch (e) {
      _errorMessage = 'Failed to load services. Please try again.';
      log('❌ Error loading services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more data (pagination)
  Future<void> loadMoreServices() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage++;
      final response = gender == ServiceGender.men
          ? await _servicesApi.fetchMenServices(page: _currentPage)
          : await _servicesApi.fetchWomenServices(page: _currentPage);

      _paginationData = response.response.data;
      _services.addAll(response.response.data.data);
      _hasMoreData = response.response.data.nextPageUrl != null;
      log('✅ Loaded ${response.response.data.data.length} more ${gender == ServiceGender.men ? "men" : "women"} services (Page $_currentPage of ${_paginationData?.lastPage})');
    } catch (e) {
      _errorMessage = 'Failed to load more services.';
      _currentPage--; // Revert page increment on failure
      log('❌ Error loading more services: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refreshServices() async {
    _currentPage = 1;
    _services.clear();
    _hasMoreData = true;
    await loadServices();
  }

  /// Reset state
  void reset() {
    _currentPage = 1;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMoreData = true;
    _errorMessage = null;
    _services.clear();
    _paginationData = null;
    notifyListeners();
  }
}
