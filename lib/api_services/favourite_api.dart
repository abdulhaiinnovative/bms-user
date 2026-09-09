import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/constants.dart';
import '../features/auth/utils/auth_manager.dart';

// TODO: FAVOURITES API - Add/Remove items from favourites
// This service handles favourite toggle functionality for salons and services
// Endpoint: POST /salons/add-to-favourites
// Phase 2: Will support both salon and service favourites
// Now supports both authenticated and guest users
class FavouriteAPI {
  /// Add or remove item from favourites
  ///
  /// Parameters:
  /// - shareId: The ID of the item (salon_id or service_id)
  /// - shareType: Type of item - "salon" or "service"
  ///
  /// Returns: Map with 'isFavourite' boolean indicating the new state
  Future<Map<String, dynamic>> toggleFavourite({
    required String shareId,
    required String shareType,
  }) async {
    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('❤️  TOGGLE FAVOURITE API CALL');
    print('═══════════════════════════════════════════════════════════════');
    print('📍 Endpoint: POST /salons/add-to-favourites');
    print('📦 Request Parameters:');
    print('   ├─ share_id: $shareId');
    print('   ├─ share_type: $shareType');
    print('   └─ timestamp: ${DateTime.now().toIso8601String()}');
    
    // Check if user is authenticated
    final token = await AuthManager.getToken();
    final isAuthenticated = token != null && token.isNotEmpty;
    
    print('');
    print('🔐 Authentication Status: ${isAuthenticated ? "Authenticated ✅" : "Guest 👤"}');
    if (isAuthenticated) {
      print('🎫 Token: ${token.substring(0, 20)}...');
    }
    print('');

    try {
      final body = {
        'share_id': shareId,
        'share_type': shareType,
      };

      // Build headers - add Authorization if authenticated
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (isAuthenticated) 'Authorization': 'Bearer $token',
      };

      print('📤 Request Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('   ├─ $key: Bearer ${value.toString().substring(7, 27)}...');
        } else {
          print('   ├─ $key: $value');
        }
      });
      print('');
      print('📤 Sending request...');

      final response = await http.post(
        Uri.parse('$BASE_URL/salons/add-to-favourites'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Response received:');
      print('   ├─ Status Code: ${response.statusCode}');
      print('   ├─ Body Length: ${response.body.length} bytes');
      print('   └─ Raw Response:');
      print('      ${response.body}');
      print('');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('✅ Response parsed successfully');
        print('📊 Response Structure:');
        print('   ├─ status: ${responseData['status']}');
        print('   ├─ message: ${responseData['message']}');
        print('   └─ response.data: ${responseData['response']?['data']}');
        print('');

        if (responseData['status'] == true) {
          final isFavourite =
              responseData['response']?['data']?['is_favourite'] ?? false;
          final message = responseData['message'] ?? 'Success';

          print('✅ SUCCESS - Favourite toggled');
          print('📊 Result:');
          print('   ├─ is_favourite: $isFavourite');
          print('   ├─ message: $message');
          print(
              '   └─ action: ${isFavourite ? "Added to favourites ❤️" : "Removed from favourites 💔"}');
          print(
              '═══════════════════════════════════════════════════════════════');
          print('');

          return {
            'success': true,
            'isFavourite': isFavourite,
            'message': message,
          };
        } else {
          print('❌ API returned status: false');
          print('📊 Error Details:');
          print('   ├─ message: ${responseData['message']}');
          print('   └─ full response: $responseData');
          print(
              '═══════════════════════════════════════════════════════════════');
          print('');

          return {
            'success': false,
            'isFavourite': false,
            'message': responseData['message'] ?? 'Failed to update favourite',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);

        print('❌ HTTP Error - Status: ${response.statusCode}');
        print('📊 Error Response:');
        print('   ├─ message: ${errorData['message']}');
        print('   └─ full error: $errorData');
        print(
            '═══════════════════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'isFavourite': false,
          'message': errorData['message'] ?? 'Failed to update favourite',
        };
      }
    } catch (e) {
      print('');
      print('💥 UNEXPECTED EXCEPTION');
      print('📊 Error Type: ${e.runtimeType}');
      print('📊 Error Message: $e');
      print('📊 Stack Trace:');
      print(StackTrace.current);
      print('═══════════════════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'isFavourite': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> getFavouritesList({int page = 1}) async {
    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('📋 GET FAVOURITES LIST');
    print('═══════════════════════════════════════════════════════════════');
    print('📍 Endpoint: POST /salons/favourite?page=$page');
    
    // Check if user is authenticated
    final token = await AuthManager.getToken();
    final isAuthenticated = token != null && token.isNotEmpty;
    
    print('🔐 Authentication Status: ${isAuthenticated ? "Authenticated ✅" : "Guest 👤"}');
    if (isAuthenticated) {
      print('🎫 Token: ${token.substring(0, 20)}...');
    }
    print('');

    try {
      // Build headers - add Authorization if authenticated
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (isAuthenticated) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$BASE_URL/salons/favourite?page=$page'),
        headers: headers,
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          print('✅ SUCCESS - Favourites fetched');
          print('═══════════════════════════════════════════════════════════════');
          print('');
          
          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Success',
          };
        } else {
          print('❌ API returned status: false');
          print('═══════════════════════════════════════════════════════════════');
          print('');
          
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch favourites',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        
        print('❌ HTTP Error - Status: ${response.statusCode}');
        print('═══════════════════════════════════════════════════════════════');
        print('');
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch favourites',
        };
      }
    } catch (e) {
      print('');
      print('💥 EXCEPTION IN GET FAVOURITES');
      print('📊 Error: $e');
      print('═══════════════════════════════════════════════════════════════');
      print('');
      
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
