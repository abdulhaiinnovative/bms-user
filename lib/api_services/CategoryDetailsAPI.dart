import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category/CategoryResponseData.dart';
import 'dart:developer' as developer;

class CategoryDetailsAPI {
  static const String baseUrl = 'https://bms.innovativewidget.com/api';

  Future<CategoryResponseData?> fetchCategoryData(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-service-by-categories/$categoryId'));
      developer.log('API Response Status: ${response.statusCode}');
      developer.log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final categoryResponse = CategoryResponseData.fromJson(jsonData);
        developer.log('Parsed CategoryResponseData: ${categoryResponse.toJson()}');
        developer.log('CategoryDetailsData: ${categoryResponse.response?.data?.toJson()}');
        return categoryResponse;
      } else {
        developer.log('Failed to load category data: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching category data: $e\nStackTrace: $stackTrace');
      return null;
    }
  }
}