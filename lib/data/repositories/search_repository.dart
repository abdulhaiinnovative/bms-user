import '../../core/base/base_repository.dart';
import '../../screens/search_final/search_salon_api.dart';

class SearchRepository extends BaseRepository {
  Future<Map<String, dynamic>> search({
    required String type,
    required String title,
    String? sortBy,
    String? sortOrder,
    int? categoryId,
    String? location,
    double? minRating,
    double? minPrice,
    double? maxPrice,
    String? gender,
    String? pageUrl,
  }) async {
    return await execute(
      operation: () => SearchSalonApi.search(
        type: type,
        title: title,
        sortBy: sortBy,
        sortOrder: sortOrder,
        categoryId: categoryId,
        location: location,
        minRating: minRating,
        minPrice: minPrice,
        maxPrice: maxPrice,
        gender: gender,
        pageUrl: pageUrl,
      ),
    );
  }
}
