import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../utlis/authutils/auth_manager.dart';
import '../constants.dart';

/// Protected HTTP Client - Automatically adds authentication token to all requests
/// Use this for all API calls that require authentication
class ProtectedHttpClient {
  /// GET request with automatic token injection
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      additionalHeaders: additionalHeaders,
      requiresAuth: requiresAuth,
    );

    final url = _buildUrl(endpoint);
    log('🌐 GET Request: $url');
    log('🔑 Requires Auth: $requiresAuth');

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      await _handleResponse(response, url);
      return response;
    } catch (e) {
      log('❌ GET Request Failed: $e');
      rethrow;
    }
  }

  /// POST request with automatic token injection
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      additionalHeaders: additionalHeaders,
      requiresAuth: requiresAuth,
    );

    final url = _buildUrl(endpoint);
    log('🌐 POST Request: $url');
    log('🔑 Requires Auth: $requiresAuth');
    if (body != null) {
      log('📦 Request Body: $body');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleResponse(response, url);
      return response;
    } catch (e) {
      log('❌ POST Request Failed: $e');
      rethrow;
    }
  }

  /// PUT request with automatic token injection
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      additionalHeaders: additionalHeaders,
      requiresAuth: requiresAuth,
    );

    final url = _buildUrl(endpoint);
    log('🌐 PUT Request: $url');
    log('🔑 Requires Auth: $requiresAuth');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleResponse(response, url);
      return response;
    } catch (e) {
      log('❌ PUT Request Failed: $e');
      rethrow;
    }
  }

  /// DELETE request with automatic token injection
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? additionalHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      additionalHeaders: additionalHeaders,
      requiresAuth: requiresAuth,
    );

    final url = _buildUrl(endpoint);
    log('🌐 DELETE Request: $url');
    log('🔑 Requires Auth: $requiresAuth');

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      await _handleResponse(response, url);
      return response;
    } catch (e) {
      log('❌ DELETE Request Failed: $e');
      rethrow;
    }
  }

  /// Build headers with authentication token
  static Future<Map<String, String>> _buildHeaders({
    Map<String, String>? additionalHeaders,
    required bool requiresAuth,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add additional headers if provided
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    // Add authentication token if required
    if (requiresAuth) {
      final token = await AuthManager.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        log('✅ Auth token added to request');
      } else {
        log('⚠️ No auth token found - Request may fail');
        throw UnauthorizedException('No authentication token found');
      }
    }

    return headers;
  }

  /// Build full URL from endpoint
  static String _buildUrl(String endpoint) {
    // If endpoint already starts with http, return as is
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }

    // Remove leading slash if present
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    return '$BASE_URL/$cleanEndpoint';
  }

  /// Handle response and check for auth errors
  static Future<void> _handleResponse(
      http.Response response, String url) async {
    log('📥 Response Status: ${response.statusCode}');

    if (response.statusCode == 401) {
      log('🚫 Unauthorized - Token may be expired or invalid');
      // Clear auth data and throw exception
      await AuthManager.clearAuthData();
      throw UnauthorizedException('Session expired. Please login again.');
    } else if (response.statusCode == 403) {
      log('🚫 Forbidden - Insufficient permissions');
      throw ForbiddenException(
          'You don\'t have permission to access this resource');
    } else if (response.statusCode >= 500) {
      log('💥 Server Error: ${response.statusCode}');
      throw ServerException('Server error occurred. Please try again later.');
    } else if (response.statusCode >= 400) {
      log('⚠️ Client Error: ${response.statusCode}');
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Request failed';
        throw ApiException(message, response.statusCode);
      } catch (e) {
        throw ApiException('Request failed with status ${response.statusCode}',
            response.statusCode);
      }
    }

    log('✅ Request completed successfully');
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await AuthManager.isLoggedIn();
  }

  /// Get current token
  static Future<String?> getToken() async {
    return await AuthManager.getToken();
  }
}

/// Custom Exceptions
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => '$message (Status: $statusCode)';
}
