import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../models/search/SalonResponse.dart';
import '../models/search/ServiceResponse.dart';
import '../models/search/DealResponse.dart';

class SearchSalonSApi {
  Future<SalonResponse> searchSalons(String query, {int page = 1}) async {
    try {
      log('SearchSalonSApi: Searching salons with query="$query", page=$page');

      final response = await ProtectedHttpClient.post(
        '/salons/search?page=$page',
        body: {'salon': query},
        additionalHeaders: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final salonResponse = SalonResponse.fromJson(jsonDecode(response.body));
        log('✅ SearchSalonSApi: Found ${salonResponse.response?.data?.salons?.data?.length ?? 0} salons');
        return salonResponse;
      }

      log('❌ SearchSalonSApi: Failed with status ${response.statusCode}');
      throw Exception('Failed to search salons: ${response.statusCode}');
    } on UnauthorizedException catch (e) {
      log('❌ SearchSalonSApi: Unauthorized - $e');
      throw Exception('Session expired. Please login again.');
    } on ApiException catch (e) {
      log('❌ SearchSalonSApi: API Error - $e');
      throw Exception('Error searching salons: $e');
    } catch (e) {
      log('❌ SearchSalonSApi: Unexpected error - $e');
      throw Exception('Error searching salons: $e');
    }
  }

  Future<ServiceResponse> searchService(String query, {int page = 1}) async {
    try {
      log('SearchSalonSApi: Searching services with query="$query", page=$page');

      final response = await ProtectedHttpClient.post(
        '/salons/search?page=$page',
        body: {'service': query},
        additionalHeaders: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final serviceResponse =
            ServiceResponse.fromJson(jsonDecode(response.body));
        log('✅ SearchSalonSApi: Found ${serviceResponse.response?.data?.services?.data?.length ?? 0} services');
        return serviceResponse;
      }

      log('❌ SearchSalonSApi: Failed with status ${response.statusCode}');
      throw Exception('Failed to search services: ${response.statusCode}');
    } on UnauthorizedException catch (e) {
      log('❌ SearchSalonSApi: Unauthorized - $e');
      throw Exception('Session expired. Please login again.');
    } on ApiException catch (e) {
      log('❌ SearchSalonSApi: API Error - $e');
      throw Exception('Error searching services: $e');
    } catch (e) {
      log('❌ SearchSalonSApi: Unexpected error - $e');
      throw Exception('Error searching services: $e');
    }
  }

  Future<DealResponse> searchDeal(String query, {int page = 1}) async {
    try {
      log('SearchSalonSApi: Searching deals with query="$query", page=$page');

      final response = await ProtectedHttpClient.post(
        '/salons/search?page=$page',
        body: {'deal': query},
        additionalHeaders: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dealResponse = DealResponse.fromJson(jsonDecode(response.body));
        log('✅ SearchSalonSApi: Found ${dealResponse.response?.data?.deals?.data?.length ?? 0} deals');
        return dealResponse;
      }

      log('❌ SearchSalonSApi: Failed with status ${response.statusCode}');
      throw Exception('Failed to search deals: ${response.statusCode}');
    } on UnauthorizedException catch (e) {
      log('❌ SearchSalonSApi: Unauthorized - $e');
      throw Exception('Session expired. Please login again.');
    } on ApiException catch (e) {
      log('❌ SearchSalonSApi: API Error - $e');
      throw Exception('Error searching deals: $e');
    } catch (e) {
      log('❌ SearchSalonSApi: Unexpected error - $e');
      throw Exception('Error searching deals: $e');
    }
  }
}
