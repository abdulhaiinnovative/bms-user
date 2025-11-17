import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/salon_detail_repository.dart';
import 'package:app/models/SalonDetailApiResponse.dart';

/// ViewModel for Salon Detail Screen
/// Manages state for salon details and favourite status
class SalonDetailViewModel extends BaseViewModel {
  final SalonDetailRepository _repository;

  SalonDetailViewModel({SalonDetailRepository? repository})
      : _repository = repository ?? SalonDetailRepository();

  // State
  SalonData? _salonDetail;
  bool _isFavourite = false;

  // Getters
  SalonData? get salonDetail => _salonDetail;
  bool get isFavourite => _isFavourite;
  bool get hasSalonDetail => _salonDetail != null;

  /// Load salon detail data
  Future<void> loadSalonDetail(String salonId) async {
    log('SalonDetailViewModel: Loading salon detail for ID: $salonId');

    await executeAsync(
      operation: () async {
        final data = await _repository.getSalonDetail(salonId);

        if (data != null) {
          _salonDetail = data;
          _isFavourite = data.isFavourite ?? false;

          log('SalonDetailViewModel: Loaded salon: ${_salonDetail?.name}');
          log('SalonDetailViewModel: Favourite status: $_isFavourite');

          return data;
        } else {
          throw Exception('No salon data received');
        }
      },
    );
  }

  /// Update favourite status (for local state management)
  void updateFavouriteStatus(bool newStatus) {
    _isFavourite = newStatus;
    notifyListeners();
  }

  /// Clear salon detail data
  void clearSalonDetail() {
    _salonDetail = null;
    _isFavourite = false;
    setIdle();
  }
}
