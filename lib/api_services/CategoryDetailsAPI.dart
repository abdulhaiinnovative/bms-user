import 'dart:convert';
import 'package:app/services/protected_http_client.dart';
import '../models/category/CategoryResponseData.dart';
import 'dart:developer' as developer;

class CategoryDetailsAPI {
  Future<CategoryResponseData?> fetchCategoryData(int categoryId) async {
    try {
      developer.log(
          'CategoryDetailsAPI: Fetching services for category $categoryId');

      final response = await ProtectedHttpClient.get(
          '/get-service-by-categories/$categoryId');

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
    } on UnauthorizedException catch (e) {
      developer.log('❌ CategoryDetailsAPI: Unauthorized - $e');
      return null;
    } on ApiException catch (e) {
      developer.log('❌ CategoryDetailsAPI: API Error - $e');
      return null;
    } catch (e, stackTrace) {
      developer.log(
          '❌ CategoryDetailsAPI: Unexpected error - $e\nStackTrace: $stackTrace');
      return null;
    }
  }
}
