import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../features/auth/utils/auth_manager.dart';
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

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      await _handleResponse(response, url);
      return response;
    } catch (e) {
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

    if (kDebugMode && endpoint.contains('create-booking')) {
      print('═══════════════════════════════════════════════════════════════');
      print('🔐 PROTECTED HTTP CLIENT - POST REQUEST');
      print('═══════════════════════════════════════════════════════════════');
      print('URL: $url');
      print('Endpoint: $endpoint');
      print('Requires Auth: $requiresAuth');
      print('');
      print('📋 HEADERS:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          final tokenPreview =
              value.length > 20 ? '${value.substring(0, 20)}...' : value;
          print('  ├─ $key: $tokenPreview');
        } else {
          print('  ├─ $key: $value');
        }
      });
      print('');
      print('📦 REQUEST BODY (RAW):');
      if (body != null) {
        print(jsonEncode(body));
      } else {
        print('  └─ (null)');
      }
      print('═══════════════════════════════════════════════════════════════');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (kDebugMode && endpoint.contains('create-booking')) {
        print('');
        print(
            '═══════════════════════════════════════════════════════════════');
        print('📥 HTTP RESPONSE RECEIVED');
        print(
            '═══════════════════════════════════════════════════════════════');
        print('Status Code: ${response.statusCode}');
        print('Reason Phrase: ${response.reasonPhrase}');
        print('');
        print('📋 RESPONSE HEADERS:');
        response.headers.forEach((key, value) {
          print('  ├─ $key: $value');
        });
        print('');
        print('📄 RESPONSE BODY:');
        print(response.body);
        print(
            '═══════════════════════════════════════════════════════════════');
      }

      await _handleResponse(response, url);
      return response;
    } catch (e) {
      if (kDebugMode && endpoint.contains('create-booking')) {
        print('');
        print('💥 EXCEPTION IN HTTP CLIENT');
        print(
            '═══════════════════════════════════════════════════════════════');
        print('Exception: $e');
        print(
            '═══════════════════════════════════════════════════════════════');
      }
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

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      await _handleResponse(response, url);
      return response;
    } catch (e) {
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

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);
      await _handleResponse(response, url);
      return response;
    } catch (e) {
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
      if (kDebugMode) {
        // Building headers with auth requirement (debug log)
      }
      final token = await AuthManager.getToken();
      if (token != null && token.isNotEmpty) {
        if (kDebugMode) {
          // Token found, adding to headers (debug log)
        }
        headers['Authorization'] = 'Bearer $token';
      } else {
        // No token found; throw UnauthorizedException
        throw UnauthorizedException('Please login to continue');
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
    if (kDebugMode) {
      // Response status ${response.statusCode} for $url (debug log)
    }

    if (response.statusCode == 401) {
      // Don't clear auth for login/register/signup endpoints
      if (url.contains('/auth/login') ||
          url.contains('/auth/register') ||
          url.contains('/auth/signup')) {
        // 401 on auth endpoint; not clearing auth data (debug log removed)
        throw UnauthorizedException(
            'Invalid credentials. Please check your email and password.');
      }

      // For other endpoints, check if token exists before clearing
      final token = await AuthManager.getToken();
      if (token == null || token.isEmpty) {
        // 401 but no token exists; already logged out
        throw UnauthorizedException('Please login to continue.');
      }

      // Token exists but got 401 - session expired
      if (kDebugMode) {
        // Session expired (401 with valid token), clearing auth data (debug log)
      }
      await AuthManager.clearAuthData();
      throw UnauthorizedException('Session expired. Please login again.');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(
          'You don\'t have permission to access this resource');
    } else if (response.statusCode == 422) {
      // Don't throw exception for 422 - let the calling service handle it
      // 422 is a validation error with structured error messages
      return;
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error occurred. Please try again later.');
    } else if (response.statusCode >= 400) {
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Request failed';
        throw ApiException(message, response.statusCode);
      } catch (e) {
        throw ApiException('Request failed with status ${response.statusCode}',
            response.statusCode);
      }
    }
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
