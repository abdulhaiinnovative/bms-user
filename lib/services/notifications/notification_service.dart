import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'local_notification_service.dart';
import 'push_notification_service.dart';
import 'notification_handler.dart';
import 'notification_models.dart';
import 'notification_config.dart';

/// Main notification service that manages all notification functionality
class NotificationService {
  static bool _isInitialized = false;

  /// Initialize all notification services
  static Future<void> initialize({
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    if (_isInitialized) {
      return;
    }

    try {
      // Store navigator key for navigation
      if (navigatorKey != null) {
        NotificationHandler.setNavigatorKey(navigatorKey);
      }

      // Initialize local notification service
      await LocalNotificationService.staticInitialize();

      // Initialize push notification service
      await PushNotificationService.initialize();

      // Register default notification callbacks
      _registerDefaultCallbacks();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Register default notification callbacks
  static void _registerDefaultCallbacks() {
    // Register appointment notification callback
    NotificationHandler.registerNotificationCallback(
      NotificationConfig.appointmentNotificationType,
      () {},
    );

    // Register promotion notification callback
    NotificationHandler.registerNotificationCallback(
      NotificationConfig.promoNotificationType,
      () {},
    );

    // Register system notification callback
    NotificationHandler.registerNotificationCallback(
      NotificationConfig.systemNotificationType,
      () {},
    );

    // Register data callbacks for detailed handling
    NotificationHandler.registerDataCallback(
      NotificationConfig.appointmentNotificationType,
      (data) => _handleAppointmentData(data),
    );

    NotificationHandler.registerDataCallback(
      NotificationConfig.promoNotificationType,
      (data) => _handlePromotionData(data),
    );
  }

  /// Handle appointment notification data
  static void _handleAppointmentData(Map<String, dynamic> data) {
    final String? appointmentId = data['appointmentId'];
    final String? action = data['action'];

    if (appointmentId != null) {
      // Handle specific appointment actions
      switch (action) {
        case 'reminder':
          break;
        case 'confirmation':
          break;
        case 'cancellation':
          break;
      }
    }
  }

  /// Handle promotion notification data
  static void _handlePromotionData(Map<String, dynamic> data) {
    final String? promoId = data['promoId'];
    final String? discountPercentage = data['discountPercentage'];

    if (promoId != null) {}
  }

  /// Show a simple notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    NotificationCategory category = NotificationCategory.general,
  }) async {
    if (!_isInitialized) {
      return;
    }

    final notification = LocalNotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: payload,
      priority: priority,
      category: category,
      autoCancel: true,
    );

    await LocalNotificationService.staticShowNotification(notification);
  }

  /// Show appointment reminder notification
  static Future<void> showAppointmentReminder({
    required String appointmentId,
    required String salonName,
    required DateTime appointmentTime,
    String? serviceDetails,
  }) async {
    final payload = NotificationHandler.createPayload(
      type: NotificationConfig.appointmentNotificationType,
      screen: NotificationConfig.appointmentScreen,
      data: {
        'appointmentId': appointmentId,
        'action': 'reminder',
        'salonName': salonName,
        'appointmentTime': appointmentTime.toIso8601String(),
      },
    );

    final notification = LocalNotificationModel(
      id: int.parse(appointmentId.hashCode.toString().substring(0, 8)),
      title: 'Appointment Reminder',
      body:
          'Your appointment at $salonName is ${_getTimeUntilAppointment(appointmentTime)}',
      payload: payload,
      priority: NotificationPriority.high,
      category: NotificationCategory.appointment,
      autoCancel: true,
      silent: false,
    );

    await LocalNotificationService.staticShowNotification(notification);
  }

  /// Show promotion notification
  static Future<void> showPromotionNotification({
    required String promoId,
    required String title,
    required String description,
    String? salonId,
    String? salonName,
    int? discountPercentage,
    DateTime? expiryDate,
  }) async {
    final payload = NotificationHandler.createPayload(
      type: NotificationConfig.promoNotificationType,
      screen: NotificationConfig.promoScreen,
      data: {
        'promoId': promoId,
        'salonId': salonId,
        'salonName': salonName,
        'discountPercentage': discountPercentage,
        'expiryDate': expiryDate?.toIso8601String(),
      },
    );

    final notification = LocalNotificationModel(
      id: promoId.hashCode,
      title: title,
      body: description,
      payload: payload,
      priority: NotificationPriority.normal,
      category: NotificationCategory.promotion,
      autoCancel: true,
    );

    await LocalNotificationService.staticShowNotification(notification);
  }

  /// Schedule appointment reminder
  static Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String salonName,
    required DateTime appointmentTime,
    Duration reminderBefore = const Duration(hours: 2),
    String? serviceDetails,
  }) async {
    final reminderTime = appointmentTime.subtract(reminderBefore);

    // Don't schedule if the reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final payload = NotificationHandler.createPayload(
      type: NotificationConfig.appointmentNotificationType,
      screen: NotificationConfig.appointmentScreen,
      data: {
        'appointmentId': appointmentId,
        'action': 'reminder',
        'salonName': salonName,
        'appointmentTime': appointmentTime.toIso8601String(),
        'serviceDetails': serviceDetails,
      },
    );

    final scheduledNotification = ScheduledNotificationModel(
      id: int.parse(appointmentId.hashCode.toString().substring(0, 8)),
      title: 'Upcoming Appointment',
      body:
          'Your appointment at $salonName is in ${_formatDuration(reminderBefore)}',
      payload: payload,
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      priority: NotificationPriority.high,
      category: NotificationCategory.appointment,
      autoCancel: true,
    );

    await LocalNotificationService.staticScheduleNotification(
        scheduledNotification);
  }

  /// Cancel appointment reminder
  static Future<void> cancelAppointmentReminder(String appointmentId) async {
    final notificationId =
        int.parse(appointmentId.hashCode.toString().substring(0, 8));
    await LocalNotificationService.staticCancelNotification(notificationId);
  }

  /// Show system notification
  static Future<void> showSystemNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? targetScreen,
  }) async {
    final payload = NotificationHandler.createPayload(
      type: NotificationConfig.systemNotificationType,
      screen: targetScreen,
      data: data,
    );

    final notification = LocalNotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      payload: payload,
      priority: NotificationPriority.high,
      category: NotificationCategory.system,
      autoCancel: true,
    );

    await LocalNotificationService.staticShowNotification(notification);
  }

  /// Get FCM token for push notifications
  static String? getFCMToken() {
    return PushNotificationService.fcmToken;
  }

  /// Subscribe to notification topic
  static Future<void> subscribeToTopic(String topic) async {
    await PushNotificationService.subscribeToTopic(topic);
  }

  /// Unsubscribe from notification topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await PushNotificationService.unsubscribeFromTopic(topic);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await LocalNotificationService.staticCancelAllNotifications();
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await LocalNotificationService.staticCancelNotification(id);
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await LocalNotificationService.staticAreNotificationsEnabled();
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    return await LocalNotificationService.staticRequestPermissions();
  }

  /// Reset all notification services
  static Future<void> reset() async {
    try {
      await LocalNotificationService.staticCancelAllNotifications();
      await PushNotificationService.reset();
      NotificationHandler.clearCallbacks();
      _isInitialized = false;
    } catch (e) {}
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get time until appointment as human readable string
  static String _getTimeUntilAppointment(DateTime appointmentTime) {
    final now = DateTime.now();
    final difference = appointmentTime.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'now';
    }
  }

  /// Format duration as human readable string
  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'less than a minute';
    }
  }

  /// Register custom notification callback
  static void registerNotificationCallback(String type, VoidCallback callback) {
    NotificationHandler.registerNotificationCallback(type, callback);
  }

  /// Register custom data callback
  static void registerDataCallback(
      String type, Function(Map<String, dynamic>) callback) {
    NotificationHandler.registerDataCallback(type, callback);
  }
}
