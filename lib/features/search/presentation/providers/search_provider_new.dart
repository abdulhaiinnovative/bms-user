import 'package:flutter/material.dart';
import '../../../../models/HomePageResponse.dart';
import '../../../../api_services/search_api_service.dart';

class SearchProviderNew with ChangeNotifier {
  List<Service> _services = [];
  List<Salon> _salons = [];
  List<Deal> _deals = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentType;

  // Store last search parameters for pagination
  String? _lastKeyword;
  int? _lastCategoryId;
  List<int>? _lastCategories;
  double? _lastMinPrice;
  double? _lastMaxPrice;
  String? _lastGender;
  String? _lastLocation;
  String? _lastSortBy;
  String? _lastTimeSlot;

  List<Service> get services => _services;
  List<Salon> get salons => _salons;
  List<Deal> get deals => _deals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentType => _currentType;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _currentPage < _totalPages;

  Future<void> searchServices(String query,
      {int? categoryId,
      List<int>? categories,
      double? minPrice,
      double? maxPrice,
      String? gender,
      String? sortBy,
      String? timeSlot,
      bool loadMore = false}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'service';

    if (!loadMore) {
      _currentPage = 1;
      _lastKeyword = query;
      _lastCategoryId = categoryId;
      _lastCategories = categories;
      _lastMinPrice = minPrice;
      _lastMaxPrice = maxPrice;
      _lastGender = gender;
      _lastSortBy = sortBy;
      _lastTimeSlot = timeSlot;
    }

    notifyListeners();

    try {
      // Build categories list
      List<int>? categoryList = categories;
      if (categoryList == null && categoryId != null) {
        categoryList = [categoryId];
      }

      // Build gender list
      List<String>? genderList = gender != null ? [gender] : null;

      // Use trimmed query - API will handle empty keyword with filter_type
      final trimmedQuery = query.trim();

      final response = await SearchApiService.searchServices(
        keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
        categories: categoryList,
        minPrice: minPrice,
        maxPrice: maxPrice,
        gender: genderList,
        sortBy: sortBy ?? 'relevance',
        perPage: 12,
        page: _currentPage,
      );

      // Extract services from response
      final servicesList = response.data.getServicesList();

      if (loadMore) {
        _services.addAll(servicesList);
      } else {
        _services = servicesList;
      }

      // Update pagination info
      if (response.data.services is ServicePagination) {
        final pagination = response.data.services as ServicePagination;
        _currentPage = pagination.currentPage;
        _totalPages = pagination.lastPage;
      } else {
        // Array result, no pagination
        _currentPage = 1;
        _totalPages = 1;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchSalons(String query,
      {String? location,
      String? area,
      String? type,
      List<String>? gender,
      String? timeSlot,
      String? sortBy,
      bool loadMore = false}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'salon';

    if (!loadMore) {
      _currentPage = 1;
      _lastKeyword = query;
      _lastLocation = location;
      _lastSortBy = sortBy;
      _lastTimeSlot = timeSlot;
    }

    notifyListeners();

    try {
      // Use trimmed query - API will handle empty keyword with filter_type
      final trimmedQuery = query.trim();

      final response = await SearchApiService.searchSalons(
        keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
        location: location,
        area: area,
        type: type,
        gender: gender,
        timeSlot: timeSlot,
        sortBy: sortBy ?? 'rating',
        perPage: 12,
        page: _currentPage,
      );

      // Extract salons from response
      final salonsList = response.data.getSalonsList();

      if (loadMore) {
        _salons.addAll(salonsList);
      } else {
        _salons = salonsList;
      }

      // Update pagination info
      if (response.data.salons is SalonPagination) {
        final pagination = response.data.salons as SalonPagination;
        _currentPage = pagination.currentPage;
        _totalPages = pagination.lastPage;
      } else {
        // Array result, no pagination
        _currentPage = 1;
        _totalPages = 1;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchDeals(String query,
      {int? categoryId,
      List<int>? categories,
      double? minPrice,
      double? maxPrice,
      String? sortBy,
      bool loadMore = false}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'deal';

    if (!loadMore) {
      _currentPage = 1;
      _lastKeyword = query;
      _lastCategoryId = categoryId;
      _lastCategories = categories;
      _lastMinPrice = minPrice;
      _lastMaxPrice = maxPrice;
      _lastSortBy = sortBy;
    }

    notifyListeners();

    try {
      // Build categories list
      List<int>? categoryList = categories;
      if (categoryList == null && categoryId != null) {
        categoryList = [categoryId];
      }

      // Use trimmed query - API will handle empty keyword with filter_type
      final trimmedQuery = query.trim();

      final response = await SearchApiService.searchDeals(
        keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy ?? 'price_low',
        perPage: 12,
        page: _currentPage,
      );

      // Extract deals from response
      final dealsList = response.data.getDealsList();

      if (loadMore) {
        _deals.addAll(dealsList);
      } else {
        _deals = dealsList;
      }

      // Update pagination info
      if (response.data.deals is DealPagination) {
        final pagination = response.data.deals as DealPagination;
        _currentPage = pagination.currentPage;
        _totalPages = pagination.lastPage;
      } else {
        // Array result, no pagination
        _currentPage = 1;
        _totalPages = 1;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMorePages || _isLoading) return;

    _currentPage++;

    if (_currentType == 'service') {
      await searchServices(
        _lastKeyword ?? '',
        categoryId: _lastCategoryId,
        categories: _lastCategories,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        gender: _lastGender,
        sortBy: _lastSortBy,
        timeSlot: _lastTimeSlot,
        loadMore: true,
      );
    } else if (_currentType == 'salon') {
      await searchSalons(
        _lastKeyword ?? '',
        location: _lastLocation,
        sortBy: _lastSortBy,
        timeSlot: _lastTimeSlot,
        loadMore: true,
      );
    } else if (_currentType == 'deal') {
      await searchDeals(
        _lastKeyword ?? '',
        categoryId: _lastCategoryId,
        categories: _lastCategories,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        sortBy: _lastSortBy,
        loadMore: true,
      );
    }
  }

  void clearFilters() {
    _services = [];
    _salons = [];
    _deals = [];
    _error = null;
    _currentPage = 1;
    _totalPages = 1;
    _currentType = null;
    _lastKeyword = null;
    _lastCategoryId = null;
    _lastCategories = null;
    _lastMinPrice = null;
    _lastMaxPrice = null;
    _lastGender = null;
    _lastLocation = null;
    _lastSortBy = null;
    _lastTimeSlot = null;
    notifyListeners();
  }
}
