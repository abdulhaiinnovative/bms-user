import 'package:flutter/material.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:provider/provider.dart';

/// Handles user restriction checks and logout
class RestrictionHandler {
  static BuildContext? _currentContext;
  static bool _isShowingDialog = false;

  /// Initialize with the current app context
  static void initialize(BuildContext context) {
    _currentContext = context;
  }

  /// Check if user is restricted and handle accordingly
  static Future<void> checkRestriction(int? isRestricted) async {
    if (isRestricted == null || isRestricted != 1) {
      return; // User is not restricted
    }

    // User is restricted, handle logout
    await _handleRestrictedUser();
  }

  /// Check if user account is inactive and handle accordingly
  static Future<void> checkStatus(int? status) async {
    if (status == null || status == 1) {
      return; // User is active (status == 1 means active)
    }

    // User is inactive, handle logout
    await _handleInactiveUser();
  }

  /// Check both restriction and status
  static Future<void> checkUserAccess({
    int? isRestricted,
    int? status,
  }) async {
    // Check restriction first
    if (isRestricted != null && isRestricted == 1) {
      await _handleRestrictedUser();
      return;
    }

    // Then check status
    if (status != null && status != 1) {
      await _handleInactiveUser();
      return;
    }
  }

  /// Validate user can perform booking (returns true if allowed)
  static Future<bool> canUserBook({
    required int? isRestricted,
    required int? status,
    int? completeStatus,
    BuildContext? context,
  }) async {
    // Use provided context if available, otherwise use stored context
    final contextToUse = context ?? _currentContext;

    // Check if restricted
    if (isRestricted != null && isRestricted == 1) {
      await _handleRestrictedUser(contextToUse);
      return false;
    }

    // Check if inactive
    if (status == null || status != 1) {
      await _handleInactiveUser(contextToUse);
      return false;
    }

    // Check if profile is incomplete
    if (completeStatus == null || completeStatus != 1) {
      await _handleIncompleteProfile(contextToUse);
      return false;
    }

    return true; // User can book
  }

  /// Handle restricted user - show dialog and logout
  static Future<void> _handleRestrictedUser([BuildContext? context]) async {
    final contextToUse = context ?? _currentContext;

    if (contextToUse == null || _isShowingDialog) {
      return;
    }

    _isShowingDialog = true;

    try {
      // Get auth provider
      final authProvider =
          Provider.of<AuthProvider>(contextToUse, listen: false);

      // Show restriction dialog
      await showDialog(
        context: contextToUse,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Restricted',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account has been restricted and you have been logged out.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please contact support for assistance.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Logout user
      await authProvider.logout();

      // Navigate to login screen and clear all routes
      if (contextToUse.mounted) {
        Navigator.of(contextToUse).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error handling restricted user: $e');
    } finally {
      _isShowingDialog = false;
    }
  }

  /// Handle inactive user - show dialog and logout
  static Future<void> _handleInactiveUser([BuildContext? context]) async {
    final contextToUse = context ?? _currentContext;

    if (contextToUse == null || _isShowingDialog) {
      return;
    }

    _isShowingDialog = true;

    try {
      // Get auth provider
      final authProvider =
          Provider.of<AuthProvider>(contextToUse, listen: false);

      // Show inactive account dialog
      await showDialog(
        context: contextToUse,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.pause_circle_outline,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Inactive',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account is currently inactive and you have been logged out.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please contact support to reactivate your account.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Logout user
      await authProvider.logout();

      // Navigate to login screen and clear all routes
      if (contextToUse.mounted) {
        Navigator.of(contextToUse).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error handling inactive user: $e');
    } finally {
      _isShowingDialog = false;
    }
  }

  /// Handle incomplete profile - show dialog to complete profile
  static Future<void> _handleIncompleteProfile([BuildContext? context]) async {
    final contextToUse = context ?? _currentContext;

    if (contextToUse == null || _isShowingDialog) {
      return;
    }

    _isShowingDialog = true;

    try {
      // Show incomplete profile dialog
      await showDialog(
        context: contextToUse,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please complete your profile to proceed with booking.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You need to add your personal details before making a booking.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error handling incomplete profile: $e');
    } finally {
      _isShowingDialog = false;
    }
  }
}
