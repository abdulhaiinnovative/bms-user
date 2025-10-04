import 'dart:developer';
import 'package:app/screens/profile/components/account_boxes.dart';
import 'package:flutter/material.dart';

import '../../api_services/my_account_api.dart';
import '../../models/my_account_response.dart';
import '../profile/components/profile_menu.dart';
import '../profile/components/profile_pic.dart';

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
      appBar: AppBar(
        title: const Text("My Account"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic("assets/images/logo.png"),
            const SizedBox(height: 20),
            AccountBoxes(
              title: "Name",
              value: "${userData?.name ?? 'N/A'}",
              press: null,
            ),
            AccountBoxes(
              title: "Email",
              value: "${userData?.email ?? 'N/A'}",
              press: null,
            ),
            AccountBoxes(
              title: "Phone",
              value: "${userData?.phone ?? 'N/A'}",
              press: null,
            ),
            AccountBoxes(
              title: "Gender",
              value: "${userData?.gender ?? 'N/A'}",
              press: null,
            ),
            AccountBoxes(
              title: "DOB",
              value: "${userData?.dob ?? 'N/A'}",
              press: null,
            ),

            AccountBoxes(
              title: "Address",
              value: "${userData?.address ?? 'N/A'}",
              press: null,
            ),

            AccountBoxes(
              title: "Appointment",
              value: "${userData?.appointment ?? 'N/A'}",
              press: null,
            ),

            AccountBoxes(
              title: "Cancel Count",
              value: "${userData?.cancelCount ?? 'N/A'}",
              press: null,
            ),

            AccountBoxes(
              title: "Complete Status",
              value: "${userData?.completeStatus ?? 'N/A'}",
              press: null,
            ),

          ],
        ),
      )
          : const Center(child: Text("Failed to load profile")),
    );
  }
}
