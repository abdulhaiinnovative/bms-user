import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

/// Quick script to extract auth token from SharedPreferences
/// Usage: dart run scripts/get_auth_token.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('═══════════════════════════════════════════════════════');
    print('Getting Auth Token from SharedPreferences');
    print('═══════════════════════════════════════════════════════');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      print('\n✓ Auth Token Found:');
      print('─────────────────────────────────────────────────────');
      print(token);
      print('─────────────────────────────────────────────────────');
      print('\nYou can now use this token with the fetch script:');
      print('dart run scripts/fetch_booking_detail.dart <booking_id> $token');
    } else {
      print('\n✗ No auth token found in SharedPreferences');
      print('\nPossible reasons:');
      print('  1. User is not logged in');
      print('  2. This script needs to run in app context');
      print('\nAlternative: Add debug logging in the app:');
      print('  - In auth_manager.dart, log the token after login');
      print('  - Check app logs after successful login');
    }

    print('\n═══════════════════════════════════════════════════════');
  } catch (e) {
    print('Error: $e');
    print('\nNote: This script might not work outside the app context.');
    print('Try adding debug logging in auth_manager.dart instead:');
    print('  print("Auth Token: \${prefs.getString(_tokenKey)}");');
  }
}
