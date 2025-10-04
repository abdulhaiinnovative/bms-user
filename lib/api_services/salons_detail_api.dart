import 'dart:developer';


import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/salon/SalonResponseData.dart';


class SalonsDetailAPI {
  static const String baseUrl = 'https://bms.innovativewidget.com/api';

  Future<SalonResponseData?> fetchSalonData(int salonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/salons/$salonId'));
      log('$baseUrl/salons/$salonId');

      if (response.statusCode == 200) {
        //log('SalonResponseData ${jsonDecode(response.body)}');

        SalonResponseData mm = SalonResponseData.fromJson(jsonDecode(response.body));
        log('SalonResponseData  ${mm.response!.data?.name}');

        return SalonResponseData.fromJson(jsonDecode(response.body));
      } else {
        log('ExceptionExceptionException');
        throw Exception('Failed to load salon data');
      }
    } catch (e) {
      log('ErrorErrorError');
      log('Error: $e');
      return null;
    }
  }
}