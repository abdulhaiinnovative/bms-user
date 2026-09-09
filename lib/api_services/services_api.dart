import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/services_response.dart';
import '../models/HomePageResponse.dart'; // For Service model
import '../models/SalonDetailApiResponse.dart' as sd; // For Review model

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

  /// Fetch a single service by ID
  Future<Service> fetchServiceById(int serviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/Service/$serviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // ✅ Correct extraction
        final serviceJson = jsonData['response']['data'];

        return Service.fromJson(serviceJson);
      } else {
        throw Exception(
            'Failed to load service: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load service: $error');
    }
  }

  /// Fetch reviews for a salon by salon ID
  /// Endpoint: GET /api/salons/{salonId}/reviews?page={page}
  Future<Map<String, dynamic>> fetchSalonReviews({
    required int salonId,
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/salons/$salonId/reviews?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );
      print("SALON REVIEWS: ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final paginatedData = jsonData['response']['data'];

        final List<sd.Review> reviews = (paginatedData['data'] as List? ?? [])
            .map((e) => sd.Review.fromJson(e))
            .toList();

        return {
          'reviews': reviews,
          'current_page': paginatedData['current_page'] ?? 1,
          'last_page': paginatedData['last_page'] ?? 1,
          'total': paginatedData['total'] ?? 0,
        };
      } else {
        throw Exception(
            'Failed to load reviews: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load reviews: $error');
    }
  }
}
