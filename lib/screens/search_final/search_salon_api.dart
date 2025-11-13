import 'dart:convert';
import 'dart:developer';

import '../../models/HomePageResponse.dart';
import '../../services/protected_http_client.dart';

class SearchSalonApi {
  static const String baseUrl = '/search';

  static Future<Map<String, dynamic>> search({
    required String type,
    required String title,
    String? sortBy,
    String? sortOrder,
    int? categoryId,
    String? location,
    double? minRating,
    double? minPrice,
    double? maxPrice,
    String? gender,
    String? pageUrl,
  }) async {
    try {
      log('🔍 SearchSalonApi: Searching for $type with title: $title');

      final body = {
        'type': type,
        'title': title,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        if (type == 'service' || type == 'deal') ...{
          if (categoryId != null) 'category_id': categoryId,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
        },
        if (type == 'service' && gender != null) 'gender': gender,
        if (type == 'salon') ...{
          if (location != null) 'location': location,
          if (minRating != null) 'min_rating': minRating,
        },
      };

      // Use pageUrl if provided (for pagination), otherwise use base endpoint
      final endpoint = pageUrl != null
          ? pageUrl.replaceFirst('https://bms.innovativewidget.com/api', '')
          : baseUrl;

      final response = await ProtectedHttpClient.post(
        endpoint,
        body: body,
      );

      log('🔍 SearchSalonApi: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['response']['data'].isNotEmpty) {
          final result = data['response']['data'][0];

          if (type == 'service') {
            log('✅ SearchSalonApi: Found ${(result['data'] as List).length} services');
            return {
              'data': (result['data'] as List)
                  .map((json) => Service.fromJson(json))
                  .toList(),
              'nextPageUrl': result['next_page_url'],
            };
          } else if (type == 'salon') {
            log('✅ SearchSalonApi: Found ${(result['data'] as List).length} salons');
            return {
              'data': (result['data'] as List)
                  .map((json) => Salon.fromJson(json))
                  .toList(),
              'nextPageUrl': result['next_page_url'],
            };
          } else if (type == 'deal') {
            log('✅ SearchSalonApi: Found ${(result['data'] as List).length} deals');
            return {
              'data': (result['data'] as List)
                  .map((json) => Deal.fromJson(json))
                  .toList(),
              'nextPageUrl': result['next_page_url'],
            };
          } else {
            log('❌ SearchSalonApi: Invalid type: $type');
            throw Exception('Invalid type: $type');
          }
        } else {
          log('ℹ️ SearchSalonApi: No data found for $type');
          return {'data': [], 'nextPageUrl': null};
        }
      } else {
        log('❌ SearchSalonApi: Failed with status: ${response.statusCode}');
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } on UnauthorizedException catch (e) {
      log('❌ SearchSalonApi: UnauthorizedException - ${e.message}');
      throw Exception('Authentication required. Please login again.');
    } on ApiException catch (e) {
      log('❌ SearchSalonApi: ApiException - ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      log('❌ SearchSalonApi: Unexpected error - $e');
      throw Exception('An error occurred while searching: $e');
    }
  }
}
