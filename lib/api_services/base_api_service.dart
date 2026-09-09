import 'package:dio/dio.dart';
import '../features/auth/utils/auth_interceptor.dart';

/// Base API service class that all other API services can extend
/// Provides common functionality for API calls using Dio
abstract class BaseApiService {
  /// Initialize the base API service
  static void initialize({String? baseUrl}) {
    AuthInterceptor.initialize(baseUrl: baseUrl);
  }

  /// Get Dio instance for making requests
  static Dio get dio => AuthInterceptor.dio;

  /// Make a GET request
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
    String? logTag,
  }) async {
    try {
      _logRequest('GET', path, logTag);
      final response = await AuthInterceptor.get(
        path,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
      _logResponse(response, logTag);
      return response;
    } on DioException catch (e) {
      _logError(e, logTag);
      rethrow;
    }
  }

  /// Make a POST request
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
    String? logTag,
  }) async {
    try {
      _logRequest('POST', path, logTag);
      final response = await AuthInterceptor.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
      _logResponse(response, logTag);
      return response;
    } on DioException catch (e) {
      _logError(e, logTag);
      rethrow;
    }
  }

  /// Make a PUT request
  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
    String? logTag,
  }) async {
    try {
      _logRequest('PUT', path, logTag);
      final response = await AuthInterceptor.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
      _logResponse(response, logTag);
      return response;
    } on DioException catch (e) {
      _logError(e, logTag);
      rethrow;
    }
  }

  /// Make a DELETE request
  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
    String? logTag,
  }) async {
    try {
      _logRequest('DELETE', path, logTag);
      final response = await AuthInterceptor.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
      _logResponse(response, logTag);
      return response;
    } on DioException catch (e) {
      _logError(e, logTag);
      rethrow;
    }
  }

  /// Make a PATCH request
  static Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
    String? logTag,
  }) async {
    try {
      _logRequest('PATCH', path, logTag);
      final response = await AuthInterceptor.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
      _logResponse(response, logTag);
      return response;
    } on DioException catch (e) {
      _logError(e, logTag);
      rethrow;
    }
  }

  /// Handle Dio exceptions and convert to user-friendly messages
  static String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request. Please check your input.';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access forbidden. You don\'t have permission.';
          case 404:
            return 'Resource not found.';
          case 409:
            return 'Conflict. Resource already exists.';
          case 422:
            return 'Validation error. Please check your input.';
          case 500:
            return 'Internal server error. Please try again later.';
          case 502:
            return 'Bad gateway. Server is temporarily unavailable.';
          case 503:
            return 'Service unavailable. Please try again later.';
          default:
            return 'Server error (${statusCode ?? 'Unknown'}). Please try again.';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';

      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';

      default:
        return 'Network error. Please try again.';
    }
  }

  /// Extract error message from response
  static String extractErrorMessage(DioException error) {
    try {
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;

        // Common error message fields
        final possibleFields = [
          'message',
          'error',
          'msg',
          'detail',
          'description'
        ];

        for (final field in possibleFields) {
          if (data.containsKey(field) && data[field] is String) {
            return data[field] as String;
          }
        }

        // Check for validation errors
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          } else if (firstError is String) {
            return firstError;
          }
        }
      }
    } catch (_) {
      // suppressed
    }

    return handleDioError(error);
  }

  /// Parse response data safely
  static T? parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      if (response.data is Map<String, dynamic>) {
        return fromJson(response.data as Map<String, dynamic>);
      } else if (response.data is String) {
        // Handle string responses that might contain JSON
        return null;
      }
    } catch (_) {
      // suppressed
    }
    return null;
  }

  /// No-op: Request logging removed
  static void _logRequest(String method, String path, String? tag) {}

  /// No-op: Response logging removed
  static void _logResponse(Response response, String? tag) {}

  /// No-op: Error logging removed
  static void _logError(DioException error, String? tag) {}
}
