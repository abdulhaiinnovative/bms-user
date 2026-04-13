import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_response.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loginTimeKey = 'login_time';
  static const String _sessionExpiryKey = 'session_expiry';

  static const Duration _sessionDuration = Duration(hours: 24);

  static Future<bool> saveAuthData(AuthData authData) async {
    try {
      // Saving auth data (debug logs removed)
      final prefs = await SharedPreferences.getInstance();
      final currentTime = DateTime.now();
      final expiryTime = currentTime.add(_sessionDuration);

      if (authData.token != null) {
        // Saving token (debug logs removed)
        await prefs.setString(_tokenKey, authData.token!);
      } else {
        // No token to save (debug log removed)
      }

      if (authData.refreshToken != null) {
        // Saving refresh token (debug log removed)
        await prefs.setString(_refreshTokenKey, authData.refreshToken!);
      }

      if (authData.user != null) {
        // Saving user data (debug log removed)
        await prefs.setString(
            _userDataKey, jsonEncode(authData.user!.toJson()));
      } else {
        // No user data to save (debug log removed)
      }

      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setInt(_loginTimeKey, currentTime.millisecondsSinceEpoch);
      await prefs.setInt(_sessionExpiryKey, expiryTime.millisecondsSinceEpoch);

      // Auth data saved successfully (debug logs removed)
      return true;
    } catch (e) {
      // Error saving auth data (debug log removed)
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      // Error getting token (debug log removed)
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      // Error getting refresh token (debug log removed)
      return null;
    }
  }

  static Future<UserData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        final Map<String, dynamic> userJson = jsonDecode(userDataString);
        return UserData.fromJson(userJson);
      }

      return null;
    } catch (e) {
      // Error getting user data (debug log removed)
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      // Checking login status (debug log removed)
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final token = prefs.getString(_tokenKey);
      final sessionExpiry = prefs.getInt(_sessionExpiryKey);

      // Login check details (debug logs removed)

      if (!isLoggedIn || token == null || token.isEmpty) {
        // Login check failed: missing flag or token (debug log removed)
        return false;
      }

      if (sessionExpiry != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(sessionExpiry);
        final now = DateTime.now();
        // Session expiry check (debug logs removed)

        if (now.isAfter(expiryTime)) {
          // Session expired, clearing auth data (debug log removed)
          await clearAuthData();
          return false;
        }
      }

      // Login check passed (debug logs removed)
      return true;
    } catch (e) {
      // Error checking login status (debug log removed)
      return false;
    }
  }

  static Future<bool> clearAuthData() async {
    try {
      // Clearing auth data (debug logs removed)

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_loginTimeKey);
      await prefs.remove(_sessionExpiryKey);
      await prefs.setBool(_isLoggedInKey, false);

      // Auth data cleared successfully (debug logs removed)
      return true;
    } catch (e) {
      // Error clearing auth data (debug log removed)
      return false;
    }
  }

  static Future<bool> updateUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(userData.toJson()));
      return true;
    } catch (e) {
      // Error updating user data (debug log removed)
      return false;
    }
  }

  static Future<bool> extendSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (!isLoggedIn) {
        return false;
      }

      final newExpiryTime = DateTime.now().add(_sessionDuration);
      await prefs.setInt(
          _sessionExpiryKey, newExpiryTime.millisecondsSinceEpoch);

      return true;
    } catch (e) {
      // Error extending session (debug log removed)
      return false;
    }
  }

  static Future<Duration?> getSessionRemainingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionExpiry = prefs.getInt(_sessionExpiryKey);

      if (sessionExpiry != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(sessionExpiry);
        final now = DateTime.now();

        if (now.isBefore(expiryTime)) {
          return expiryTime.difference(now);
        }
      }

      return null;
    } catch (e) {
      // Error getting session remaining time (debug log removed)
      return null;
    }
  }

  static Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getToken();

    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }

    return null;
  }

  static Future<bool> isTokenExpired() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return true;
    }

    return false;
  }

  static Future<bool> refreshAuthToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      return false;
    } catch (e) {
      // Error refreshing token (debug log removed)
      return false;
    }
  }
}
