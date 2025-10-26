import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_manager.dart';

class AuthMiddleware {
  static Timer? _sessionTimer;
  static VoidCallback? _onSessionExpired;
  static VoidCallback? _onSessionWarning;

  static const Duration _warningDuration = Duration(minutes: 5);

  static void initializeSessionMonitoring({
    VoidCallback? onSessionExpired,
    VoidCallback? onSessionWarning,
  }) {
    _onSessionExpired = onSessionExpired;
    _onSessionWarning = onSessionWarning;

    _startSessionTimer();
  }

  static void _startSessionTimer() {
    _sessionTimer?.cancel();

    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        final remainingTime = await AuthManager.getSessionRemainingTime();

        if (remainingTime == null) {
          _handleSessionExpired();
          return;
        }

        if (remainingTime <= Duration.zero) {
          _handleSessionExpired();
        } else if (remainingTime <= _warningDuration) {
          _handleSessionWarning();
        }
      },
    );
  }

  static void _handleSessionExpired() {
    _sessionTimer?.cancel();
    _onSessionExpired?.call();
  }

  static void _handleSessionWarning() {
    _onSessionWarning?.call();
  }

  static Future<bool> extendSessionOnActivity() async {
    final isLoggedIn = await AuthManager.isLoggedIn();

    if (isLoggedIn) {
      final extended = await AuthManager.extendSession();
      if (extended) {
        _startSessionTimer();
        return true;
      }
    }

    return false;
  }

  static void stopSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  static Future<bool> validateCurrentSession() async {
    final isLoggedIn = await AuthManager.isLoggedIn();

    if (!isLoggedIn) {
      _handleSessionExpired();
      return false;
    }

    return true;
  }

  static Future<void> handleAppResume() async {
    final isValid = await validateCurrentSession();

    if (isValid) {
      _startSessionTimer();
    }
  }

  static void handleAppPause() {
    _sessionTimer?.cancel();
  }

  static Future<SessionStatus> getSessionStatus() async {
    final isLoggedIn = await AuthManager.isLoggedIn();

    if (!isLoggedIn) {
      return SessionStatus(
        isValid: false,
        remainingTime: null,
        needsWarning: false,
      );
    }

    final remainingTime = await AuthManager.getSessionRemainingTime();

    if (remainingTime == null || remainingTime <= Duration.zero) {
      return SessionStatus(
        isValid: false,
        remainingTime: null,
        needsWarning: false,
      );
    }

    return SessionStatus(
      isValid: true,
      remainingTime: remainingTime,
      needsWarning: remainingTime <= _warningDuration,
    );
  }

  static void dispose() {
    stopSessionMonitoring();
    _onSessionExpired = null;
    _onSessionWarning = null;
  }
}

class SessionStatus {
  final bool isValid;
  final Duration? remainingTime;
  final bool needsWarning;

  SessionStatus({
    required this.isValid,
    this.remainingTime,
    required this.needsWarning,
  });

  String get remainingTimeFormatted {
    if (remainingTime == null) return 'Session expired';

    final hours = remainingTime!.inHours;
    final minutes = remainingTime!.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
