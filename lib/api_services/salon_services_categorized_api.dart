import 'dart:convert';
import '../models/SalonServicesCategorizedResponse.dart';
import 'base_api_service.dart';

class SalonServicesCategorizedAPI {
  SalonServicesCategorizedAPI();

  Future<SalonServicesCategorizedResponse?>
      fetchAllServicesAndDealsCategorizedData(int salonId) async {
    try {
      final response = await BaseApiService.post(
        '/categorized_services',
        data: {"salon_id": salonId},
        requiresAuth: true, // Server requires authentication for this endpoint
        logTag: 'SalonServicesCategorized',
      );

      print('');
      print('📥 Response received:');
      print('   ├─ Status Code: ${response.statusCode}');
      print('   └─ Raw JSON Response:');
      print('      ${jsonEncode(response.data)}');
      print('');

      if (response.statusCode == 200) {
        final parsedResponse =
            SalonServicesCategorizedResponse.fromJson(response.data);
        return parsedResponse;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load data: $error');
    }
  }
}
