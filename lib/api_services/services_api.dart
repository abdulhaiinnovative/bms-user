import 'dart:convert';
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
      final response = await http.get(
        Uri.parse('$BASE_URL/get-women-service?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ServicesResponse servicesResponse =
            ServicesResponse.fromJson(jsonDecode(response.body));

        return servicesResponse;
      } else {
        throw Exception(
            'Failed to load women services: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load women services: $error');
    }
  }

  /// Fetch men's services with pagination
  Future<ServicesResponse> fetchMenServices({
    required int page,
    int perPage = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/get-men-service?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ServicesResponse servicesResponse =
            ServicesResponse.fromJson(jsonDecode(response.body));

        return servicesResponse;
      } else {
        throw Exception(
            'Failed to load men services: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load men services: $error');
    }
  }
}
