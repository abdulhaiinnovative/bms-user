import 'dart:developer';
import 'dart:convert';
import 'package:app/services/protected_http_client.dart';
import '../models/salon/SalonResponseData.dart';

class SalonsDetailAPI {
  Future<SalonResponseData?> fetchSalonData(int salonId) async {
    try {
      log('SalonsDetailAPI: Fetching salon data for ID $salonId');

      final response = await ProtectedHttpClient.get('/salons/$salonId');

      if (response.statusCode == 200) {
        SalonResponseData salonData =
            SalonResponseData.fromJson(jsonDecode(response.body));
        log('✅ SalonsDetailAPI: ${salonData.response?.data?.name ?? "Unknown"}');
        return salonData;
      } else {
        log('❌ SalonsDetailAPI: Failed with status ${response.statusCode}');
        throw Exception('Failed to load salon data');
      }
    } on UnauthorizedException catch (e) {
      log('❌ SalonsDetailAPI: Unauthorized - $e');
      return null;
    } on ApiException catch (e) {
      log('❌ SalonsDetailAPI: API Error - $e');
      return null;
    } catch (e) {
      log('❌ SalonsDetailAPI: Error - $e');
      return null;
    }
  }
}
