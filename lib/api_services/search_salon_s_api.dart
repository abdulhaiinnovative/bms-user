import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;


import '../models/search/SalonResponse.dart';
import '../models/search/ServiceResponse.dart';
import '../models/search/DealResponse.dart';

class SearchSalonSApi {

  Future<SalonResponse> searchSalons(String query, {int page = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('https://bms.innovativewidget.com/api/salons/search?page=$page'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'salon': query}),
      );

      log('========');

      if (response.statusCode == 200) {

        log('=====*statusCode*=== ${response.statusCode}');
        log('=====*body*=== ${SalonResponse.fromJson(jsonDecode(response.body)).response?.data?.salons?.data?.length}');
        log('=====*body*=== ${SalonResponse.fromJson(jsonDecode(response.body)).response?.data?.salons?.data}');
        log('=====*body*=== ${SalonResponse.fromJson(jsonDecode(response.body)).response?.data?.salons?.data?[0].name}');

        return SalonResponse.fromJson(jsonDecode(response.body));
      }
      log('Failed to search salons: ${response.statusCode}');
      throw Exception('Failed to search salons: ${response.statusCode}');
    } catch (e) {
      log('Exception to search salons: ${e}');
      throw Exception('Error searching salons: $e');
    }
  }


  Future<ServiceResponse> searchService(String query, {int page = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('https://bms.innovativewidget.com/api/salons/search?page=$page'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'service': query}),
      );

      log('========');

      if (response.statusCode == 200) {

        log('=====*statusCode*=== ${response.statusCode}');
        log('=====*body*=== ${ServiceResponse.fromJson(jsonDecode(response.body)).response?.data?.services?.data?.length}');
        log('=====*body*=== ${ServiceResponse.fromJson(jsonDecode(response.body)).response?.data?.services?.data}');
        log('=====*body*=== ${ServiceResponse.fromJson(jsonDecode(response.body)).response?.data?.services?.data?[0].name}');

        return ServiceResponse.fromJson(jsonDecode(response.body));
      }

      log('Failed to search salons: ${response.statusCode}');
      throw Exception('Failed to search salons: ${response.statusCode}');
    } catch (e) {
      log('Exception to search salons: ${e}');
      throw Exception('Error searching salons: $e');
    }
  }


  Future<DealResponse> searchDeal(String query, {int page = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('https://bms.innovativewidget.com/api/salons/search?page=$page'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deal': query}),
      );

      log('========');

      if (response.statusCode == 200) {

        log('=====*statusCode*=== ${response.statusCode}');
        log('=====*body*=== ${DealResponse.fromJson(jsonDecode(response.body)).response?.data?.deals?.data?.length}');
        log('=====*body*=== ${DealResponse.fromJson(jsonDecode(response.body)).response?.data?.deals?.data}');
        log('=====*body*=== ${DealResponse.fromJson(jsonDecode(response.body)).response?.data?.deals?.data?[0].name}');

        return DealResponse.fromJson(jsonDecode(response.body));
      }
      log('Failed to search salons: ${response.statusCode}');
      throw Exception('Failed to search salons: ${response.statusCode}');
    } catch (e) {
      log('Exception to search salons: ${e}');
      throw Exception('Error searching salons: $e');
    }
  }


}