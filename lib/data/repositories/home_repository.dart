import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/home_screen_api.dart';
import 'package:app/models/HomePageResponse.dart';

/// Repository for home screen data operations
/// Handles data fetching and caching for the home screen
class HomeRepository extends BaseRepository {
  final HomeScreenAPI _homeScreenAPI;

  HomeRepository({HomeScreenAPI? homeScreenAPI})
      : _homeScreenAPI = homeScreenAPI ?? HomeScreenAPI();

  /// Fetch home page data including sliders, categories, salons, deals, and services
  Future<HomePageResponse> fetchHomePageData() async {
    return await execute(
      operation: () => _homeScreenAPI.fetchHomePageData(),
      errorContext: 'Fetch home page data',
    );
  }
}
