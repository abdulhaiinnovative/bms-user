#!/usr/bin/env dart

/// Script to fetch booking detail API and display the raw response
/// This helps identify the exact structure of the API response
///
/// Usage:
/// dart scripts/fetch_booking_detail.dart <booking_id> [auth_token]
///
/// Example:
/// dart scripts/fetch_booking_detail.dart 123 your_auth_token_here
///
/// Or run from VS Code terminal:
/// dart run scripts/fetch_booking_detail.dart 123

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart fetch_booking_detail.dart <booking_id> [auth_token]');
    print('Example: dart fetch_booking_detail.dart 123');
    exit(1);
  }

  final bookingId = args[0];
  final authToken = args.length > 1 ? args[1] : null;

  print('═══════════════════════════════════════════════════════');
  print('Fetching Booking Detail API');
  print('═══════════════════════════════════════════════════════');
  print('Booking ID: $bookingId');
  print(
      'API URL: https://bms.innovativewidget.com/api/booking-detail/$bookingId');
  print('');

  try {
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse(
          'https://bms.innovativewidget.com/api/booking-detail/$bookingId'),
    );

    // Add auth token if provided
    if (authToken != null) {
      request.headers.add('Authorization', 'Bearer $authToken');
      print('✓ Using provided auth token');
    } else {
      print(
          '⚠ No auth token provided - you may need to add one as second argument');
    }

    request.headers.add('Accept', 'application/json');
    request.headers.add('Content-Type', 'application/json');

    print('');
    print('Sending request...');
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print('');
    print('═══════════════════════════════════════════════════════');
    print('Response Status: ${response.statusCode}');
    print('═══════════════════════════════════════════════════════');
    print('');

    if (response.statusCode == 200) {
      print('✓ Success!');
      print('');

      // Parse and pretty print JSON
      final jsonData = jsonDecode(responseBody);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);

      print('Full Response:');
      print('─────────────────────────────────────────────────────');
      print(prettyJson);
      print('');

      // Check for services and staff data
      if (jsonData['response']?['data']?['services'] != null) {
        print('');
        print('═══════════════════════════════════════════════════════');
        print('Services Data Analysis:');
        print('═══════════════════════════════════════════════════════');

        final services = jsonData['response']['data']['services'] as List;
        for (var i = 0; i < services.length; i++) {
          final service = services[i];
          print('');
          print('Service ${i + 1}:');
          print('  Name: ${service['name']}');
          print('  Has "staff" field: ${service.containsKey('staff')}');
          print(
              '  Has "selected_professional" field: ${service.containsKey('selected_professional')}');

          if (service.containsKey('staff') && service['staff'] != null) {
            print('  Staff Data:');
            print(
                '    ${const JsonEncoder.withIndent('    ').convert(service['staff'])}');
          }

          if (service.containsKey('selected_professional') &&
              service['selected_professional'] != null) {
            print('  Selected Professional Data:');
            print(
                '    ${const JsonEncoder.withIndent('    ').convert(service['selected_professional'])}');
          }

          if (!service.containsKey('staff') &&
              !service.containsKey('selected_professional')) {
            print('  ⚠ No staff/professional data found!');
          }
        }
      } else {
        print('');
        print('⚠ No services data found in response');
      }

      print('');
      print('═══════════════════════════════════════════════════════');
      print('Model Generation Recommendation:');
      print('═══════════════════════════════════════════════════════');
      print(
          'Based on the response, update your BookingService model to parse:');

      if (jsonData['response']?['data']?['services'] != null) {
        final services = jsonData['response']['data']['services'] as List;
        if (services.isNotEmpty) {
          final firstService = services.first;
          if (firstService.containsKey('staff')) {
            print('✓ Use "staff" field for professional data');
          } else if (firstService.containsKey('selected_professional')) {
            print('✓ Use "selected_professional" field for professional data');
          } else {
            print('⚠ Professional field not found - check API response');
          }
        }
      }
    } else {
      print('✗ Failed with status code: ${response.statusCode}');
      print('');
      print('Response Body:');
      print(responseBody);
    }

    client.close();
  } catch (e, stackTrace) {
    print('');
    print('✗ Error occurred:');
    print(e);
    print('');
    print('Stack trace:');
    print(stackTrace);
    exit(1);
  }

  print('');
  print('═══════════════════════════════════════════════════════');
  print('Script completed');
  print('═══════════════════════════════════════════════════════');
}
