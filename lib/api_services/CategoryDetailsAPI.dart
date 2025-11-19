import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';
import '../models/category/CategoryResponseData.dart';
import 'dart:developer' as developer;

class CategoryDetailsAPI {
  Future<CategoryResponseData?> fetchCategoryData(int categoryId) async {
    try {
      developer.log(
          'CategoryDetailsAPI: Fetching services for category $categoryId');

      final response = await http.get(
        Uri.parse('$BASE_URL/get-service-by-categories/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log(
          '✅ CategoryDetailsAPI: Response received with status ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final categoryResponse = CategoryResponseData.fromJson(jsonData);
        developer
            .log('✅ CategoryDetailsAPI: Parsed category data successfully');
        return categoryResponse;
      } else {
        developer.log(
            '❌ CategoryDetailsAPI: Unexpected status ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(
          '❌ CategoryDetailsAPI: Unexpected error - $e\nStackTrace: $stackTrace');
      return null;
    }
  }
}
