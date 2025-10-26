import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Service to handle Firebase Cloud Messaging (FCM) token operations
class FCMTokenService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _cachedToken;

  /// Get the FCM token for push notifications
  /// Returns null if permission is denied or token cannot be retrieved
  static Future<String?> getFCMToken() async {
    try {
      // Return cached token if available
      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        log('FCMTokenService: Returning cached FCM token');
        return _cachedToken;
      }

      // Request notification permissions
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log('FCMTokenService: Notification permission denied');
        return null;
      }

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        log('FCMTokenService: FCM Token retrieved: ${token.substring(0, 20)}...');
        return token;
      } else {
        log('FCMTokenService: Failed to retrieve FCM token');
        return null;
      }
    } catch (e) {
      log('FCMTokenService: Error getting FCM token - $e');
      return null;
    }
  }

  /// Listen for FCM token refresh
  /// Call this in your main.dart or app initialization
  static void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      log('FCMTokenService: Token refreshed: ${newToken.substring(0, 20)}...');
      _cachedToken = newToken;
      onTokenRefresh(newToken);
    });
  }

  /// Clear cached token (useful for logout)
  static void clearCachedToken() {
    _cachedToken = null;
    log('FCMTokenService: Cached token cleared');
  }

  /// Delete FCM token (useful for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _cachedToken = null;
      log('FCMTokenService: FCM token deleted');
    } catch (e) {
      log('FCMTokenService: Error deleting FCM token - $e');
    }
  }
}
