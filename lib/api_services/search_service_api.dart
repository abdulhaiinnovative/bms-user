import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';
import 'package:app/models/ServiceMain.dart';
import '../models/SearchServiceResponse.dart';

Future<List<ServiceMain>> searchServiceAPI(
    {required String salon, required String service}) async {
  final Map<String, dynamic> body = {
    "salon": salon,
    "service": service,
  };

  try {
    log('SearchServiceAPI: Searching for salon="$salon", service="$service"');

    final response = await ProtectedHttpClient.post(
      '/salons/search?page=1',
      body: body,
      additionalHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final searchResponse =
          SearchServiceResponse.fromJson(jsonDecode(response.body));

      if (searchResponse.status) {
        final services = searchResponse.response.data.services;

        if (services.isNotEmpty) {
          log('✅ SearchServiceAPI: Found ${services.length} services');
          return services;
        } else {
          log('⚠️ SearchServiceAPI: No services found');
          return [];
        }
      } else {
        log('❌ SearchServiceAPI: Error - ${searchResponse.message}');
        return [];
      }
    } else {
      log('❌ SearchServiceAPI: Unexpected status code ${response.statusCode}');
      return [];
    }
  } on UnauthorizedException catch (e) {
    log('❌ SearchServiceAPI: Unauthorized - $e');
    throw Exception('Session expired. Please login again.');
  } on ApiException catch (e) {
    log('❌ SearchServiceAPI: API Error - $e');
    return [];
  } catch (e) {
    log('❌ SearchServiceAPI: Unexpected error - $e');
    return [];
  }
}
