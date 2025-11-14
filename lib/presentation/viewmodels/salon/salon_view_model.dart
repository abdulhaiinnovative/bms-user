import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/salon_repository.dart';
import 'package:app/models/SalonDetailApiResponse.dart';

/// ViewModel for salon details management
/// Handles salon information, services, reviews, and availability
class SalonViewModel extends BaseViewModel {
  final SalonRepository _repository;

  SalonViewModel({SalonRepository? repository})
      : _repository = repository ?? SalonRepository();

  // State
  SalonData? _salonData;
  SalonDetailApiResponse? _response;

  // Getters
  SalonData? get salonData => _salonData;
  List<Section>? get sections => _salonData?.sections;
  Location? get location => _salonData?.location;

  String get salonName => _salonData?.name ?? '';
  String get salonLogo => _salonData?.logo ?? '';
  List<String> get salonImages => _salonData?.images ?? [];
  int get starRating => _salonData?.star ?? 0;
  int get reviewCount => _salonData?.review_count ?? 0;
  String get salonAbout => _salonData?.about ?? '';
  String get salonPolicy => _salonData?.policy ?? '';
  String get salonType => _salonData?.type ?? '';
  String get salonKind => _salonData?.kind ?? '';
  String get salonGender => _salonData?.gender ?? '';
  bool get isFavourite => _salonData?.isFavourite ?? false;

  // Social media
  String get facebook => _salonData?.fackebook ?? '';
  String get instagram => _salonData?.instagram ?? '';
  String get twitter => _salonData?.twitter ?? '';
  String get linkedin => _salonData?.linkedin ?? '';

  bool get hasDetails => _salonData != null;
  bool get hasSections => sections != null && sections!.isNotEmpty;
  bool get hasLocation => location != null;

  /// Load salon details by ID
  Future<void> loadSalonDetails(String salonId) async {
    log('SalonViewModel: Loading salon details for ID: $salonId');

    await executeAsync(
      operation: () async {
        final response = await _repository.getSalonDetails(salonId);

        log('SalonViewModel: Response received');

        if (response != null) {
          _response = response;
          _salonData = response.response.data;

          log('SalonViewModel: Salon loaded successfully');
          log('  - Name: ${_salonData?.name}');
          log('  - Sections: ${_salonData?.sections?.length ?? 0}');
          log('  - Is Favourite: ${_salonData?.isFavourite}');
        } else {
          log('SalonViewModel: Load failed - No response');
          throw Exception('Failed to load salon details');
        }

        notifyListeners();
      },
    );
  }

  /// Refresh salon details
  Future<void> refresh(String salonId) async {
    log('SalonViewModel: Refreshing salon details');
    await loadSalonDetails(salonId);
  }

  /// Get all services from all sections
  List<dynamic> getAllSectionData() {
    if (sections == null) return [];

    return sections!
        .expand((section) =>
            (section.data is List) ? section.data as List : [section.data])
        .toList();
  }

  /// Get data by section index
  dynamic getDataForSection(int sectionIndex) {
    if (sections == null || sectionIndex >= sections!.length) {
      return null;
    }

    return sections![sectionIndex].data;
  }

  /// Get section names
  List<String> getSectionNames() {
    if (sections == null) return [];

    return sections!
        .map((section) => section.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
