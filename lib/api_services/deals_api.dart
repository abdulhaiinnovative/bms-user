import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/deals_response.dart';

class DealsApi {
  DealsApi();

  /// Fetch deals with pagination
  Future<DealsResponse> fetchDeals({
    required int page,
    int perPage = 10,
  }) async {
    try {
      // Using regular HTTP without authentication (public data)
      log('DealsApi: Fetching deals - Page: $page');

      final response = await http.get(
        Uri.parse('$BASE_URL/get-deals?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        log('✅ DealsApi: Success - Page $page');

        DealsResponse dealsResponse =
            DealsResponse.fromJson(jsonDecode(response.body));

        log('DealsApi: Loaded ${dealsResponse.response.data.data.length} deals');
        log('DealsApi: Current page ${dealsResponse.response.data.currentPage} of ${dealsResponse.response.data.lastPage}');

        return dealsResponse;
      } else {
        log('❌ DealsApi: Failed to load - Status: ${response.statusCode}');
        throw Exception(
            'Failed to load deals: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      log('❌ DealsApi: Unexpected Error - $error');
      throw Exception('Failed to load deals: $error');
    }
  }
}
