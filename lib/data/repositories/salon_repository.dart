import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/salon_detail_api.dart';

/// Repository for salon operations
class SalonRepository extends BaseRepository {
  final SalonDetailAPI _salonAPI;

  SalonRepository({SalonDetailAPI? salonAPI})
      : _salonAPI = salonAPI ?? SalonDetailAPI();

  /// Get salon details by ID
  Future<dynamic> getSalonDetails(String salonId) async {
    return await execute(
      operation: () => _salonAPI.fetchSalonDetailData(salonId),
      errorContext: 'Get salon details',
    );
  }
}
