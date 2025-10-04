import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:app/models/SearchSalonResponse.dart';
import 'package:app/models/ServiceMain.dart';

import '../models/SearchServiceResponse.dart';

Future<List<ServiceMain>> searchServiceAPI({required String salon, required String service}) async {
  //const String url = 'https://bookmyspot.arca9.com/api/salons/search?page=1';
  const String url = 'https://bms.innovativewidget.com/api/salons/search?page=1';


  // String baseURL = 'https://bms.innovativewidget.com/api';
  final Map<String, dynamic> body = {
    "salon": salon,
    "service": service,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final searchResponse = SearchServiceResponse.fromJson(jsonDecode(response.body));

      if (searchResponse.status) {
        final services = searchResponse.response.data.services;

        if (services.isNotEmpty) {
          log('services = ${services.length}');
          return services;
        } else {
          log('No salons found.');
          return [];
        }
      } else {
        log('Error: ${searchResponse.message}');
        return [];
      }
    } else {
      log('Failed to load data. Status Code: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    log('Error:: $e');
    return [];
  }
}