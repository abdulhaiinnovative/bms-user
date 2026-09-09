import 'package:dio/dio.dart';
import 'auth_manager.dart';
import '../../../utils/restriction_handler.dart';

class AuthInterceptor {
  static late Dio _dio;
  static bool _isInitialized = false;

  static void initialize({
    String? baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    int sendTimeout = 30000,
  }) {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(AuthDioInterceptor());

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));

    _isInitialized = true;
  }

  static Dio get dio {
    if (!_isInitialized) {
      initialize();
    }
    return _dio;
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.extra = {'requiresAuth': requiresAuth};

    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.extra = {'requiresAuth': requiresAuth};

    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.extra = {'requiresAuth': requiresAuth};

    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.extra = {'requiresAuth': requiresAuth};

    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  static Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.extra = {'requiresAuth': requiresAuth};

    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }
}

class AuthDioInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final authHeaders = await AuthManager.getAuthHeaders();
      if (authHeaders != null) {
        options.headers.addAll(authHeaders);
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Check for user restriction in API response
    try {
      final data = response.data;
      
      if (data is Map) {
        // Check in response.user.is_restricted and response.user.status
        final responseData = data['response'];
        if (responseData is Map) {
          final user = responseData['user'];
          if (user is Map) {
            final isRestricted = user['is_restricted'];
            final status = user['status'];
            
            // Check both restriction and status
            await RestrictionHandler.checkUserAccess(
              isRestricted: isRestricted as int?,
              status: status as int?,
            );
          }
        }
        
        // Also check in data.is_restricted and data.status (for other response formats)
        final isRestricted = data['is_restricted'];
        final status = data['status'];
        if (isRestricted != null || status != null) {
          await RestrictionHandler.checkUserAccess(
            isRestricted: isRestricted as int?,
            status: status as int?,
          );
        }
      }
    } catch (e) {
      // Silently ignore restriction check errors to not break API flow
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // AuthInterceptor error occurred (debug log removed)

    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      final requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;

      // Don't clear auth for endpoints that don't require authentication
      if (!requiresAuth) {
        // 401 on non-auth-required endpoint (debug log removed)
        super.onError(err, handler);
        return;
      }

      // Don't clear auth for login/register/signup endpoints
      if (path.contains('/auth/login') ||
          path.contains('/auth/register') ||
          path.contains('/auth/signup')) {
        // 401 on auth endpoint (debug log removed)
        super.onError(err, handler);
        return;
      }

      // 401 error, attempting token refresh (debug log removed)
      final refreshed = await _handleTokenRefresh();

      if (refreshed) {
        // Token refreshed successfully (debug log removed)
        final response = await _retryRequest(err.requestOptions);
        handler.resolve(response);
        return;
      } else {
        // Token refresh failed (debug log removed)
        await AuthManager.clearAuthData();
      }
    }

    super.onError(err, handler);
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      return await AuthManager.refreshAuthToken();
    } catch (e) {
      // Token refresh failed (debug log removed)
      return false;
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final authHeaders = await AuthManager.getAuthHeaders();
    if (authHeaders != null) {
      requestOptions.headers.addAll(authHeaders);
    }

    final retryDio = Dio();

    return await retryDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: requestOptions.extra,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
      ),
    );
  }
}
