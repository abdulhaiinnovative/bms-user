import 'package:flutter/material.dart';
import '../../core/base/base_view_model.dart';
import '../../data/repositories/search_repository.dart';
import '../../models/HomePageResponse.dart';

class SearchProviderNew extends BaseViewModel {
  final SearchRepository _repository = SearchRepository();

  List<Service> _services = [];
  List<Salon> _salons = [];
  List<Deal> _deals = [];
  String? _nextPageUrl;
  String? _currentType;

  List<Service> get services => _services;
  List<Salon> get salons => _salons;
  List<Deal> get deals => _deals;
  String? get currentType => _currentType;
  String? get error => errorMessage; // Map to BaseViewModel's errorMessage

  Future<void> searchServices(String query,
      {int? categoryId,
      double? minPrice,
      double? maxPrice,
      String? gender,
      String? sortBy,
      String? sortOrder,
      String? pageUrl}) async {
    _currentType = 'service';

    await executeAsync(
      operation: () async {
        final response = await _repository.search(
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
        _services =
            pageUrl == null ? response['data'] : _services + response['data'];
        _nextPageUrl = response['nextPageUrl'];
      },
    );
  }

  Future<void> searchSalons(String query,
      {String? location,
      double? minRating,
      String? sortBy,
      String? sortOrder,
      String? pageUrl}) async {
    _currentType = 'salon';

    await executeAsync(
      operation: () async {
        final response = await _repository.search(
          type: 'salon',
          title: query.isEmpty ? 'all' : query,
          sortBy: sortBy ?? 'rating',
          sortOrder: sortOrder ?? 'desc',
          location: location,
          minRating: minRating,
          pageUrl: pageUrl,
        );
        _salons =
            pageUrl == null ? response['data'] : _salons + response['data'];
        _nextPageUrl = response['nextPageUrl'];
      },
    );
  }

  Future<void> searchDeals(String query,
      {int? categoryId,
      double? minPrice,
      double? maxPrice,
      String? sortBy,
      String? sortOrder,
      String? pageUrl}) async {
    _currentType = 'deal';

    await executeAsync(
      operation: () async {
        final response = await _repository.search(
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
      },
    );
  }

  Future<void> loadMore() async {
    if (_nextPageUrl == null || isLoading) return;

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
    _nextPageUrl = null;
    _currentType = null;
    setIdle();
  }
}
