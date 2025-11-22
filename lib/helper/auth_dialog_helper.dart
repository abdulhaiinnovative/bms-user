import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';

/// Helper class to show authentication-required dialogs
/// Use this when a feature requires the user to be logged in
class AuthDialogHelper {
  /// Show a dialog asking the user to login or signup
  ///
  /// Parameters:
  /// - context: BuildContext for showing the dialog
  /// - title: Optional custom title (default: "Login Required")
  /// - message: Optional custom message
  /// - icon: Optional custom icon (default: Icons.favorite_border)
  static void showAuthRequiredDialog(
    BuildContext context, {
    String title = 'Login Required',
    String? message,
    IconData icon = Icons.lock_outline,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                icon,
                color: kPrimaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message ??
                'To access this feature, please login or create an account.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, AuthScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Login / Sign Up',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Check if an error message indicates an authentication issue
  static bool isAuthError(String? message) {
    if (message == null) return false;
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('login') ||
        lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('authentication') ||
        lowerMessage.contains('auth') ||
        lowerMessage.contains('token') ||
        lowerMessage.contains('please sign in');
  }

  /// Show appropriate error handling - dialog for auth errors, snackbar for others
  static void handleError(
    BuildContext context,
    String? errorMessage, {
    String? authDialogTitle,
    String? authDialogMessage,
    IconData? authDialogIcon,
  }) {
    if (isAuthError(errorMessage)) {
      showAuthRequiredDialog(
        context,
        title: authDialogTitle ?? 'Login Required',
        message: authDialogMessage,
        icon: authDialogIcon ?? Icons.lock_outline,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
