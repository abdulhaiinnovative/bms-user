import 'dart:convert';
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
      final response = await http.get(
        Uri.parse('$BASE_URL/get-top-rated-salon?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        TopSalonsResponse topSalonsResponse =
            TopSalonsResponse.fromJson(jsonDecode(response.body));

        return topSalonsResponse;
      } else {
        throw Exception(
            'Failed to load top salons: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load top salons: $error');
    }
  }
}
