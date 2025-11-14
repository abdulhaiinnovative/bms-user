import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/category_repository.dart';
import 'package:app/models/category/CategoryResponseData.dart';
import 'package:app/models/category/CategoryDetailsData.dart';
import 'package:app/models/home/ServiceData.dart';

/// ViewModel for Category Details Screen
/// Manages state for category services and details
class CategoryViewModel extends BaseViewModel {
  final CategoryRepository _repository;

  CategoryViewModel({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  // State
  CategoryResponseData? _categoryData;
  int? _currentCategoryId;

  // Getters
  CategoryResponseData? get categoryData => _categoryData;
  CategoryDetailsData? get categoryDetails => _categoryData?.response?.data;
  String get categoryName => categoryDetails?.category?.name ?? '';
  List<ServiceData>? get services => categoryDetails?.services?.data;
  int get servicesCount => services?.length ?? 0;
  bool get hasServices => services != null && services!.isNotEmpty;
  bool get isEmpty => _categoryData != null && !hasServices;

  /// Load category details by ID
  Future<void> loadCategoryDetails(int categoryId) async {
    log('CategoryViewModel: Loading category details for ID: $categoryId');
    _currentCategoryId = categoryId;

    await executeAsync(
      operation: () async {
        final response = await _repository.getCategoryDetails(categoryId);

        log('CategoryViewModel: Response received');

        if (response != null) {
          _categoryData = response;
          log('CategoryViewModel: Category loaded successfully');
          log('  - Category: ${categoryDetails?.category?.name}');
          log('  - Services: ${servicesCount}');
        } else {
          log('CategoryViewModel: Load failed - No response');
          throw Exception('Failed to load category details');
        }

        notifyListeners();
      },
    );
  }

  /// Refresh category details
  Future<void> refresh() async {
    if (_currentCategoryId == null) {
      log('CategoryViewModel: Cannot refresh - no category ID');
      return;
    }
    
    log('CategoryViewModel: Refreshing category details');
    await loadCategoryDetails(_currentCategoryId!);
  }

  /// Get service by index
  ServiceData? getServiceAt(int index) {
    if (services == null || index >= services!.length) {
      return null;
    }
    return services![index];
  }

  /// Search services by name
  List<ServiceData> searchServices(String query) {
    if (services == null || query.isEmpty) {
      return services ?? [];
    }

    final lowerQuery = query.toLowerCase();
    return services!.where((service) {
      final name = service.name?.toLowerCase() ?? '';
      final description = service.description?.toLowerCase() ?? '';
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }
}
