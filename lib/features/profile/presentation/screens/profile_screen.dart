import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:app/services/fcm_token_service.dart';
import 'package:app/utlis/UtilsExtra.dart';
import '../viewmodels/profile_view_model.dart';
import 'my_account_screen.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<ProfileViewModel>().loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileViewModel>(
      builder: (context, authProvider, profileViewModel, child) {
        final isAuthenticated = authProvider.isAuthenticated;

        return Scaffold(
          backgroundColor: kScreenBg,
          appBar: AppBar(
            title: const Text(
              "Profile",
              style: TextStyle(
                color: kTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: isAuthenticated
              ? _buildAuthenticatedProfile(context, profileViewModel)
              : _buildGuestProfile(context),
        );
      },
    );
  }

  Widget _buildAuthenticatedProfile(
      BuildContext context, ProfileViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor.withOpacity(0.1),
                  kPrimaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: viewModel.userImage.isNotEmpty
                          ? NetworkImage(viewModel.userImage)
                          : null,
                      child: viewModel.userImage.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  Text(
                    viewModel.userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User Email
                  Text(
                    viewModel.userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        icon: Icons.event_available,
                        value: viewModel.appointmentCount.toString(),
                        label: 'Appointments',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      _buildStatCard(
                        icon: Icons.stars_rounded,
                        value: viewModel.loyaltyPoints.toString(),
                        label: 'Loyalty Points',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildModernMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: "My Account",
                  subtitle: "Manage your personal information",
                  onTap: () =>
                      Navigator.pushNamed(context, MyAccountScreen.routeName),
                ),
                _buildModernMenuItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  subtitle: "Manage your notification preferences",
                  onTap: () {},
                ),
                _buildModernMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  subtitle: "App settings and preferences",
                  onTap: () {},
                ),
                _buildModernMenuItem(
                  context: context,
                  icon: Icons.help_outline,
                  title: "Help Center",
                  subtitle: "Get help and support",
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Guest Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kPrimaryColor.withOpacity(0.2),
                      kPrimaryColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 60,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              const Text(
                'Welcome, Guest!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kTextColor,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Sign in to unlock all features and\nmanage your bookings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Login / Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Guest Features
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Member Benefits',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      icon: Icons.event_available,
                      text: 'Book and manage appointments',
                    ),
                    _buildBenefitItem(
                      icon: Icons.favorite_outline,
                      text: 'Save your favorite salons',
                    ),
                    _buildBenefitItem(
                      icon: Icons.card_giftcard,
                      text: 'Earn loyalty points & rewards',
                    ),
                    _buildBenefitItem(
                      icon: Icons.history,
                      text: 'View booking history',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kTextColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: kPrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red[100]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: Colors.red[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: kPrimaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
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
