import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../../../models/HomePageResponse.dart';

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
        log('HomeViewModel: Loading home page data');
        final response = await _homeRepository.fetchHomePageData();

        // Update data
        _type1 = response.response.data.type1;
        _type2 = response.response.data.type2;
        _type3 = response.response.data.type3;
        _type4 = response.response.data.type4;
        _type5 = response.response.data.type5;

        // Log data for debugging
        log('type1 (sliders): ${_type1?.length ?? 0} ${_type1?.isNotEmpty == true ? _type1![0].heading : 'null'} ${_type1?.isNotEmpty == true ? _type1![0].data.length : 0}');
        log('type2 (categories): ${_type2?.length ?? 0} ${_type2?.isNotEmpty == true ? _type2![0].heading : 'null'} ${_type2?.isNotEmpty == true ? _type2![0].data.length : 0}');
        log('type3 (salons): ${_type3?.length ?? 0} ${_type3?.isNotEmpty == true ? _type3![0].heading : 'null'} ${_type3?.isNotEmpty == true ? _type3![0].data.length : 0}');
        log('type4 (deals): ${_type4?.length ?? 0}');
        log('type5 (services): ${_type5?.length ?? 0}');

        // Log slider details
        if (_type1?.isNotEmpty == true) {
          for (int i = 0; i < _type1![0].data.length; i++) {
            log('type1 url: ${_type1![0].data[i].url}');
            log('type1 image: ${_type1![0].data[i].image}');
          }
        }

        // Log category details
        if (_type2?.isNotEmpty == true) {
          log('type2 heading: ${_type2![0].heading}');
          for (int i = 0; i < _type2![0].data.length; i++) {
            log('type2 name: ${_type2![0].data[i].name}');
          }
        }

        // Log salon details
        if (_type3?.isNotEmpty == true) {
          log('type3 heading: ${_type3![0].heading}');
          for (int i = 0; i < _type3![0].data.length; i++) {
            log('type3 name: ${_type3![0].data[i].name}');
          }
        }

        log('HomeViewModel: Data loaded successfully');
        return response;
      },
      onError: (error) {
        log('HomeViewModel: Failed to load data - $error');
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
