import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import 'components/complete_profile_form.dart';
import 'package:app/models/UserIsAlreadyRegisteredModel.dart';
import '../../../data/models/social_auth_response.dart';

class CompleteProfileScreen extends StatelessWidget {
  static String routeName = "/complete_profile";

  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments - can be UserIsAlreadyRegisteredModel or Map for social auth
    final args = ModalRoute.of(context)!.settings.arguments;

    // Check if this is social auth or regular registration
    bool isSocialAuth = false;
    SocialUserData? socialUser;
    UserIsAlreadyRegisteredModel? regularUser;
    String? email;

    if (args is Map<String, dynamic>) {
      // Social auth flow
      isSocialAuth = args['isSocialAuth'] ?? false;
      socialUser = args['socialUser'] as SocialUserData?;
      email = args['email'] as String?;
    } else if (args is UserIsAlreadyRegisteredModel) {
      // Regular registration flow
      regularUser = args;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile", style: headingStyle),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Complete your details and continue",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CompleteProfileForm(
                      user: regularUser,
                      isSocialAuth: isSocialAuth,
                      socialUser: socialUser,
                      email: email,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "By continuing you confirm that you agree \nwith our Terms and Conditions",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
