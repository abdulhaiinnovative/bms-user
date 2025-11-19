import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';
import '../models/SalonServicesCategorizedResponse.dart';

class SalonServicesCategorizedAPI {
  SalonServicesCategorizedAPI();

  Future<SalonServicesCategorizedResponse?>
      fetchAllServicesAndDealsCategorizedData(int salonId) async {
    try {
      log('SalonServicesCategorizedAPI: Fetching categorized services for salon $salonId');

      final response = await http.post(
        Uri.parse('$BASE_URL/categorized_services'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"salon_id": salonId}),
      );

      if (response.statusCode == 200) {
        log('✅ SalonServicesCategorizedAPI: Data loaded successfully');
        return SalonServicesCategorizedResponse.fromJson(
            json.decode(response.body));
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
