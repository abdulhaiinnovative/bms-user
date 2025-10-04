import 'package:app/screens/search_final/search_salon_api.dart';
import 'package:flutter/material.dart';
import '../../models/HomePageResponse.dart';


class SearchProviderNew with ChangeNotifier {
  List<Service> _services = [];
  List<Salon> _salons = [];
  List<Deal> _deals = [];
  bool _isLoading = false;
  String? _error;
  String? _nextPageUrl;
  String? _currentType;

  List<Service> get services => _services;
  List<Salon> get salons => _salons;
  List<Deal> get deals => _deals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentType => _currentType;

  Future<void> searchServices(String query, {int? categoryId, double? minPrice, double? maxPrice, String? gender, String? sortBy, String? sortOrder, String? pageUrl}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'service';
    notifyListeners();

    try {
      final response = await SearchSalonApi.search(
        type: 'service',
        title: query.isEmpty ? 'all' : query,
        sortBy: sortBy ?? 'name',
        sortOrder: sortOrder ?? 'desc',
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        gender: gender,
        pageUrl: pageUrl,
      );
      _services = pageUrl == null ? response['data'] : _services + response['data'];
      _nextPageUrl = response['nextPageUrl'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchSalons(String query, {String? location, double? minRating, String? sortBy, String? sortOrder, String? pageUrl}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'salon';
    notifyListeners();

    try {
      final response = await SearchSalonApi.search(
        type: 'salon',
        title: query.isEmpty ? 'all' : query,
        sortBy: sortBy ?? 'rating',
        sortOrder: sortOrder ?? 'desc',
        location: location,
        minRating: minRating,
        pageUrl: pageUrl,
      );
      _salons = pageUrl == null ? response['data'] : _salons + response['data'];
      _nextPageUrl = response['nextPageUrl'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchDeals(String query, {int? categoryId, double? minPrice, double? maxPrice, String? sortBy, String? sortOrder, String? pageUrl}) async {
    _isLoading = true;
    _error = null;
    _currentType = 'deal';
    notifyListeners();

    try {
      final response = await SearchSalonApi.search(
        type: 'deal',
        title: query.isEmpty ? 'all' : query,
        sortBy: sortBy ?? 'total_price',
        sortOrder: sortOrder ?? 'asc',
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        pageUrl: pageUrl,
      );
      _deals = pageUrl == null ? response['data'] : _deals + response['data'];
      _nextPageUrl = response['nextPageUrl'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_nextPageUrl == null || _isLoading) return;

    if (_currentType == 'service') {
      await searchServices('', pageUrl: _nextPageUrl);
    } else if (_currentType == 'salon') {
      await searchSalons('', pageUrl: _nextPageUrl);
    } else if (_currentType == 'deal') {
      await searchDeals('', pageUrl: _nextPageUrl);
    }
  }

  void clearFilters() {
    _services = [];
    _salons = [];
    _deals = [];
    _error = null;
    _nextPageUrl = null;
    _currentType = null;
    notifyListeners();
  }
}