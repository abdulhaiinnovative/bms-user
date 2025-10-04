import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../models/HomePageResponse.dart';
import '../models/SalonServicesCategorizedResponse.dart';

class SalonServicesCategorizedAPI {
  static const String baseURL = 'https://bms.innovativewidget.com/api';

  SalonServicesCategorizedAPI();

  Future<SalonServicesCategorizedResponse?> fetchAllServicesAndDealsCategorizedData(String accessToken, int salonId) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
        'Bearer $accessToken'
      };

      final request = http.Request(
        'POST',
        Uri.parse('$baseURL/categorized_services'),
      );
      request.body = json.encode({"salon_id": salonId});
      request.headers.addAll(headers);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        log('Response---------- $responseBody');

        return SalonServicesCategorizedResponse.fromJson(json.decode(responseBody));
      } else {
        log('Error---------- ${response.reasonPhrase}');
        throw Exception('Failed to load data---------- ${response.reasonPhrase}');
      }
    } catch (error) {
      log('Error---------- $error');
      throw Exception('Failed to load data---------- $error');
    }
  }
}