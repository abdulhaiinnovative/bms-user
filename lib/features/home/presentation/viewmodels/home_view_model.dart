import 'dart:convert';

import 'package:app/constants.dart';
import 'package:app/core/base/base_view_model.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as dio;
import 'package:http/http.dart' as http;
// import 'package:http/http.dart' as dio;
import '../../data/repositories/home_repository.dart';
import 'package:app/models/HomePageResponse.dart';

import 'home_slider_response.dart';

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
  List<Service>? _featuredServices;
  List<SliderBlock>? _sliders;
  // Getters
  List<Type1>? get banners => _type1;
  List<SliderBlock>? get sliders => _sliders;
  List<CategorySection>? get categories => _type2;
  List<TopSalonSection>? get salons => _type3;
  List<DealSection>? get deals => _type4;
  List<ServiceSection>? get services => _type5;
  List<Service>? get featuredServices => _featuredServices;

  // Check if data is available
  bool get hasData =>
      _type2 != null && _type3 != null && _type4 != null && _type5 != null;

  /// Load home page data
  Future<void> loadHomeData() async {
    await executeAsync(
      operation: () async {
        final response = await _homeRepository.fetchHomePageData();
        final sliderResponse = await fetchSliders(); // add this

        // Fetch Top Rated & Popular Salons from specific APIs for Dashboard
        List<TopSalonSection> customSalonsSections = [];
        try {
          final topRatedRes = await http.get(Uri.parse('$BASE_URL/get-top-rated-salon'));
          if (topRatedRes.statusCode == 200) {
            final data = jsonDecode(topRatedRes.body);
            if (data['status'] == true && data['response']?['data']?['data'] != null) {
              final List items = data['response']['data']['data'];
              if (items.isNotEmpty) {
                customSalonsSections.add(TopSalonSection(
                  heading: "Top Rated Salons",
                  data: items.map((item) => Salon.fromJson(item)).toList(),
                ));
              }
            }
          }
          
          final popularRes = await http.get(Uri.parse('$BASE_URL/get-popular-salons'));
          if (popularRes.statusCode == 200) {
            final data = jsonDecode(popularRes.body);
            if (data['status'] == true && data['response']?['data']?['data'] != null) {
              final List items = data['response']['data']['data'];
              if (items.isNotEmpty) {
                customSalonsSections.add(TopSalonSection(
                  heading: "Popular Salons",
                  data: items.map((item) => Salon.fromJson(item)).toList(),
                ));
              }
            }
          }
        } catch (e) {
          print("Error fetching custom salons for dashboard: $e");
        }

        // Fetch Featured Services
        List<Service> customFeaturedServices = [];
        try {
          final featuredRes = await http.get(Uri.parse('$BASE_URL/get-featured-services'));
          if (featuredRes.statusCode == 200) {
            final data = jsonDecode(featuredRes.body);
            if (data['status'] == true && data['response']?['data']?['data'] != null) {
              final List items = data['response']['data']['data'];
              if (items.isNotEmpty) {
                customFeaturedServices = items.map((item) => Service.fromJson(item)).toList();
              }
            }
          }
        } catch (e) {
          print("Error fetching featured services: $e");
        }

        _sliders = sliderResponse.data;
        _type1 = response.response.data.type1;
        _type2 = response.response.data.type2;
        // Use custom salon sections if successfully fetched, otherwise fallback to API type3
        _type3 = customSalonsSections.isNotEmpty ? customSalonsSections : response.response.data.type3;
        _type4 = response.response.data.type4;
        _type5 = response.response.data.type5;
        _featuredServices = customFeaturedServices;

        return response;
      },
      onError: (error) {
        // Error handled by caller/executor
      },
    );
  }

  /// Track slider click
  Future<void> trackSliderClickById(int id) async {
    try {
      await _homeRepository.trackSliderClickById(id);
    } catch (e) {
      // Log error
      print('Error tracking slider click: $e');
    }
  }

  // In HomeRepository

  Future<HomeSliderResponse> fetchSliders() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/get-slider'),
    );

    final data = jsonDecode(response.body);

    return HomeSliderResponse.fromJson(data);
  }

  /// Refresh home page data
  Future<void> refreshHomeData() async {
    // Clear existing data
    _type1 = null;
    _type2 = null;
    _type3 = null;
    _type4 = null;
    _type5 = null;
    _featuredServices = null;

    // Reload data
    await loadHomeData();
  }
}
