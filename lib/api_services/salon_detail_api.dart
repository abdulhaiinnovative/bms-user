import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../models/SalonDetailApiResponse.dart';

class SalonDetailAPI {
  SalonDetailAPI();

  Future<SalonData?> fetchSalonDetailData(String salonId) async {
    try {
      // Using ProtectedHttpClient with authentication required
      log('SalonDetailAPI: Fetching salon details for ID: $salonId');

      final response = await ProtectedHttpClient.get('/salons/$salonId');

      if (response.statusCode == 200) {
        final apiResponse =
            SalonDetailApiResponse.fromJson(jsonDecode(response.body));

        SalonData? salonDetails = apiResponse.response.data;

        log('SalonDetailAPI Name::: ${salonDetails.name}');
        log('SalonDetailAPI 0001--- ${apiResponse.response.data.sections?[0].name}');
        log('SalonDetailAPI 0002--- ${apiResponse.response.data.sections?[0].type}');
        log('SalonDetailAPI 0003--- ${apiResponse.response.data.sections?[0].data}');

        return salonDetails;
      } else {
        log('❌ SalonDetailAPI: Unexpected status code ${response.statusCode}');
        return null;
      }
    } on UnauthorizedException catch (e) {
      log('❌ SalonDetailAPI: Unauthorized - $e');
      throw Exception('Session expired. Please login again.');
    } on ApiException catch (e) {
      log('❌ SalonDetailAPI: API Error - $e');
      throw Exception('Failed to load salon details: $e');
    } catch (error) {
      log('❌ SalonDetailAPI: Unexpected error - $error');
      throw Exception('Failed to load salon details: $error');
    }
  }
}
