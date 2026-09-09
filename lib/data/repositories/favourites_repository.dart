import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/favourite_api.dart';

/// Repository for favourites operations
class FavouritesRepository extends BaseRepository {
  final FavouriteAPI _favouriteAPI;

  FavouritesRepository({FavouriteAPI? favouriteAPI})
      : _favouriteAPI = favouriteAPI ?? FavouriteAPI();

  /// Get list of favourite salons with pagination
  Future<Map<String, dynamic>> getFavouritesList({int page = 1}) async {
    return await execute(
      operation: () => _favouriteAPI.getFavouritesList(page: page),
      errorContext: 'Get favourites list',
    );
  }

  /// Toggle favourite status for a salon or service
  Future<Map<String, dynamic>> toggleFavourite({
    required String shareId,
    required String shareType,
  }) async {
    return await execute(
      operation: () => _favouriteAPI.toggleFavourite(
        shareId: shareId,
        shareType: shareType,
      ),
      errorContext: 'Toggle favourite',
    );
  }
}
