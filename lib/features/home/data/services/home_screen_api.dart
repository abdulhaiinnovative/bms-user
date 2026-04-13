import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../models/HomePageResponse.dart';

class HomeScreenAPI {
  HomeScreenAPI();

  Future<HomePageResponse> fetchHomePageData() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/home-page'),
        headers: {'Content-Type': 'application/json'},
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
}
