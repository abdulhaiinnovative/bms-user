import 'dart:developer';
import '../models/SalonServicesCategorizedResponse.dart';
import 'base_api_service.dart';

class SalonServicesCategorizedAPI {
  SalonServicesCategorizedAPI();

  Future<SalonServicesCategorizedResponse?>
      fetchAllServicesAndDealsCategorizedData(int salonId) async {
    try {
      log('SalonServicesCategorizedAPI: Fetching categorized services for salon $salonId');

      final response = await BaseApiService.post(
        '/categorized_services',
        data: {"salon_id": salonId},
        requiresAuth: true,
        logTag: 'SalonServicesCategorized',
      );

      if (response.statusCode == 200) {
        log('✅ SalonServicesCategorizedAPI: Data loaded successfully');
        return SalonServicesCategorizedResponse.fromJson(response.data);
      } else {
        log('❌ SalonServicesCategorizedAPI: Failed with status ${response.statusCode}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      log('❌ SalonServicesCategorizedAPI: Error - $error');
      throw Exception('Failed to load data: $error');
    }
  }
}
