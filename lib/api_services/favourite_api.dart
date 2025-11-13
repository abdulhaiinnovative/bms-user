import 'dart:convert';
import 'dart:developer';
import 'package:app/services/protected_http_client.dart';

// TODO: FAVOURITES API - Add/Remove items from favourites
// This service handles favourite toggle functionality for salons and services
// Endpoint: POST /salons/add-to-favourites
// Phase 2: Will support both salon and service favourites
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
    try {
      log('FavouriteAPI: Toggling favourite for $shareType ID: $shareId');

      final body = {
        'share_id': shareId,
        'share_type': shareType,
      };

      final response = await ProtectedHttpClient.post(
        '/salons/add-to-favourites',
        body: body,
      );

      log('✅ FavouriteAPI: Response status ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          final isFavourite =
              responseData['response']?['data']?['is_favourite'] ?? false;
          final message = responseData['message'] ?? 'Success';

          log('✅ FavouriteAPI: $message - isFavourite=$isFavourite');

          return {
            'success': true,
            'isFavourite': isFavourite,
            'message': message,
          };
        } else {
          log('❌ FavouriteAPI: ${responseData['message']}');
          return {
            'success': false,
            'isFavourite': false,
            'message': responseData['message'] ?? 'Failed to update favourite',
          };
        }
      } else {
        log('❌ FavouriteAPI: Unexpected status ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'isFavourite': false,
          'message': errorData['message'] ?? 'Failed to update favourite',
        };
      }
    } on UnauthorizedException catch (e) {
      log('❌ FavouriteAPI: Unauthorized - $e');
      return {
        'success': false,
        'isFavourite': false,
        'message': 'Please login again',
      };
    } on ApiException catch (e) {
      log('❌ FavouriteAPI: API Error - $e');
      return {
        'success': false,
        'isFavourite': false,
        'message': 'Failed to update favourite',
      };
    } catch (e) {
      log('❌ FavouriteAPI: Exception - $e');
      return {
        'success': false,
        'isFavourite': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // TODO: FAVOURITES API - Get user's favourites list
  // Endpoint: POST /salons/favourite
  // Returns paginated list of favourite salons
  /// Get list of favourites
  Future<Map<String, dynamic>> getFavouritesList({int page = 1}) async {
    try {
      log('FavouriteAPI: Fetching favourites list for page $page');

      final response =
          await ProtectedHttpClient.post('/salons/favourite?page=$page');

      log('✅ FavouriteAPI: Response status ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          log('✅ FavouriteAPI: Success - Total favourites: ${responseData['response']?['data']?['total'] ?? 0}');

          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Success',
          };
        } else {
          log('❌ FavouriteAPI: ${responseData['message']}');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch favourites',
          };
        }
      } else {
        log('❌ FavouriteAPI: Unexpected status ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch favourites',
        };
      }
    } on UnauthorizedException catch (e) {
      log('❌ FavouriteAPI: Unauthorized - $e');
      return {
        'success': false,
        'message': 'Please login again',
      };
    } on ApiException catch (e) {
      log('❌ FavouriteAPI: API Error - $e');
      return {
        'success': false,
        'message': 'Failed to fetch favourites',
      };
    } catch (e) {
      log('❌ FavouriteAPI: Exception - $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
