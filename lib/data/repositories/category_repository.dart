import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/CategoryDetailsAPI.dart';
import 'package:app/models/category/CategoryResponseData.dart';

/// Repository for category operations
class CategoryRepository extends BaseRepository {
  final CategoryDetailsAPI _categoryAPI;

  CategoryRepository({CategoryDetailsAPI? categoryAPI})
      : _categoryAPI = categoryAPI ?? CategoryDetailsAPI();

  /// Get category details by ID
  Future<CategoryResponseData?> getCategoryDetails(int categoryId) async {
    return await execute(
      operation: () => _categoryAPI.fetchCategoryData(categoryId),
      errorContext: 'Get category details',
    );
  }
}
