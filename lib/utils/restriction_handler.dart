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
    if (completeStatus == null || completeStatus < 100) {
      await _handleIncompleteProfile(contextToUse);
      return false;
    }

    return true; // User can book
  }


  /// Handle restricted user - show dialog and logout
  // ==================== RESTRICTED USER ====================
  static Future<void> _handleRestrictedUser([BuildContext? context]) async {
    final contextToUse = context ?? _currentContext;
    if (contextToUse == null || _isShowingDialog) return;

    _isShowingDialog = true;

    try {
      final authProvider = Provider.of<AuthProvider>(contextToUse, listen: false);

      await showDialog(
        context: contextToUse,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.block_rounded, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Account Restricted',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account has been restricted and you have been logged out.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please contact support for assistance.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

      await authProvider.logout();

      if (contextToUse.mounted) {
        Navigator.of(contextToUse).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
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
    if (contextToUse == null || _isShowingDialog) return;

    _isShowingDialog = true;

    try {
      final authProvider = Provider.of<AuthProvider>(contextToUse, listen: false);

      await showDialog(
        context: contextToUse,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.pause_circle_outline, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              const Expanded(child: Text('Account Inactive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account is currently inactive and you have been logged out.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 22),
                      const SizedBox(width: 12),
                       Expanded(
                        child: Text(
                          'Please contact support to reactivate your account.',
                          style: TextStyle(fontSize: 14, color: Colors.orange.shade900, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

      await authProvider.logout();

      if (contextToUse.mounted) {
        Navigator.of(contextToUse).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
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
    final ctx = context ?? _currentContext;
    if (ctx == null || _isShowingDialog) return;

    _isShowingDialog = true;

    try {
      await showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (context) {
          final size = MediaQuery.of(context).size;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "Complete Your Profile",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            "Please complete your profile before booking. You need to add your personal details.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "OK",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _isShowingDialog = false;
    }
  }
}
