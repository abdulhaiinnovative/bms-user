import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../../constants.dart';
import '../../models/notification/notification_model.dart';
import '../../utlis/authutils/auth_interceptor.dart';

class NotificationServiceAPI {
  static const String baseURL = BASE_URL;

  // API endpoints
  static const String notificationsEndpoint = '/notifications';
  static const String unreadCountEndpoint = '/notifications/unread/count';
  static const String markAllReadEndpoint = '/notifications/mark-all-read';
  static String markReadEndpoint(String id) => '/notifications/$id/mark-read';

  NotificationServiceAPI() {
    AuthInterceptor.initialize(baseUrl: baseURL);
  }

  /// Get all notifications with pagination
  /// page: page number (default: 1)
  Future<NotificationsResponse> getNotifications({int page = 1}) async {
    try {
      log('📬 NotificationAPI: Fetching notifications (page: $page)');

      final response = await AuthInterceptor.get(
        '$notificationsEndpoint?page=$page',
        requiresAuth: true,
      );

      log('📬 NotificationAPI: Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final notificationsResponse =
            NotificationsResponse.fromJson(responseData);
        log('✅ NotificationAPI: Fetched ${notificationsResponse.data.length} notifications');
        return notificationsResponse;
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      log('❌ NotificationAPI: DioError - ${dioError.message}');
      log('📍 NotificationAPI: Stack Trace:\n$stackTrace');

      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Request timeout. Please check your internet connection');
      } else if (dioError.type == DioExceptionType.connectionError) {
        throw Exception('Network error. Please check your internet connection');
      } else if (dioError.response != null) {
        final statusCode = dioError.response!.statusCode ?? 500;
        throw Exception('Server error: HTTP $statusCode');
      } else {
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e, stackTrace) {
      log('💥 NotificationAPI: Error - $e');
      log('📍 NotificationAPI: Stack Trace:\n$stackTrace');
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Get unread notification count
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      log('🔔 NotificationAPI: Fetching unread count');

      final response = await AuthInterceptor.get(
        unreadCountEndpoint,
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final unreadCountResponse = UnreadCountResponse.fromJson(responseData);
        log('✅ NotificationAPI: Unread count: ${unreadCountResponse.unreadCount}');
        return unreadCountResponse;
      } else {
        throw Exception('Failed to fetch unread count: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      log('❌ NotificationAPI: Unread count error - ${dioError.message}');
      throw Exception('Failed to fetch unread count');
    } catch (e) {
      log('💥 NotificationAPI: Unread count error - $e');
      throw Exception('Failed to fetch unread count: ${e.toString()}');
    }
  }

  /// Mark a single notification as read
  Future<MarkReadResponse> markAsRead(int notificationId) async {
    try {
      log('📖 NotificationAPI: Marking notification $notificationId as read');

      final response = await AuthInterceptor.post(
        markReadEndpoint(notificationId.toString()),
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final markReadResponse = MarkReadResponse.fromJson(responseData);
        log('✅ NotificationAPI: Notification $notificationId marked as read');
        return markReadResponse;
      } else {
        throw Exception(
            'Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      log('❌ NotificationAPI: Mark as read error - ${dioError.message}');
      throw Exception('Failed to mark notification as read');
    } catch (e) {
      log('💥 NotificationAPI: Mark as read error - $e');
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<MarkAllReadResponse> markAllAsRead() async {
    try {
      log('📖 NotificationAPI: Marking all notifications as read');

      final response = await AuthInterceptor.post(
        markAllReadEndpoint,
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final markAllReadResponse = MarkAllReadResponse.fromJson(responseData);
        log('✅ NotificationAPI: Marked ${markAllReadResponse.updatedCount} notifications as read');
        return markAllReadResponse;
      } else {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      log('❌ NotificationAPI: Mark all as read error - ${dioError.message}');
      throw Exception('Failed to mark all notifications as read');
    } catch (e) {
      log('💥 NotificationAPI: Mark all as read error - $e');
      throw Exception('Failed to mark all as read: ${e.toString()}');
    }
  }
}
