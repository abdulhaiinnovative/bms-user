import 'dart:convert';
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

      final response = await http.get(
        Uri.parse('$BASE_URL/get-deals?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        DealsResponse dealsResponse =
            DealsResponse.fromJson(jsonDecode(response.body));

        return dealsResponse;
      } else {
        throw Exception(
            'Failed to load deals: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load deals: $error');
    }
  }
}
