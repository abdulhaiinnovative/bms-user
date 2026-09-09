import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notification_models.dart';
import 'notification_config.dart';
import 'notification_handler.dart';
import 'local_notification_service.dart';
import 'notification_service.dart';

/// Handles Firebase Cloud Messaging (FCM) push notifications
class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? _fcmToken;
  static bool _isInitialized = false;

  static int _safeNotificationId() {
    return DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
  }

  /// Initialize push notification service
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('PushNotificationService: Already initialized, skipping');
      return;
    }

    try {
      debugPrint('PushNotificationService: Starting initialization');

      // Request permission for both iOS and Android
      await _requestPermission();

      // Configure Firebase Messaging
      await _configureFirebaseMessaging();

      // Get initial FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      _isInitialized = true;
      debugPrint(
          'PushNotificationService: Initialization completed successfully');
    } catch (e) {
      debugPrint('PushNotificationService: Initialization failed: $e');
      rethrow;
    }
  }

  /// Request notification permission
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

      debugPrint(
          'Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notification permission denied');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        debugPrint('Notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('Notification permission provisional');
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  /// Configure Firebase Messaging handlers
  static Future<void> _configureFirebaseMessaging() async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, // We handle foreground notifications manually via local_notifications
        badge: true,
        sound: true,
      );
      debugPrint(
          'PushNotificationService: iOS foreground presentation options set');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      debugPrint(
          'PushNotificationService: Background message handler registered');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      debugPrint(
          'PushNotificationService: Foreground message listener registered');

      // Handle notification tap when app is terminated or background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      debugPrint(
          'PushNotificationService: Message opened app listener registered');

      // Handle initial message when app is launched from notification
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            'PushNotificationService: Initial message found, handling tap');
        _handleNotificationTap(initialMessage);
      } else {
        debugPrint('PushNotificationService: No initial message');
      }
    } catch (e) {
      debugPrint(
          'PushNotificationService: Error configuring Firebase Messaging: $e');
    }
  }

  /// Get FCM token
  static Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      return _fcmToken;
    } catch (e) {
      return null;
    }
  }

  /// Handle token refresh
  static void _onTokenRefresh(String token) {
    _fcmToken = token;

    // Update token on server
    _updateTokenOnServer(token);
  }

  /// Handle foreground message
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('PushNotificationService: FCM Foreground message received');
    debugPrint(
        'PushNotificationService: Title: ${message.notification?.title}');
    debugPrint('PushNotificationService: Body: ${message.notification?.body}');
    debugPrint('PushNotificationService: Data: ${message.data}');

    // Refresh notification list in UI if on notifications screen
    NotificationService.refreshNotificationsList();
    debugPrint('PushNotificationService: Message ID: ${message.messageId}');

    // Check app lifecycle state
    final appState = WidgetsBinding.instance.lifecycleState;
    debugPrint('PushNotificationService: App lifecycle state: $appState');

    // Check if app is in foreground
    final isForeground = appState == AppLifecycleState.resumed;
    debugPrint('PushNotificationService: Is app in foreground: $isForeground');

    // Show local notification for foreground messages
    _showLocalNotificationFromRemote(message);

    // Refresh notification count in real-time
    NotificationService.refreshNotificationCount();
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    // Extract data and handle navigation
    final Map<String, dynamic> data = message.data;

    _handleFCMNavigation(data);

    // Refresh notification count
    NotificationService.refreshNotificationCount();
  }

  /// Show local notification from remote message
  static Future<void> _showLocalNotificationFromRemote(
      RemoteMessage message) async {
    try {
      // Check if LocalNotificationService is initialized
      if (!LocalNotificationService.isInitialized) {
        debugPrint(
            'PushNotificationService: LocalNotificationService not initialized, initializing now');
        await LocalNotificationService.staticInitialize();
      }

      final String? title = message.notification?.title ?? 
          message.data['title'] ?? 
          message.data['subject'];
          
      final String? body = message.notification?.body ?? 
          message.data['body'] ?? 
          message.data['message'];

      // If it's a completely silent data message without any text, do not show a notification
      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        debugPrint('PushNotificationService: Silent data message (no title/body). Skipping local notification.');
        return;
      }

      debugPrint(
          'PushNotificationService: Creating local notification from FCM message');
      final notification = LocalNotificationModel(
        id: PushNotificationService._safeNotificationId(),
        title: title ?? 'Notification',
        body: body ?? '',
        payload: NotificationHandler.createPayload(
          type: message.data['type'] ?? NotificationConfig.generalNotificationType,
          screen: message.data['screen'],
          data: message.data,
        ),
        priority: NotificationPriority.high,
        category: _getNotificationCategory(message.data['type']),
        autoCancel: true,
        ongoing: false,
        silent: false,
      );

      debugPrint('PushNotificationService: Showing local notification');
      await LocalNotificationService.staticShowNotification(notification);
    } catch (e) {
      debugPrint(
          'PushNotificationService: Error showing local notification: $e');
    }
  }

  /// Handle FCM navigation
  static void _handleFCMNavigation(Map<String, dynamic> data) {
    debugPrint('PushNotificationService: Received FCM data: $data');
    try {
      String? appointmentId = data['appointmentId'] ?? data['bookingId'] ?? data['route_id']?.toString();
      final String? salonId = data['salonId'];
      final String? screen = data['screen'];
      final String? type = data['type'];
      final String? action = data['action'];
      final String? promoId = data['promoId'];
      final String? category = data['category'];

      // Also check for category 'booking' if type is 'notification'
      bool isBookingType = type == 'booking' || 
                         type == 'appointment' || 
                         category == 'booking' ||
                         (type == 'notification' && category == 'booking');

      // If appointmentId is missing, try to extract it from the URL
      if (appointmentId == null && (data['url'] != null || data['link'] != null)) {
        final String urlStr = (data['url'] ?? data['link']).toString();
        debugPrint('PushNotificationService: ID missing, attempting extraction from URL: $urlStr');
        try {
          final Uri uri = Uri.parse(urlStr);
          
          // Check all path segments for a numeric ID
          for (final segment in uri.pathSegments) {
            final id = int.tryParse(segment);
            if (id != null && id > 0) {
              appointmentId = segment;
              debugPrint('PushNotificationService: Found ID in URL segment: $appointmentId');
              break;
            }
          }
          
          // Check common query parameters for ID if still not found
          if (appointmentId == null) {
            final queryKeys = ['id', 'booking_id', 'appointment_id', 'bookingId', 'appointmentId', 'booking_detail_id'];
            for (final key in queryKeys) {
              final queryVal = uri.queryParameters[key];
              if (queryVal != null) {
                final id = int.tryParse(queryVal);
                if (id != null && id > 0) {
                  appointmentId = queryVal;
                  debugPrint('PushNotificationService: Found ID in query parameter ($key): $appointmentId');
                  break;
                }
              }
            }
          }
        } catch (e) {
          debugPrint('PushNotificationService: URL parsing error: $e');
        }
      }

      debugPrint('PushNotificationService: Final Appointment ID for navigation: $appointmentId');

      // Prioritize booking navigation if an appointment ID was found and it's a booking-related notification
      bool hasNavigated = false;
      if (appointmentId != null && isBookingType) {
        debugPrint('PushNotificationService: Aggressive booking navigation for ID: $appointmentId');
        _navigateToScreen(NotificationConfig.appointmentScreen, {
          'appointmentId': appointmentId,
          'id': appointmentId
        });
        hasNavigated = true;
      }

      // Handle other notification types if not already navigated
      if (!hasNavigated) {
        switch (type) {
          case NotificationConfig.promoNotificationType:
            if (promoId != null) {
              _navigateToScreen(
                  NotificationConfig.promoScreen, {'promoId': promoId});
              hasNavigated = true;
            } else if (salonId != null) {
              _navigateToScreen('/salon-details', {'salonId': salonId});
              hasNavigated = true;
            }
            break;
          case NotificationConfig.systemNotificationType:
            _navigateToScreen(screen ?? NotificationConfig.homeScreen, data);
            hasNavigated = true;
            break;
          default:
            if (screen != null) {
              _navigateToScreen(screen, data);
              hasNavigated = true;
            }
        }
      }
 
      // Handle URL/Link if present in data AND we haven't navigated yet
      final String? url = data['url'] ?? data['link'];
      if (!hasNavigated && url != null) {
        _launchURL(url);
        hasNavigated = true;
      }

      // Final fallback: show dialog if nothing else worked
      if (!hasNavigated) {
        final String? title = data['subject'] ?? data['title'] ?? 'Notification';
        final String? body = data['message'] ?? data['body'];
        
        if (title != null || body != null) {
          final context = NotificationHandler.navigatorKey?.currentContext;
          if (context != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title ?? 'Notification'),
                content: Text(body ?? ''),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      // debug logs removed
    }
  }

  /// Launch a URL
  static Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  /// Navigate to screen
  static void _navigateToScreen(String screen, Map<String, dynamic>? data) {
    debugPrint('PushNotificationService: Navigating to $screen');
    NotificationHandler.navigateToScreen(screen, data);
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
      // TODO: Implement API call to update token on your server
      // Example:
      // await ApiService.updateFCMToken(token);
    } catch (e) {
      // debug logs removed
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // debug logs removed
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // debug logs removed
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
    } catch (e) {
      // debug logs removed
    }
  }

  /// Send test notification (for development)
  static Future<void> sendTestNotification() async {
    if (kDebugMode && _fcmToken != null) {
      // Create a test notification
      final testNotification = LocalNotificationModel(
        id: PushNotificationService._safeNotificationId(),
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
  debugPrint('PushNotificationService: Background message received');
  debugPrint(
      'PushNotificationService: Background Title: ${message.notification?.title}');
  debugPrint(
      'PushNotificationService: Background Body: ${message.notification?.body}');
  debugPrint('PushNotificationService: Background Data: ${message.data}');
  debugPrint(
      'PushNotificationService: Background Message ID: ${message.messageId}');

  // Handle background message
  // Note: You can't update UI from here, but you can:
  // - Store data in local storage
  // - Show local notification
  // - Update app badge

  try {
    // If the message contains a notification payload, the OS already shows it natively in the background.
    // We only need to trigger a local notification manually for data-only messages to avoid double notifications.
    if (message.notification != null) {
      debugPrint('PushNotificationService: Notification payload exists, OS will display it. Skipping local notification.');
      return; 
    }

    // Initialize local notification service if needed
    if (!LocalNotificationService.staticIsInitialized) {
      debugPrint(
          'PushNotificationService: Initializing local notification service in background');
      await LocalNotificationService.staticInitialize();
    }
    // Extract title and body from data payload if available
    final String? title = message.data['title'] ?? message.data['subject'];
    final String? body = message.data['body'] ?? message.data['message'];

    // If there is no title and no body in the data payload, it is a silent data sync message.
    // Do not show an empty "Notification" popup.
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      debugPrint('PushNotificationService: Silent data-only message received. Skipping local notification.');
      return;
    }

    // Show local notification for background messages
    final notification = LocalNotificationModel(
      id: PushNotificationService._safeNotificationId(),
      title: title ?? 'Notification',
      body: body ?? '',
      payload: NotificationHandler.createPayload(
        type: message.data['type'] ?? NotificationConfig.generalNotificationType,
        screen: message.data['screen'],
        data: message.data,
      ),
      priority: NotificationPriority.high,
      category: NotificationCategory.general,
      autoCancel: true,
    );

    debugPrint(
        'PushNotificationService: Showing background local notification');
    await LocalNotificationService.staticShowNotification(notification);
    debugPrint(
        'PushNotificationService: Background notification shown successfully');
  } catch (e) {
    debugPrint(
        'PushNotificationService: Error in background message handler: $e');
  }
}
