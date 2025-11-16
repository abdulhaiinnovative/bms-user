import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/salon_services_repository.dart';
import 'package:app/models/SalonServicesCategorizedResponse.dart';

/// ViewModel for salon categorized services and deals
class SalonServicesViewModel extends BaseViewModel {
  final SalonServicesRepository _repository;

  SalonServicesViewModel({SalonServicesRepository? repository})
      : _repository = repository ?? SalonServicesRepository();

  // State
  SalonServicesCategorizedResponse? _response;
  List<Category>? _categories;
  int? _currentSalonId;

  // Getters
  SalonServicesCategorizedResponse? get response => _response;
  List<Category>? get categories => _categories;
  bool get hasCategories => _categories != null && _categories!.isNotEmpty;
  int get categoriesCount => _categories?.length ?? 0;

  /// Get category at specific index
  Category? getCategoryAt(int index) {
    if (_categories == null || index < 0 || index >= _categories!.length) {
      return null;
    }
    return _categories![index];
  }

  /// Get all category names
  List<String> getCategoryNames() {
    if (_categories == null) return [];
    return _categories!.map((cat) => cat.name ?? "NA").toList();
  }

  /// Get items for a specific category
  List<dynamic> getCategoryItems(int categoryIndex) {
    final category = getCategoryAt(categoryIndex);
    return category?.items ?? [];
  }

  /// Load categorized services for a salon
  Future<void> loadCategorizedServices(int salonId) async {
    log('SalonServicesViewModel: Loading categorized services for salon $salonId');
    _currentSalonId = salonId;

    await executeAsync(
      operation: () async {
        final response =
            await _repository.getCategorizedServices(salonId);

        if (response != null) {
          _response = response;
          _categories = response.response?.data;

          log('SalonServicesViewModel: Loaded ${_categories?.length ?? 0} categories');
          _categories?.forEach((category) {
            log('  - ${category.name ?? 'Unknown'}: ${category.items?.length ?? 0} items');
          });
        }
      },
      onError: (error) {
        log('SalonServicesViewModel: Failed to load services - $error');
      },
    );
  }

  /// Refresh current salon services
  Future<void> refresh() async {
    if (_currentSalonId != null) {
      await loadCategorizedServices(_currentSalonId!);
    }
  }

  /// Search items across all categories
  List<dynamic> searchItems(String query) {
    if (_categories == null || query.isEmpty) return [];

    final results = <dynamic>[];
    for (final category in _categories!) {
      if (category.items != null) {
        final matchingItems = category.items!.where((item) {
          final name = item.name?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
        results.addAll(matchingItems);
      }
    }
    return results;
  }
}
