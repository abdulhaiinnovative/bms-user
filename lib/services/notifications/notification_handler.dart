import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles notification taps and actions
class NotificationHandler {
  static final Map<String, VoidCallback> _notificationCallbacks = {};
  static final Map<String, Function(Map<String, dynamic>)> _dataCallbacks = {};
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Set the navigator key for navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> navKey) {
    navigatorKey = navKey;
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
    debugPrint('NotificationHandler: Tapped notification with payload: ${response.payload}');
    if (response.payload == null || response.payload!.isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> payload = jsonDecode(response.payload!);
      final String? type = payload[NotificationConfig.payloadTypeKey];
      final Map<String, dynamic>? data =
          payload[NotificationConfig.payloadDataKey];
      final String? screen = payload[NotificationConfig.payloadScreenKey];

      // Handle specific notification types
      bool hasNavigated = false;
      if (type != null) {
        hasNavigated = handleNotificationType(type, data ?? {});
      }

      // Navigate to specific screen if specified
      if (!hasNavigated && screen != null) {
        navigateToScreen(screen, data);
        hasNavigated = true;
      }

      // Handle URL/Link if present in data and we haven't navigated yet
      if (!hasNavigated && data != null) {
        final String? url = data['url'] ?? data['link'];
        if (url != null) {
          _launchURL(url);
          hasNavigated = true;
        }
      }

      // Final fallback: show dialog if nothing else worked
      if (!hasNavigated) {
        final String? title = payload[NotificationConfig.payloadTitleKey] ?? data?['title'];
        final String? body = payload[NotificationConfig.payloadBodyKey] ?? data?['body'] ?? data?['message'];
        
        if (title != null || body != null) {
          final context = navigatorKey?.currentContext;
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

      // Execute registered callbacks
      if (type != null && _notificationCallbacks.containsKey(type)) {
        _notificationCallbacks[type]!();
      }

      if (type != null && _dataCallbacks.containsKey(type) && data != null) {
        _dataCallbacks[type]!(data);
      }
    } catch (e) {}
  }

  /// Launch a URL
  static Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  /// Handle iOS foreground notification
  static void handleIOSForegroundNotification(
      int id, String? title, String? body, String? payload) {
    // For iOS, you might want to show a custom dialog or banner
    // when a notification is received while the app is in foreground
    if (navigatorKey?.currentContext != null) {
      _showForegroundNotificationDialog(
        navigatorKey!.currentContext!,
        title ?? 'Notification',
        body ?? '',
        payload,
      );
    }
  }

  /// Handle specific notification types
  static bool handleNotificationType(String type, Map<String, dynamic> data) {
    // Aggressively check for appointment ID to prioritize booking navigation
    final String? appointmentId = data['appointmentId']?.toString() ?? 
                                data['bookingId']?.toString() ??
                                data['id']?.toString();
                                
    if (appointmentId != null && (type == 'booking' || type == 'appointment' || type.contains('booking'))) {
      return _handleAppointmentNotification(data);
    }

    switch (type) {
      case NotificationConfig.appointmentNotificationType:
      case 'booking':
      case 'booking_sent':
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'notification': // Added to support generic notification type
        return _handleAppointmentNotification(data);
      case NotificationConfig.promoNotificationType:
        return _handlePromoNotification(data);
      case NotificationConfig.systemNotificationType:
        return _handleSystemNotification(data);
      case NotificationConfig.generalNotificationType:
        return _handleGeneralNotification(data);
      default:
        // Final fallback: if it looks like a booking but has wrong type
        if (appointmentId != null && data['url']?.toString().contains('booking') == true) {
          return _handleAppointmentNotification(data);
        }
        return false;
    }
  }

  /// Handle appointment notifications
  static bool _handleAppointmentNotification(Map<String, dynamic> data) {
    // Extract appointment-specific data
    String? appointmentId = 
        data['appointmentId']?.toString() ?? data['bookingId']?.toString();
    final String? action = data['action'];

    // If ID is missing, try to extract it from the URL
    if (appointmentId == null && (data['url'] != null || data['link'] != null)) {
      final String urlStr = (data['url'] ?? data['link']).toString();
      debugPrint('NotificationHandler: ID missing, attempting extraction from URL: $urlStr');
      try {
        final Uri uri = Uri.parse(urlStr);
        
        // Check all path segments for a numeric ID
        for (final segment in uri.pathSegments) {
          final id = int.tryParse(segment);
          if (id != null && id > 0) {
            appointmentId = segment;
            debugPrint('NotificationHandler: Found ID in URL segment: $appointmentId');
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
                debugPrint('NotificationHandler: Found ID in query parameter ($key): $appointmentId');
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('NotificationHandler: URL parsing error: $e');
      }
    }

    debugPrint('NotificationHandler: Final Appointment ID for navigation: $appointmentId');

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
      return true;
    }
    return false;
  }

  /// Handle promotional notifications
  static bool _handlePromoNotification(Map<String, dynamic> data) {
    final String? promoId = data['promoId'];
    final String? salonId = data['salonId'];

    // Navigate to appropriate promo screen
    if (promoId != null) {
      _navigateToPromoDetails(promoId, data);
      return true;
    } else if (salonId != null) {
      _navigateToSalonDetails(salonId);
      return true;
    } else {
      navigateToScreen(NotificationConfig.promoScreen, data);
      return true;
    }
  }

  /// Handle system notifications
  static bool _handleSystemNotification(Map<String, dynamic> data) {
    final String? action = data['action'];
    final String? screen = data['screen'];

    switch (action) {
      case 'update':
        _handleAppUpdate(data);
        return true;
      case 'maintenance':
        _handleMaintenanceNotification(data);
        return true;
      default:
        navigateToScreen(screen ?? NotificationConfig.homeScreen, data);
        return true;
    }
  }

  /// Handle general notifications
  static bool _handleGeneralNotification(Map<String, dynamic> data) {
    final String? screen = data['screen'];
    navigateToScreen(screen ?? NotificationConfig.homeScreen, data);
    return true;
  }

  /// Navigate to a specific screen
  static void navigateToScreen(String screen, Map<String, dynamic>? data) {
    debugPrint('NotificationHandler: Attempting to navigate to "$screen"');
    
    if (navigatorKey == null) {
      debugPrint('NotificationHandler: FAILED - navigatorKey is NULL. Make sure NotificationService.initialize(navigatorKey: ...) is called in main.dart');
      return;
    }

    if (navigatorKey?.currentState == null) {
      debugPrint('NotificationHandler: FAILED - navigatorKey.currentState is NULL. The navigator might not be mounted yet.');
      return;
    }

    try {
      debugPrint('NotificationHandler: Executing pushNamed for "$screen" with arguments: $data');
      navigatorKey!.currentState!.pushNamed(screen, arguments: data);
      debugPrint('NotificationHandler: pushNamed call completed');
    } catch (e) {
      debugPrint('NotificationHandler: Navigation exception occurred: $e');
      // Fallback to home screen if navigation fails
      try {
        debugPrint('NotificationHandler: Attempting fallback to home screen');
        navigatorKey!.currentState!.pushNamedAndRemoveUntil(
          NotificationConfig.homeScreen,
          (route) => false,
        );
      } catch (fallbackError) {
        debugPrint('NotificationHandler: Fallback failed: $fallbackError');
      }
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
    _navigateToAppointmentDetails(appointmentId);
  }

  /// Handle appointment confirmation
  static void _handleAppointmentConfirmation(
      String appointmentId, Map<String, dynamic> data) {
    _navigateToAppointmentDetails(appointmentId);
  }

  /// Handle appointment cancellation
  static void _handleAppointmentCancellation(
      String appointmentId, Map<String, dynamic> data) {
    _navigateToAppointmentDetails(appointmentId);
  }

  /// Navigate to appointment details
  static void _navigateToAppointmentDetails(String appointmentId) {
    navigateToScreen(NotificationConfig.appointmentScreen, {
      'appointmentId': appointmentId,
    });
  }

  /// Navigate to promo details
  static void _navigateToPromoDetails(
      String promoId, Map<String, dynamic> data) {
    navigateToScreen(NotificationConfig.promoScreen, {
      'promoId': promoId,
      ...data,
    });
  }

  /// Navigate to salon details
  static void _navigateToSalonDetails(String salonId) {
    navigateToScreen('/salon-details', {
      'salonId': salonId,
    });
  }

  /// Handle app update notification
  static void _handleAppUpdate(Map<String, dynamic> data) {
    if (navigatorKey?.currentContext != null) {
      showDialog(
        context: navigatorKey!.currentContext!,
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
    if (navigatorKey?.currentContext != null) {
      showDialog(
        context: navigatorKey!.currentContext!,
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
