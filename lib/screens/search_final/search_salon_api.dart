import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/HomePageResponse.dart';


class SearchSalonApi {
  static const String baseUrl = 'https://bms.innovativewidget.com/api/search';

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

    final response = await http.post(
      Uri.parse(pageUrl ?? baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['response']['data'].isNotEmpty) {
        final result = data['response']['data'][0];
        if (type == 'service') {
          return {
            'data': (result['data'] as List).map((json) => Service.fromJson(json)).toList(),
            'nextPageUrl': result['next_page_url'],
          };
        } else if (type == 'salon') {
          return {
            'data': (result['data'] as List).map((json) => Salon.fromJson(json)).toList(),
            'nextPageUrl': result['next_page_url'],
          };
        } else if (type == 'deal') {
          return {
            'data': (result['data'] as List).map((json) => Deal.fromJson(json)).toList(),
            'nextPageUrl': result['next_page_url'],
          };
        } else {
          throw Exception('Invalid type: $type');
        }
      } else {
        return {'data': [], 'nextPageUrl': null};
      }
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }
}