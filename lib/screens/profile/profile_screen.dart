import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import '../../providers/auth/auth_provider.dart';
import '../../screens/auth/auth_screen.dart';
import '../../services/fcm_token_service.dart';
import '../../utlis/UtilsExtra.dart';
import 'components/profile_menu.dart';
import 'components/profile_pic.dart';
import 'my_account_screen.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(logo),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: "assets/icons/User Icon.svg",
              press: () =>
                  {Navigator.pushNamed(context, MyAccountScreen.routeName)},
            ),
            ProfileMenu(
              text: "Notifications",
              icon: "assets/icons/Bell.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Settings",
              icon: "assets/icons/Settings.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Help Center",
              icon: "assets/icons/Question mark.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icons/Log out.svg",
              press: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle logout functionality
  Future<void> _handleLogout(BuildContext context) async {
    developer.log('🔴 ProfileScreen: Logout initiated');

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      developer.log('🔴 ProfileScreen: Logout cancelled by user');
      return;
    }

    // Show loading indicator
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      developer.log('🔴 ProfileScreen: Starting logout process...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 1. Sign out from Google (if logged in via Google)
      developer.log('🔴 ProfileScreen: Signing out from Google...');
      await authProvider.signOutGoogle();

      // 2. Clear FCM token
      developer.log('🔴 ProfileScreen: Clearing FCM token...');
      await FCMTokenService.deleteToken();

      // 3. Logout from auth provider (clears AuthManager data)
      developer.log('🔴 ProfileScreen: Clearing auth data...');
      final logoutSuccess = await authProvider.logout();

      // 4. Clear old user details (backward compatibility)
      developer.log('🔴 ProfileScreen: Clearing legacy user data...');
      await UtilsExtra.clearUserDetails();

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (logoutSuccess) {
        developer.log(
            '✅ ProfileScreen: Logout successful, navigating to auth screen');

        // Navigate to auth screen and clear all routes
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AuthScreen.routeName,
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        developer.log('❌ ProfileScreen: Logout failed');

        // Show error if logout failed
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      developer.log('❌ ProfileScreen: Logout error - $e');

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show error message
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
