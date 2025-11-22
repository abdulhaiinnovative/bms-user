import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/services_response.dart';

class ServicesApi {
  ServicesApi();

  /// Fetch women's services with pagination
  Future<ServicesResponse> fetchWomenServices({
    required int page,
    int perPage = 10,
  }) async {
    try {
      // Using regular HTTP without authentication (public data)
      log('ServicesApi: Fetching women services - Page: $page');

      final response = await http.get(
        Uri.parse('$BASE_URL/get-women-service?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        log('✅ ServicesApi: Success (Women) - Page $page');

        ServicesResponse servicesResponse =
            ServicesResponse.fromJson(jsonDecode(response.body));

        log('ServicesApi: Loaded ${servicesResponse.response.data.data.length} women services');
        log('ServicesApi: Current page ${servicesResponse.response.data.currentPage} of ${servicesResponse.response.data.lastPage}');

        return servicesResponse;
      } else {
        log('❌ ServicesApi: Failed to load women services - Status: ${response.statusCode}');
        throw Exception(
            'Failed to load women services: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      log('❌ ServicesApi: Unexpected Error (Women) - $error');
      throw Exception('Failed to load women services: $error');
    }
  }

  /// Fetch men's services with pagination
  Future<ServicesResponse> fetchMenServices({
    required int page,
    int perPage = 10,
  }) async {
    try {
      // Using regular HTTP without authentication (public data)
      log('ServicesApi: Fetching men services - Page: $page');

      final response = await http.get(
        Uri.parse('$BASE_URL/get-men-service?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        log('✅ ServicesApi: Success (Men) - Page $page');

        ServicesResponse servicesResponse =
            ServicesResponse.fromJson(jsonDecode(response.body));

        log('ServicesApi: Loaded ${servicesResponse.response.data.data.length} men services');
        log('ServicesApi: Current page ${servicesResponse.response.data.currentPage} of ${servicesResponse.response.data.lastPage}');

        return servicesResponse;
      } else {
        log('❌ ServicesApi: Failed to load men services - Status: ${response.statusCode}');
        throw Exception(
            'Failed to load men services: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      log('❌ ServicesApi: Unexpected Error (Men) - $error');
      throw Exception('Failed to load men services: $error');
    }
  }
}
