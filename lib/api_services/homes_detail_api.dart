

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home/HomeApiResponse.dart';


class HomesDetailAPI {
  static const String baseUrl = 'https://bms.innovativewidget.com/api/home-page';

  Future<HomeApiResponse?> fetchHomePageData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return HomeApiResponse.fromJson(jsonData);
      } else {
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }
}