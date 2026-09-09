import 'package:flutter/material.dart';
import 'package:app/models/HomePageResponse.dart' as HomePage;
import '../../../../api_services/search_api_service.dart';
import '../../data/services/search_cache_service.dart';

class SearchProviderNew with ChangeNotifier {
  List<HomePage.Service> _services = [];
  List<HomePage.Salon> _salons = [];
  List<HomePage.Deal> _deals = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentType;
  String? _specialSalonFilter; // null, 'top_rated', or 'popular'

  bool _hasSearched = false;

  int _salonsCount = 0;
  int _servicesCount = 0;
  int _dealsCount = 0;

  // Last search parameters
  String? _lastKeyword;
  int? _lastCategoryId;
  int? _lastServiceCategoryId;        // ← Yeh add kiya gaya hai
  List<int>? _lastCategories;
  double? _lastMinPrice;
  double? _lastMaxPrice;
  String? _lastGender;
  String? _lastLocation;
  String? _lastSortBy;
  String? _lastTimeSlot;

  // Getters
  List<HomePage.Service> get services => _services;
  List<HomePage.Salon> get salons => _salons;
  List<HomePage.Deal> get deals => _deals;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentType => _currentType;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _currentPage < _totalPages;
  bool get hasSearched => _hasSearched;
  String? get specialSalonFilter => _specialSalonFilter;

  int? get lastCategoryId => _lastCategoryId;        // Keep for backward compatibility
  int? get lastServiceCategoryId => _lastServiceCategoryId;

  int get salonsCount => _salonsCount;
  int get servicesCount => _servicesCount;
  int get dealsCount => _dealsCount;

  // ====================== SEARCH DEALS (UPDATED) ======================
  Future<void> searchDeals(String query,
      {int? categoryId,
        int? serviceCategoryId,        // ← Yeh use hoga Deals ke liye
        List<int>? categories,
        double? minPrice,
        double? maxPrice,
        String? sortBy,
        bool loadMore = false}) async {

    _isLoading = true;
    _error = null;
    _currentType = 'deal';
    _hasSearched = true;

    if (!loadMore) {
      _currentPage = 1;
      _lastKeyword = query;
      _lastCategoryId = categoryId;
      _lastServiceCategoryId = serviceCategoryId;   // ← Save kar rahe hain
      _lastCategories = categories;
      _lastMinPrice = minPrice;
      _lastMaxPrice = maxPrice;
      _lastSortBy = sortBy;

      _services = [];
      _salons = [];
      _servicesCount = 0;
      _salonsCount = 0;
    }

    notifyListeners();

    try {
      final trimmedQuery = query.trim();

      SearchResponse? response;
      if (!loadMore) {
        final cachedResponse = SearchCacheService.getCached(
          keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
          filterType: ['deal'],
          minPrice: minPrice,
          maxPrice: maxPrice,
          sortBy: sortBy ?? 'price_low',
          perPage: 12,
          page: _currentPage,
        );

        if (cachedResponse != null) {
          response = cachedResponse;
        }
      }

      if (response == null) {
        response = await SearchApiService.searchDeals(
          keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
          serviceCategoryId: serviceCategoryId,     // ← Backend ko bhej rahe hain
          minPrice: minPrice,
          maxPrice: maxPrice,
          sortBy: sortBy ?? 'price_low',
          perPage: 12,
          page: _currentPage,
        );

        if (!loadMore) {
          SearchCacheService.setCache(
            response: response,
            keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
            filterType: ['deal'],
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: sortBy ?? 'price_low',
            perPage: 12,
            page: _currentPage,
          );
        }
      }

      final dealsList = response.data.getDealsList();

      if (loadMore) {
        _deals.addAll(dealsList);
      } else {
        _deals = dealsList;
      }

      if (sortBy == 'name_asc') {
        _deals.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      } else if (sortBy == 'name_desc') {
        _deals.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
      }

      // Update pagination
      if (response.data.deals is DealPagination) {
        final pagination = response.data.deals as DealPagination;
        _currentPage = pagination.currentPage;
        _totalPages = pagination.lastPage;
      } else {
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

  // ====================== LOAD MORE ======================
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
      if (_specialSalonFilter == 'top_rated') {
        await searchTopRatedSalons(loadMore: true);
      } else if (_specialSalonFilter == 'popular') {
        await searchPopularSalons(loadMore: true);
      } else {
        await searchSalons(
          _lastKeyword ?? '',
          location: _lastLocation,
          sortBy: _lastSortBy,
          timeSlot: _lastTimeSlot,
          loadMore: true,
        );
      }
    } else if (_currentType == 'deal') {
      await searchDeals(
        _lastKeyword ?? '',
        serviceCategoryId: _lastServiceCategoryId,   // ← Yeh use ho raha hai
        categoryId: _lastCategoryId,
        categories: _lastCategories,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        sortBy: _lastSortBy,
        loadMore: true,
      );
    }
  }

  // ====================== SEARCH BY FILTER TYPE ======================
  Future<void> searchByFilterType(String filterType) async {
    if (!_hasSearched) return;

    switch (filterType) {
      case 'service':
        await searchServices(
          _lastKeyword ?? '',
          categoryId: _lastCategoryId,
          categories: _lastCategories,
          minPrice: _lastMinPrice,
          maxPrice: _lastMaxPrice,
          gender: _lastGender,
          sortBy: _lastSortBy,
          timeSlot: _lastTimeSlot,
        );
        break;

      case 'deal':
        await searchDeals(
          _lastKeyword ?? '',
          serviceCategoryId: _lastServiceCategoryId,   // ← Important
          categoryId: _lastCategoryId,
          categories: _lastCategories,
          minPrice: _lastMinPrice,
          maxPrice: _lastMaxPrice,
          sortBy: _lastSortBy,
        );
        break;

      case 'salon':
        if (_specialSalonFilter == 'top_rated') {
          await searchTopRatedSalons();
        } else if (_specialSalonFilter == 'popular') {
          await searchPopularSalons();
        } else {
          await searchSalons(
            _lastKeyword ?? '',
            location: _lastLocation,
            sortBy: _lastSortBy,
            timeSlot: _lastTimeSlot,
          );
        }
        break;

      default:
        await searchAll(
          keyword: _lastKeyword,
          location: _lastLocation,
          categoryId: _lastCategoryId,
          categories: _lastCategories,
          minPrice: _lastMinPrice,
          maxPrice: _lastMaxPrice,
          sortBy: _lastSortBy ?? 'relevance',
        );
    }
  }

  // ====================== OTHER METHODS ======================
  void markAsSearched() {
    _hasSearched = true;
    notifyListeners();
  }

  void clearFilters() {
    _services = [];
    _salons = [];
    _deals = [];
    _error = null;
    _currentPage = 1;
    _totalPages = 1;
    _currentType = null;
    _specialSalonFilter = null;
    _hasSearched = false;

    _lastKeyword = null;
    _lastCategoryId = null;
    _lastServiceCategoryId = null;        // ← Clear kiya
    _lastCategories = null;
    _lastMinPrice = null;
    _lastMaxPrice = null;
    _lastGender = null;
    _lastLocation = null;
    _lastSortBy = null;
    _lastTimeSlot = null;

    notifyListeners();
  }

  Future<void> refreshCurrentSearch() async {
    if (!_hasSearched) return;

    SearchCacheService.clearCache();

    if (_currentType == 'all' || _currentType == null) {
      await searchAll(
        keyword: _lastKeyword,
        location: _lastLocation,
        categoryId: _lastCategoryId,
        categories: _lastCategories,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        sortBy: _lastSortBy ?? 'relevance',
      );
    } else if (_currentType == 'service') {
      await searchServices(
        _lastKeyword ?? '',
        categoryId: _lastCategoryId,
        categories: _lastCategories,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        gender: _lastGender,
        sortBy: _lastSortBy,
        timeSlot: _lastTimeSlot,
      );
    } else if (_currentType == 'salon') {
      if (_specialSalonFilter == 'top_rated') {
        await searchTopRatedSalons();
      } else if (_specialSalonFilter == 'popular') {
        await searchPopularSalons();
      } else {
        await searchSalons(
          _lastKeyword ?? '',
          location: _lastLocation,
          sortBy: _lastSortBy,
          timeSlot: _lastTimeSlot,
        );
      }
    } else if (_currentType == 'deal') {
      await searchDeals(
        _lastKeyword ?? '',
        serviceCategoryId: _lastServiceCategoryId,   // ← Yeh bhi pass kiya
        categoryId: _lastCategoryId,
        categories: _lastCategories,
        minPrice: _lastMinPrice,
        maxPrice: _lastMaxPrice,
        sortBy: _lastSortBy,
      );
    }
  }
  /// Unified search method - fetches salons, services, and deals in one API call
  /// Updates all three tabs simultaneously
  /// Uses caching to avoid redundant API calls
  Future<void> searchAll({
    String? keyword,
    String? location,
    String? area,
    String? type,
    int? categoryId,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
  }) async {
    _isLoading = true;
    _error = null;
    _currentType = 'all';
    _specialSalonFilter = null;
    _hasSearched = true; // Mark that user has searched

    // Save search parameters
    _lastKeyword = keyword;
    _lastCategoryId = categoryId;
    _lastCategories = categories;
    _lastMinPrice = minPrice;
    _lastMaxPrice = maxPrice;
    _lastLocation = location;
    _lastSortBy = sortBy;

    notifyListeners();

    try {
      // Build categories list
      List<int>? categoryList = categories;
      if (categoryList == null && categoryId != null) {
        categoryList = [categoryId];
      }

      // Check cache first
      final cachedResponse = SearchCacheService.getCached(
        keyword: keyword,
        location: location,
        area: area,
        type: type,
        filterType: ['salon', 'service', 'deal'],
        categories: categoryList,
        minPrice: minPrice,
        maxPrice: maxPrice,
        gender: gender,
        sortBy: sortBy,
        perPage: perPage,
      );

      SearchResponse response;
      if (cachedResponse != null) {
        response = cachedResponse;
      } else {
        response = await SearchApiService.searchAll(
          keyword: keyword,
          location: location,
          area: area,
          type: type,
          categories: categoryList,
          minPrice: minPrice,
          maxPrice: maxPrice,
          gender: gender,
          sortBy: sortBy,
          perPage: perPage,
        );

        // Store in cache
        SearchCacheService.setCache(
          response: response,
          keyword: keyword,
          location: location,
          area: area,
          type: type,
          filterType: ['salon', 'service', 'deal'],
          categories: categoryList,
          minPrice: minPrice,
          maxPrice: maxPrice,
          gender: gender,
          sortBy: sortBy,
          perPage: perPage,
        );
      }

      // Update all three lists from unified response
      _salons = response.data.getSalonsList();
      _services = response.data.getServicesList();
      _deals = response.data.getDealsList();

      // Update counts
      _salonsCount = response.data.salonsCount;
      _servicesCount = response.data.servicesCount;
      _dealsCount = response.data.dealsCount;

      // For unified search, pagination is not available (arrays returned)
      _currentPage = 1;
      _totalPages = 1;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

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
    _specialSalonFilter = null;
    _hasSearched = true; // Mark that user has searched

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
      // Clear other lists when starting new search
      _salons = [];
      _deals = [];
      _salonsCount = 0;
      _dealsCount = 0;
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

      // Check cache first (only for initial load, not loadMore)
      SearchResponse? response;
      if (!loadMore) {
        final cachedResponse = SearchCacheService.getCached(
          keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
          filterType: ['service'],
          categories: categoryList,
          minPrice: minPrice,
          maxPrice: maxPrice,
          gender: genderList,
          sortBy: sortBy ?? 'relevance',
          perPage: 12,
          page: _currentPage,
        );

        if (cachedResponse != null) {
          response = cachedResponse;
        }
      }

      if (response == null) {
        response = await SearchApiService.searchServices(
          keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
          categories: categoryList,
          minPrice: minPrice,
          maxPrice: maxPrice,
          gender: genderList,
          sortBy: sortBy ?? 'relevance',
          perPage: 12,
          page: _currentPage,
        );

        // Store in cache (only for initial load)
        if (!loadMore) {
          SearchCacheService.setCache(
            response: response,
            keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
            filterType: ['service'],
            categories: categoryList,
            minPrice: minPrice,
            maxPrice: maxPrice,
            gender: genderList,
            sortBy: sortBy ?? 'relevance',
            perPage: 12,
            page: _currentPage,
          );
        }
      }

      // Extract services from response
      final servicesList = response.data.getServicesList();

      if (loadMore) {
        _services.addAll(servicesList);
      } else {
        _services = servicesList;
      }

      // Client-side name sorting (API doesn't support name-based sort)
      if (sortBy == 'name_asc') {
        _services.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      } else if (sortBy == 'name_desc') {
        _services.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
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
      _specialSalonFilter = null;
    }
    _hasSearched = true; // Mark that user has searched

    if (!loadMore) {
      _currentPage = 1;
      _lastKeyword = query;
      _lastLocation = location;
      _lastSortBy = sortBy;
      _lastTimeSlot = timeSlot;
      // Clear other lists when starting new search
      _services = [];
      _deals = [];
      _servicesCount = 0;
      _dealsCount = 0;
    }

    notifyListeners();

    try {
      // Use trimmed query - API will handle empty keyword with filter_type
      final trimmedQuery = query.trim();

      // Check cache first (only for initial load, not loadMore)
      SearchResponse? response;
      if (!loadMore) {
        final cachedResponse = SearchCacheService.getCached(
          keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
          location: location,
          area: area,
          type: type,
          filterType: ['salon'],
          gender: gender,
          timeSlot: timeSlot,
          sortBy: sortBy ?? 'rating',
          perPage: 12,
          page: _currentPage,
        );

        if (cachedResponse != null) {
          response = cachedResponse;
        }
      }

      if (response == null) {
        response = await SearchApiService.searchSalons(
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

        // Store in cache (only for initial load)
        if (!loadMore) {
          SearchCacheService.setCache(
            response: response,
            keyword: trimmedQuery.isEmpty ? null : trimmedQuery,
            location: location,
            area: area,
            type: type,
            filterType: ['salon'],
            gender: gender,
            timeSlot: timeSlot,
            sortBy: sortBy ?? 'rating',
            perPage: 12,
            page: _currentPage,
          );
        }
      }

      // Extract salons from response
      final salonsList = response.data.getSalonsList();

      if (loadMore) {
        _salons.addAll(salonsList);
      } else {
        _salons = salonsList;
      }

      if (sortBy == 'name_asc') {
        _salons.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      } else if (sortBy == 'name_desc') {
        _salons.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
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

  // ====================== SPECIAL SALON FILTERS ======================
  Future<void> searchTopRatedSalons({bool loadMore = false}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'salon';
    _hasSearched = true;
    _specialSalonFilter = 'top_rated';
    
    if (!loadMore) {
      _currentPage = 1;
      _salons = [];
      _salonsCount = 0;
      _services = [];
      _deals = [];
    }
    notifyListeners();

    try {
      final response = await SearchApiService.getTopRatedSalons(page: _currentPage);
      
      if (loadMore) {
        _salons.addAll(response.data);
      } else {
        _salons = response.data;
      }
      
      _currentPage = response.currentPage;
      _totalPages = response.lastPage;
      _salonsCount = response.total;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchPopularSalons({bool loadMore = false}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'salon';
    _hasSearched = true;
    _specialSalonFilter = 'popular';
    
    if (!loadMore) {
      _currentPage = 1;
      _salons = [];
      _salonsCount = 0;
      _services = [];
      _deals = [];
    }
    notifyListeners();

    try {
      final response = await SearchApiService.getPopularSalons(page: _currentPage);
      
      if (loadMore) {
        _salons.addAll(response.data);
      } else {
        _salons = response.data;
      }
      
      _currentPage = response.currentPage;
      _totalPages = response.lastPage;
      _salonsCount = response.total;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

}
