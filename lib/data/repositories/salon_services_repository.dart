import 'package:app/api_services/salon_services_categorized_api.dart';
import 'package:app/core/base/base_repository.dart';
import 'package:app/models/SalonServicesCategorizedResponse.dart';

/// Repository for fetching categorized salon services and deals
class SalonServicesRepository extends BaseRepository {
  final SalonServicesCategorizedAPI _api;

  SalonServicesRepository({SalonServicesCategorizedAPI? api})
      : _api = api ?? SalonServicesCategorizedAPI();

  /// Fetch categorized services and deals for a salon
  Future<SalonServicesCategorizedResponse?> getCategorizedServices(
      int salonId) async {
    return await execute(
      operation: () async {
        return await _api.fetchAllServicesAndDealsCategorizedData(salonId);
      },
    );
  }
}
