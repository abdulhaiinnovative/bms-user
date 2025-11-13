import 'dart:developer';
import 'package:app/screens/profile/components/account_boxes.dart';
import 'package:flutter/material.dart';

import '../../api_services/my_account_api.dart';
import '../../constants.dart';
import '../../models/my_account_response.dart';

class MyAccountScreen extends StatefulWidget {
  static String routeName = "/my_account";

  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  UserData? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    log('Fetching user profile...');
    final profileResponse = await MyAccountAPI().getMyAccount();

    if (profileResponse != null && profileResponse.response?.user != null) {
      setState(() {
        userData = profileResponse.response!.user!;
        isLoading = false;
      });
    } else {
      log('Failed to load user profile');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: kPrimaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
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
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
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
          : userData != null
              ? RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Profile Header Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFFAFAFA)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
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
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          kPrimaryColor,
                                          kPrimaryDarkColor
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimaryColor.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 112,
                                    width: 112,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      image: const DecorationImage(
                                        image: NetworkImage(logo),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            kPrimaryColor,
                                            kPrimaryDarkColor
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                kPrimaryColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
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
                                userData?.name ?? 'N/A',
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
                                      userData?.email ?? 'N/A',
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.event_available_rounded,
                                        label: 'Appointments',
                                        value: '${userData?.appointment ?? 0}',
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFF764ba2)
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.cancel_outlined,
                                        label: 'Cancelled',
                                        value: '${userData?.cancelCount ?? 0}',
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFf093fb),
                                            Color(0xFFf5576c)
                                          ],
                                        ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                value: userData?.phone ?? 'Not provided',
                                press: null,
                              ),
                              AccountBoxes(
                                icon: Icons.wc_rounded,
                                title: "Gender",
                                value: userData?.gender ?? 'Not specified',
                                press: null,
                              ),
                              AccountBoxes(
                                icon: Icons.cake_rounded,
                                title: "Date of Birth",
                                value: userData?.dob ?? 'Not provided',
                                press: null,
                              ),
                              AccountBoxes(
                                icon: Icons.location_on_rounded,
                                title: "Address",
                                value: userData?.address ?? 'Not provided',
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
                                value: userData?.completeStatus == 1
                                    ? 'Complete'
                                    : 'Incomplete',
                                press: null,
                                statusColor: userData?.completeStatus == 1
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
                        onPressed: loadProfile,
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
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
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
