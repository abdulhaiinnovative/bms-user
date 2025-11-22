import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/top_salons_response.dart';

class TopSalonsApi {
  TopSalonsApi();

  /// Fetch top rated salons with pagination
  Future<TopSalonsResponse> fetchTopRatedSalons({
    required int page,
    int perPage = 10,
  }) async {
    try {
      // Using regular HTTP without authentication (public data)
      log('TopSalonsApi: Fetching top salons - Page: $page');

      final response = await http.get(
        Uri.parse('$BASE_URL/get-top-rated-salon?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        log('✅ TopSalonsApi: Success - Page $page');

        TopSalonsResponse topSalonsResponse =
            TopSalonsResponse.fromJson(jsonDecode(response.body));

        log('TopSalonsApi: Loaded ${topSalonsResponse.response.data.data.length} salons');
        log('TopSalonsApi: Current page ${topSalonsResponse.response.data.currentPage} of ${topSalonsResponse.response.data.lastPage}');

        return topSalonsResponse;
      } else {
        log('❌ TopSalonsApi: Failed to load - Status: ${response.statusCode}');
        throw Exception(
            'Failed to load top salons: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      log('❌ TopSalonsApi: Unexpected Error - $error');
      throw Exception('Failed to load top salons: $error');
    }
  }
}
