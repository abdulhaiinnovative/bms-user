import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/auth_response.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final currentTime = DateTime.now();
      final expiryTime = currentTime.add(_sessionDuration);
      
      if (authData.token != null) {
        await prefs.setString(_tokenKey, authData.token!);
      }
      
      if (authData.refreshToken != null) {
        await prefs.setString(_refreshTokenKey, authData.refreshToken!);
      }
      
      if (authData.user != null) {
        await prefs.setString(_userDataKey, jsonEncode(authData.user!.toJson()));
      }
      
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setInt(_loginTimeKey, currentTime.millisecondsSinceEpoch);
      await prefs.setInt(_sessionExpiryKey, expiryTime.millisecondsSinceEpoch);
      
      return true;
    } catch (e) {
      print('AuthManager: Error saving auth data - $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('AuthManager: Error getting token - $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('AuthManager: Error getting refresh token - $e');
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
      print('AuthManager: Error getting user data - $e');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final token = prefs.getString(_tokenKey);
      final sessionExpiry = prefs.getInt(_sessionExpiryKey);
      
      if (!isLoggedIn || token == null || token.isEmpty) {
        return false;
      }
      
      if (sessionExpiry != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(sessionExpiry);
        if (DateTime.now().isAfter(expiryTime)) {
          await clearAuthData();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('AuthManager: Error checking login status - $e');
      return false;
    }
  }

  static Future<bool> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_loginTimeKey);
      await prefs.remove(_sessionExpiryKey);
      await prefs.setBool(_isLoggedInKey, false);
      
      return true;
    } catch (e) {
      print('AuthManager: Error clearing auth data - $e');
      return false;
    }
  }

  static Future<bool> updateUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(userData.toJson()));
      return true;
    } catch (e) {
      print('AuthManager: Error updating user data - $e');
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
      await prefs.setInt(_sessionExpiryKey, newExpiryTime.millisecondsSinceEpoch);
      
      return true;
    } catch (e) {
      print('AuthManager: Error extending session - $e');
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
      print('AuthManager: Error getting session remaining time - $e');
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
      print('AuthManager: Error refreshing token - $e');
      return false;
    }
  }
}
