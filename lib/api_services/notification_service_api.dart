import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants.dart';
import '../../models/notification/notification_model.dart';
import '../../features/auth/utils/auth_interceptor.dart';

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
      final response = await AuthInterceptor.get(
        '$notificationsEndpoint?page=$page',
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final notificationsResponse =
            NotificationsResponse.fromJson(responseData);

        return notificationsResponse;
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      debugPrint('Notification getNotifications DioException: $dioError');
      debugPrint('Stack trace: $stackTrace');
      if (dioError.response != null) {
        debugPrint('Response data: ${dioError.response?.data}');
        debugPrint('Status code: ${dioError.response?.statusCode}');
      }

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
      debugPrint('Notification getNotifications error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Get unread notification count
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
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
        return unreadCountResponse;
      } else {
        throw Exception('Failed to fetch unread count: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      debugPrint('Notification getUnreadCount DioException: $dioError');
      debugPrint('Stack trace: $stackTrace');
      if (dioError.response != null) {
        debugPrint('Response data: ${dioError.response?.data}');
        debugPrint('Status code: ${dioError.response?.statusCode}');
      }
      throw Exception('Failed to fetch unread count');
    } catch (e, stackTrace) {
      debugPrint('Notification getUnreadCount error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch unread count: ${e.toString()}');
    }
  }

  /// Mark a single notification as read
  Future<MarkReadResponse> markAsRead(int notificationId) async {
    try {
      debugPrint(
          'NotificationServiceAPI: Marking notification $notificationId as read');
      final response = await AuthInterceptor.get(
        markReadEndpoint(notificationId.toString()),
        requiresAuth: true,
      );

      debugPrint(
          'NotificationServiceAPI: Mark read response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final markReadResponse = MarkReadResponse.fromJson(responseData);
        debugPrint(
            'NotificationServiceAPI: Successfully marked notification as read');
        return markReadResponse;
      } else {
        debugPrint(
            'NotificationServiceAPI: Failed to mark notification as read: ${response.statusCode}');
        throw Exception(
            'Failed to mark notification as read: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      debugPrint(
          'NotificationServiceAPI: DioException in markAsRead: $dioError');
      debugPrint('Stack trace: $stackTrace');
      if (dioError.response != null) {
        debugPrint('Response data: ${dioError.response?.data}');
        debugPrint('Status code: ${dioError.response?.statusCode}');
      }
      if (dioError.response != null && dioError.response!.statusCode == 401) {
        throw Exception('Please login to continue');
      }
      throw Exception('Failed to mark notification as read');
    } catch (e, stackTrace) {
      debugPrint('NotificationServiceAPI: Error in markAsRead: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<MarkAllReadResponse> markAllAsRead() async {
    try {
      final response = await AuthInterceptor.get(
        markAllReadEndpoint,
        requiresAuth: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : jsonDecode(response.data.toString());

        final markAllReadResponse = MarkAllReadResponse.fromJson(responseData);
        return markAllReadResponse;
      } else {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } on DioException catch (dioError, stackTrace) {
      throw Exception('Failed to mark all notifications as read');
    } catch (e, stackTrace) {
      throw Exception('Failed to mark all as read: ${e.toString()}');
    }
  }
}
