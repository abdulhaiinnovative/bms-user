import 'package:app/core/base/base_repository.dart';
import 'package:app/api_services/notification_service_api.dart';

/// Repository for notifications operations
class NotificationsRepository extends BaseRepository {
  final NotificationServiceAPI _notificationAPI;

  NotificationsRepository({NotificationServiceAPI? notificationAPI})
      : _notificationAPI = notificationAPI ?? NotificationServiceAPI();

  /// Get notifications with pagination
  Future<dynamic> getNotifications({int page = 1}) async {
    return await execute(
      operation: () => _notificationAPI.getNotifications(page: page),
      errorContext: 'Get notifications (page: $page)',
    );
  }

  /// Get unread notification count
  Future<dynamic> getUnreadCount() async {
    return await execute(
      operation: () => _notificationAPI.getUnreadCount(),
      errorContext: 'Get unread count',
    );
  }

  /// Mark a notification as read
  Future<dynamic> markAsRead(int notificationId) async {
    return await execute(
      operation: () => _notificationAPI.markAsRead(notificationId),
      errorContext: 'Mark notification as read',
    );
  }

  /// Mark all notifications as read
  Future<dynamic> markAllAsRead() async {
    return await execute(
      operation: () => _notificationAPI.markAllAsRead(),
      errorContext: 'Mark all notifications as read',
    );
  }
}
