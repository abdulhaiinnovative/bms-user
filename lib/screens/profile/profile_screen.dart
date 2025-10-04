import 'package:app/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';

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
              press: () => {
              Navigator.pushNamed(context, MyAccountScreen.routeName)
              },
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
              press: () {

                UtilsExtra.clearUserDetails();
                Navigator.pushNamed(context, SplashScreen.routeName);

              },
            ),
          ],
        ),
      ),
    );
  }
}
