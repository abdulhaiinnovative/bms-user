import '../../core/base/base_repository.dart';
import '../../api_services/salon_detail_api.dart';

/// Repository for salon detail operations
class SalonDetailRepository extends BaseRepository {
  final SalonDetailAPI _salonDetailAPI;

  SalonDetailRepository({SalonDetailAPI? salonDetailAPI})
      : _salonDetailAPI = salonDetailAPI ?? SalonDetailAPI();

  /// Get salon detail data
  Future<dynamic> getSalonDetail(String salonId) async {
    return await execute(
      operation: () => _salonDetailAPI.fetchSalonDetailData(salonId),
      errorContext: 'Get salon detail',
    );
  }
}
