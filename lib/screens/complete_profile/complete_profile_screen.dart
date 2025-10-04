import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/complete_profile_form.dart';
import 'package:app/models/UserIsAlreadyRegisteredModel.dart';

class CompleteProfileScreen extends StatelessWidget {
  static String routeName = "/complete_profile";

  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userIsAlreadyRegisteredModel =
    ModalRoute.of(context)!.settings.arguments as UserIsAlreadyRegisteredModel;

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
                    CompleteProfileForm(user: userIsAlreadyRegisteredModel,),
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
