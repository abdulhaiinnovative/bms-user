import 'dart:io';

import '../widgets/account_boxes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/constants.dart';
import '../viewmodels/profile_view_model.dart';
import '../../../../screens/profile/edit_profile_screen.dart';

class MyAccountScreen extends StatefulWidget {
  static String routeName = "/my_account";

  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: kScreenBg,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              "My Account",
              style: TextStyle(
                color: kTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: kPrimaryColor,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile');
                },
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          body: viewModel.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading profile...',
                        style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : viewModel.hasProfileData
                  ? RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () => viewModel.refreshProfile(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Profile Header Section
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  // Profile Picture
                                  // Profile Picture
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Glow background
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kPrimaryColor.withOpacity(0.15),
                                        ),
                                      ),

                                      // Actual Image Container
                                      Container(
                                        height: 112,
                                        width: 112,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 4),
                                        ),
                                        child: ClipOval(
                                          child: Builder(
                                            builder: (context) {
                                              final imageUrl = viewModel.userImage;

                                              // Case 1: Valid Network URL
                                              if (imageUrl.isNotEmpty &&
                                                  (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
                                                return Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.person, size: 55, color: Colors.grey);
                                                  },
                                                );
                                              }
                                              // Case 2: Local file path (after upload)
                                              else if (imageUrl.isNotEmpty && imageUrl.startsWith('file://')) {
                                                final filePath = imageUrl.replaceFirst('file://', '');
                                                return Image.file(
                                                  File(filePath),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.person, size: 55, color: Colors.grey);
                                                  },
                                                );
                                              }
                                              // Case 3: No image
                                              else {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 55,
                                                  color: Colors.grey,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),

                                      // Camera Icon
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 3),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                  const SizedBox(height: 6),
                                  // User Email
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 14,
                                          color: kPrimaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          viewModel.userEmail,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Stats Cards
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            viewModel,
                                            icon: Icons.event_available_rounded,
                                            label: 'Appointments',
                                            value:
                                                '${viewModel.appointmentCount}',
                                            cardColor: const Color(0xFF667eea),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Personal Information Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AccountBoxes(
                                    icon: Icons.phone_rounded,
                                    title: "Phone Number",
                                    value: viewModel.userPhone.isNotEmpty
                                        ? viewModel.userPhone
                                        : 'Not provided',
                                    press: null,
                                  ),
                                  AccountBoxes(
                                    icon: Icons.wc_rounded,
                                    title: "Gender",
                                    value: viewModel.userData?.gender ??
                                        'Not specified',
                                    press: null,
                                  ),
                                  AccountBoxes(
                                    icon: Icons.cake_rounded,
                                    title: "Date of Birth",
                                    value: viewModel.userData?.dob ??
                                        'Not provided',
                                    press: null,
                                  ),
                                  AccountBoxes(
                                    icon: Icons.location_on_rounded,
                                    title: "Address",
                                    value: viewModel.hasAddress
                                        ? viewModel.fullAddress
                                        : 'Not provided',
                                    press: null,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Account Status',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AccountBoxes(
                                    icon: Icons.check_circle_outline_rounded,
                                    title: "Profile Completion",
                                    value: viewModel.isProfileComplete
                                        ? 'Complete'
                                        : 'Incomplete',
                                    press: null,
                                    statusColor: viewModel.isProfileComplete
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              size: 60,
                              color: kSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Failed to load profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please try again later",
                            style: TextStyle(
                              fontSize: 14,
                              color: kSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => viewModel.refreshProfile(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildStatCard(
    ProfileViewModel viewModel, {
    required IconData icon,
    required String label,
    required String value,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
