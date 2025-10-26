import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_models.dart';
import 'notification_config.dart';
import 'notification_handler.dart';
import 'local_notification_service.dart';

/// Handles Firebase Cloud Messaging (FCM) push notifications
class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? _fcmToken;
  static bool _isInitialized = false;

  /// Initialize push notification service
  static Future<void> initialize() async {
    if (_isInitialized) {
      log('PushNotificationService: Already initialized');
      return;
    }

    try {
      log('PushNotificationService: Initializing...');

      // Request permission for iOS
      if (Platform.isIOS) {
        await _requestPermission();
      }

      // Configure Firebase Messaging
      await _configureFirebaseMessaging();

      // Get initial FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      _isInitialized = true;
      log('PushNotificationService: Initialization complete');
    } catch (e) {
      log('PushNotificationService: Initialization error - $e');
      rethrow;
    }
  }

  /// Request notification permission (iOS)
  static Future<void> _requestPermission() async {
    try {
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('PushNotificationService: Permission status - ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log('PushNotificationService: Notification permission denied');
      }
    } catch (e) {
      log('PushNotificationService: Permission request error - $e');
    }
  }

  /// Configure Firebase Messaging handlers
  static Future<void> _configureFirebaseMessaging() async {
    try {
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is terminated or background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle initial message when app is launched from notification
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      log('PushNotificationService: Firebase messaging configured');
    } catch (e) {
      log('PushNotificationService: Configuration error - $e');
    }
  }

  /// Get FCM token
  static Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      log('PushNotificationService: FCM Token - $_fcmToken');
      return _fcmToken;
    } catch (e) {
      log('PushNotificationService: Error getting FCM token - $e');
      return null;
    }
  }

  /// Handle token refresh
  static void _onTokenRefresh(String token) {
    log('PushNotificationService: Token refreshed - $token');
    _fcmToken = token;

    // Update token on server
    _updateTokenOnServer(token);
  }

  /// Handle foreground message
  static void _handleForegroundMessage(RemoteMessage message) {
    log('PushNotificationService: Foreground message received');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');

    // Show local notification for foreground messages
    _showLocalNotificationFromRemote(message);
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    log('PushNotificationService: Notification tapped');
    log('Data: ${message.data}');

    // Extract data and handle navigation
    final Map<String, dynamic> data = message.data;

    _handleFCMNavigation(data);
  }

  /// Show local notification from remote message
  static Future<void> _showLocalNotificationFromRemote(
      RemoteMessage message) async {
    try {
      // Create a local notification model from the remote message
      final notification = LocalNotificationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
        priority: NotificationPriority.high,
        category: _getNotificationCategory(message.data['type']),
        autoCancel: true,
        ongoing: false,
        silent: false,
      );

      // Show the notification using local notification service
      await LocalNotificationService.staticShowNotification(notification);
    } catch (e) {
      log('PushNotificationService: Error showing local notification - $e');
    }
  }

  /// Handle FCM navigation
  static void _handleFCMNavigation(Map<String, dynamic> data) {
    try {
      final String? type = data['type'];
      final String? screen = data['screen'];
      final String? appointmentId = data['appointmentId'];
      final String? salonId = data['salonId'];
      final String? promoId = data['promoId'];

      // Handle different notification types
      switch (type) {
        case NotificationConfig.appointmentNotificationType:
          if (appointmentId != null) {
            _navigateToScreen(NotificationConfig.appointmentScreen,
                {'appointmentId': appointmentId});
          }
          break;
        case NotificationConfig.promoNotificationType:
          if (promoId != null) {
            _navigateToScreen(
                NotificationConfig.promoScreen, {'promoId': promoId});
          } else if (salonId != null) {
            _navigateToScreen('/salon-details', {'salonId': salonId});
          }
          break;
        case NotificationConfig.systemNotificationType:
          _navigateToScreen(screen ?? NotificationConfig.homeScreen, data);
          break;
        default:
          _navigateToScreen(screen ?? NotificationConfig.homeScreen, data);
      }
    } catch (e) {
      log('PushNotificationService: Navigation error - $e');
    }
  }

  /// Navigate to screen (placeholder - would use actual navigation)
  static void _navigateToScreen(String screen, Map<String, dynamic>? data) {
    log('PushNotificationService: Navigate to $screen with data: $data');
    // In a real implementation, this would use the app's navigation system
    // For now, we'll just log the action
  }

  /// Get notification category from type
  static NotificationCategory _getNotificationCategory(String? type) {
    switch (type) {
      case NotificationConfig.appointmentNotificationType:
        return NotificationCategory.appointment;
      case NotificationConfig.promoNotificationType:
        return NotificationCategory.promotion;
      case NotificationConfig.systemNotificationType:
        return NotificationCategory.system;
      default:
        return NotificationCategory.general;
    }
  }

  /// Update token on server
  static Future<void> _updateTokenOnServer(String token) async {
    try {
      log('PushNotificationService: Updating token on server - $token');

      // TODO: Implement API call to update token on your server
      // Example:
      // await ApiService.updateFCMToken(token);
    } catch (e) {
      log('PushNotificationService: Error updating token on server - $e');
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('PushNotificationService: Subscribed to topic - $topic');
    } catch (e) {
      log('PushNotificationService: Error subscribing to topic - $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('PushNotificationService: Unsubscribed from topic - $topic');
    } catch (e) {
      log('PushNotificationService: Error unsubscribing from topic - $e');
    }
  }

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Clear all subscriptions and reset
  static Future<void> reset() async {
    try {
      // Delete FCM token
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      _isInitialized = false;
      log('PushNotificationService: Reset complete');
    } catch (e) {
      log('PushNotificationService: Reset error - $e');
    }
  }

  /// Send test notification (for development)
  static Future<void> sendTestNotification() async {
    if (kDebugMode && _fcmToken != null) {
      log('PushNotificationService: Sending test notification to token: $_fcmToken');

      // Create a test notification
      final testNotification = LocalNotificationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Test Notification',
        body: 'This is a test notification from the app',
        payload: NotificationHandler.createPayload(
          type: NotificationConfig.generalNotificationType,
          screen: NotificationConfig.homeScreen,
          data: {'test': true},
        ),
        priority: NotificationPriority.high,
        category: NotificationCategory.general,
        autoCancel: true,
      );

      await LocalNotificationService.staticShowNotification(testNotification);
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('PushNotificationService: Background message received');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Data: ${message.data}');

  // Handle background message
  // Note: You can't update UI from here, but you can:
  // - Store data in local storage
  // - Show local notification
  // - Update app badge

  try {
    // Initialize local notification service if needed
    if (!LocalNotificationService.staticIsInitialized) {
      await LocalNotificationService.staticInitialize();
    } // Show local notification for background messages
    final notification = LocalNotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
      priority: NotificationPriority.high,
      category: NotificationCategory.general,
      autoCancel: true,
    );

    await LocalNotificationService.staticShowNotification(notification);
  } catch (e) {
    log('PushNotificationService: Background handler error - $e');
  }
}
