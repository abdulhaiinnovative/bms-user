import 'package:firebase_messaging/firebase_messaging.dart';

/// Service to handle Firebase Cloud Messaging (FCM) token operations
class FCMTokenService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? _cachedToken;

  /// Get the FCM token for push notifications
  /// Returns null if permission is denied or token cannot be retrieved
  static Future<String?> getFCMToken() async {
    try {
      // Return cached token if available
      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        return _cachedToken;
      }

      // Request notification permissions
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

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }

      // Get FCM token
      final token = await _firebaseMessaging.getToken();

      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        return token;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Listen for FCM token refresh
  /// Call this in your main.dart or app initialization
  static void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _cachedToken = newToken;
      onTokenRefresh(newToken);
    });
  }

  /// Clear cached token (useful for logout)
  static void clearCachedToken() {
    _cachedToken = null;
  }

  /// Delete FCM token (useful for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _cachedToken = null;
    } catch (e) {}
  }
}
