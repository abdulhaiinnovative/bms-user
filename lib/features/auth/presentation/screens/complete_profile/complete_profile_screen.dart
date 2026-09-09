import 'package:flutter/material.dart';
import 'components/complete_profile_form.dart';
import 'package:app/models/UserIsAlreadyRegisteredModel.dart';
import '../../../data/models/social_auth_response.dart';

class CompleteProfileScreen extends StatelessWidget {
  static String routeName = "/complete_profile";

  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments - can be UserIsAlreadyRegisteredModel or Map for social auth
    final args = ModalRoute.of(context)?.settings.arguments;

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
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Top button - same styling as AuthScreen
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Header Text - match AuthScreen typography
                  const Text(
                    "Almost There",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Complete your profile to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form
                  CompleteProfileForm(
                    user: regularUser,
                    isSocialAuth: isSocialAuth,
                    socialUser: socialUser,
                    email: email,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
