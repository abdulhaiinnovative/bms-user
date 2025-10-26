import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_config.dart';

/// Handles notification taps and actions
class NotificationHandler {
  static final Map<String, VoidCallback> _notificationCallbacks = {};
  static final Map<String, Function(Map<String, dynamic>)> _dataCallbacks = {};
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Set the navigator key for navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Register a callback for a specific notification type
  static void registerNotificationCallback(String type, VoidCallback callback) {
    _notificationCallbacks[type] = callback;
  }

  /// Register a data callback for a specific notification type
  static void registerDataCallback(
      String type, Function(Map<String, dynamic>) callback) {
    _dataCallbacks[type] = callback;
  }

  /// Handle notification tap when app is running or in background
  static void handleNotificationTap(NotificationResponse response) {
    log('NotificationHandler: Handling notification tap - ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) {
      log('NotificationHandler: No payload found');
      return;
    }

    try {
      final Map<String, dynamic> payload = jsonDecode(response.payload!);
      final String? type = payload[NotificationConfig.payloadTypeKey];
      final Map<String, dynamic>? data =
          payload[NotificationConfig.payloadDataKey];
      final String? screen = payload[NotificationConfig.payloadScreenKey];

      log('NotificationHandler: Type: $type, Screen: $screen, Data: $data');

      // Handle specific notification types
      if (type != null) {
        _handleNotificationType(type, data ?? {});
      }

      // Navigate to specific screen if specified
      if (screen != null) {
        _navigateToScreen(screen, data);
      }

      // Execute registered callbacks
      if (type != null && _notificationCallbacks.containsKey(type)) {
        _notificationCallbacks[type]!();
      }

      if (type != null && _dataCallbacks.containsKey(type) && data != null) {
        _dataCallbacks[type]!(data);
      }
    } catch (e) {
      log('NotificationHandler: Error parsing payload - $e');
    }
  }

  /// Handle iOS foreground notification
  static void handleIOSForegroundNotification(
      int id, String? title, String? body, String? payload) {
    log('NotificationHandler: iOS foreground notification - $title');

    // For iOS, you might want to show a custom dialog or banner
    // when a notification is received while the app is in foreground
    if (_navigatorKey?.currentContext != null) {
      _showForegroundNotificationDialog(
        _navigatorKey!.currentContext!,
        title ?? 'Notification',
        body ?? '',
        payload,
      );
    }
  }

  /// Handle specific notification types
  static void _handleNotificationType(String type, Map<String, dynamic> data) {
    switch (type) {
      case NotificationConfig.appointmentNotificationType:
        _handleAppointmentNotification(data);
        break;
      case NotificationConfig.promoNotificationType:
        _handlePromoNotification(data);
        break;
      case NotificationConfig.systemNotificationType:
        _handleSystemNotification(data);
        break;
      case NotificationConfig.generalNotificationType:
        _handleGeneralNotification(data);
        break;
      default:
        log('NotificationHandler: Unknown notification type - $type');
    }
  }

  /// Handle appointment notifications
  static void _handleAppointmentNotification(Map<String, dynamic> data) {
    log('NotificationHandler: Handling appointment notification');

    // Extract appointment-specific data
    final String? appointmentId = data['appointmentId'];
    final String? action = data['action'];

    if (appointmentId != null) {
      // Handle different appointment actions
      switch (action) {
        case 'reminder':
          _handleAppointmentReminder(appointmentId, data);
          break;
        case 'confirmation':
          _handleAppointmentConfirmation(appointmentId, data);
          break;
        case 'cancellation':
          _handleAppointmentCancellation(appointmentId, data);
          break;
        default:
          _navigateToAppointmentDetails(appointmentId);
      }
    }
  }

  /// Handle promotional notifications
  static void _handlePromoNotification(Map<String, dynamic> data) {
    log('NotificationHandler: Handling promo notification');

    final String? promoId = data['promoId'];
    final String? salonId = data['salonId'];

    // Navigate to appropriate promo screen
    if (promoId != null) {
      _navigateToPromoDetails(promoId, data);
    } else if (salonId != null) {
      _navigateToSalonDetails(salonId);
    } else {
      _navigateToScreen(NotificationConfig.promoScreen, data);
    }
  }

  /// Handle system notifications
  static void _handleSystemNotification(Map<String, dynamic> data) {
    log('NotificationHandler: Handling system notification');

    final String? action = data['action'];

    switch (action) {
      case 'update':
        _handleAppUpdate(data);
        break;
      case 'maintenance':
        _handleMaintenanceNotification(data);
        break;
      default:
        _navigateToScreen(NotificationConfig.homeScreen, data);
    }
  }

  /// Handle general notifications
  static void _handleGeneralNotification(Map<String, dynamic> data) {
    log('NotificationHandler: Handling general notification');
    _navigateToScreen(NotificationConfig.homeScreen, data);
  }

  /// Navigate to a specific screen
  static void _navigateToScreen(String screen, Map<String, dynamic>? data) {
    if (_navigatorKey?.currentState != null) {
      try {
        _navigatorKey!.currentState!.pushNamed(screen, arguments: data);
        log('NotificationHandler: Navigated to $screen');
      } catch (e) {
        log('NotificationHandler: Navigation error - $e');
        // Fallback to home screen
        _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
          NotificationConfig.homeScreen,
          (route) => false,
        );
      }
    } else {
      log('NotificationHandler: Navigator not available');
    }
  }

  /// Show foreground notification dialog for iOS
  static void _showForegroundNotificationDialog(
    BuildContext context,
    String title,
    String body,
    String? payload,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (payload != null) {
                  handleNotificationTap(NotificationResponse(
                    notificationResponseType:
                        NotificationResponseType.selectedNotification,
                    payload: payload,
                  ));
                }
              },
              child: const Text('Open'),
            ),
          ],
        );
      },
    );
  }

  /// Handle appointment reminder
  static void _handleAppointmentReminder(
      String appointmentId, Map<String, dynamic> data) {
    log('NotificationHandler: Appointment reminder for $appointmentId');
    _navigateToAppointmentDetails(appointmentId);
  }

  /// Handle appointment confirmation
  static void _handleAppointmentConfirmation(
      String appointmentId, Map<String, dynamic> data) {
    log('NotificationHandler: Appointment confirmation for $appointmentId');
    _navigateToAppointmentDetails(appointmentId);
  }

  /// Handle appointment cancellation
  static void _handleAppointmentCancellation(
      String appointmentId, Map<String, dynamic> data) {
    log('NotificationHandler: Appointment cancellation for $appointmentId');
    _navigateToScreen(NotificationConfig.homeScreen, data);
  }

  /// Navigate to appointment details
  static void _navigateToAppointmentDetails(String appointmentId) {
    _navigateToScreen(NotificationConfig.appointmentScreen, {
      'appointmentId': appointmentId,
    });
  }

  /// Navigate to promo details
  static void _navigateToPromoDetails(
      String promoId, Map<String, dynamic> data) {
    _navigateToScreen(NotificationConfig.promoScreen, {
      'promoId': promoId,
      ...data,
    });
  }

  /// Navigate to salon details
  static void _navigateToSalonDetails(String salonId) {
    _navigateToScreen('/salon-details', {
      'salonId': salonId,
    });
  }

  /// Handle app update notification
  static void _handleAppUpdate(Map<String, dynamic> data) {
    log('NotificationHandler: App update notification');

    if (_navigatorKey?.currentContext != null) {
      showDialog(
        context: _navigatorKey!.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('App Update Available'),
            content: const Text(
                'A new version of the app is available. Would you like to update now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle app update logic here
                  _openAppStore();
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Handle maintenance notification
  static void _handleMaintenanceNotification(Map<String, dynamic> data) {
    log('NotificationHandler: Maintenance notification');

    if (_navigatorKey?.currentContext != null) {
      showDialog(
        context: _navigatorKey!.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Scheduled Maintenance'),
            content: Text(data['message'] ??
                'The app will be under maintenance. Please check back later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Open app store for updates
  static void _openAppStore() {
    // Implement app store opening logic
    log('NotificationHandler: Opening app store for update');
    // You can use packages like url_launcher to open the app store
  }

  /// Clear all callbacks (useful for testing)
  static void clearCallbacks() {
    _notificationCallbacks.clear();
    _dataCallbacks.clear();
  }

  /// Create payload for notification
  static String createPayload({
    required String type,
    String? screen,
    Map<String, dynamic>? data,
  }) {
    final payload = <String, dynamic>{
      NotificationConfig.payloadTypeKey: type,
    };

    if (screen != null) {
      payload[NotificationConfig.payloadScreenKey] = screen;
    }

    if (data != null) {
      payload[NotificationConfig.payloadDataKey] = data;
    }

    return jsonEncode(payload);
  }
}
