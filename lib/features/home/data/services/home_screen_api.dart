import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../models/HomePageResponse.dart';

import '../../../../features/auth/utils/auth_manager.dart';

class HomeScreenAPI {
  HomeScreenAPI();

  Future<HomePageResponse> fetchHomePageData() async {
    try {
      final headers = await AuthManager.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$BASE_URL/home-page'),
        headers: headers ?? {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        HomePageResponse homePageResponse =
            HomePageResponse.fromJson(jsonDecode(response.body));
        return homePageResponse;
      } else {
        throw Exception(
            'Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load data: $error');
    }
  }

  Future<void> trackSliderClickById(int id) async {
    print('Tracking slider click for ID: $id');
    try {
      final response = await http.get(
        Uri.parse('https://bms.innovativewidget.com/api/slide/$id/click'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Tracking API response: ${response.statusCode}');
      if (response.statusCode != 200) {
        // Log error but don't throw, as tracking shouldn't block the user action
        print('Failed to track slider click: ${response.statusCode}');
      }
    } catch (error) {
      // Log error but don't throw
      print('Error tracking slider click: $error');
    }
  }
}
