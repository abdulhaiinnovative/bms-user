import 'package:app/core/base/base_view_model.dart';
import '../../data/repositories/home_repository.dart';
import 'package:app/models/HomePageResponse.dart';

/// ViewModel for the Home Screen
/// Manages state and business logic for home page data
class HomeViewModel extends BaseViewModel {
  final HomeRepository _homeRepository;

  HomeViewModel({HomeRepository? homeRepository})
      : _homeRepository = homeRepository ?? HomeRepository();

  // Data properties
  List<Type1>? _type1;
  List<CategorySection>? _type2;
  List<TopSalonSection>? _type3;
  List<DealSection>? _type4;
  List<ServiceSection>? _type5;

  // Getters
  List<Type1>? get sliders => _type1;
  List<CategorySection>? get categories => _type2;
  List<TopSalonSection>? get salons => _type3;
  List<DealSection>? get deals => _type4;
  List<ServiceSection>? get services => _type5;

  // Check if data is available
  bool get hasData =>
      _type2 != null && _type3 != null && _type4 != null && _type5 != null;

  /// Load home page data
  Future<void> loadHomeData() async {
    await executeAsync(
      operation: () async {
        final response = await _homeRepository.fetchHomePageData();

        // Update data
        _type1 = response.response.data.type1;
        _type2 = response.response.data.type2;
        _type3 = response.response.data.type3;
        _type4 = response.response.data.type4;
        _type5 = response.response.data.type5;

        return response;
      },
      onError: (error) {
        // Error handled by caller/executor
      },
    );
  }

  /// Refresh home page data
  Future<void> refreshHomeData() async {
    // Clear existing data
    _type1 = null;
    _type2 = null;
    _type3 = null;
    _type4 = null;
    _type5 = null;

    // Reload data
    await loadHomeData();
  }
}
