import 'dart:developer' as developer;

import 'package:app/constants.dart';
import 'package:app/models/create_user/CreateUserResponse.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;



class CreateUserViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? result;

  static Future<CreateUserResponse?> createUser(
     String provider,
     String provider_id,
     String google_unique_id,
     String email,
     String device_id,
     String phone,
     String name,
     String first_name,
     String last_name,
     String image,
  ) async {
    String baseUrl = BASE_URL;
    // final url = 'https://bookmyspot.arca9.com/api/auth/social-login';
    String url = 'https://bms.innovativewidget.com/api/auth/social-login';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      "provider": provider,
      "provider_id": provider_id,
      "google_unique_id": google_unique_id,
      "email": email,
      "device_id": device_id,
      "phone": phone,
      "name": name,
      "first_name": first_name,
      "last_name": last_name,
      "image": image,
    });

    try {

      developer.log('===== url ===== ${url}');
      developer.log('===== headers ===== ${headers}');
      developer.log('===== body ===== ${body}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      developer.log('===== User created successfully =====   1');
      final jsonResponse = jsonDecode(response.body);
      developer.log('jsonResponse = $jsonResponse');
      developer.log('jsonResponse["response"] = ${jsonResponse["response"]}');
      developer.log('jsonResponse["response"]["data"] = ${jsonResponse["response"]?["data"]}');
      developer.log('jsonResponse["response"]["data"]["user"]["name"] = ${jsonResponse["response"]?["data"]["user"]["name"]}');

      return CreateUserResponse.fromJson(jsonResponse);

    } catch (e) {
      developer.log('Error CreateUserApi: $e');
    }
    return null;
  }



}