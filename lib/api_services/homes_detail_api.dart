import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import '../models/home/HomeApiResponse.dart';

class HomesDetailAPI {
  Future<HomeApiResponse?> fetchHomePageData() async {
    try {
      log('HomesDetailAPI: Fetching home page data');

      final response = await ProtectedHttpClient.get('/home-page');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('✅ HomesDetailAPI: Data loaded successfully');
        return HomeApiResponse.fromJson(jsonData);
      } else {
        log('❌ HomesDetailAPI: Failed with status ${response.statusCode}');
        return null;
      }
    } on UnauthorizedException catch (e) {
      log('❌ HomesDetailAPI: Unauthorized - $e');
      return null;
    } on ApiException catch (e) {
      log('❌ HomesDetailAPI: API Error - $e');
      return null;
    } catch (e) {
      log('❌ HomesDetailAPI: Error - $e');
      return null;
    }
  }
}
