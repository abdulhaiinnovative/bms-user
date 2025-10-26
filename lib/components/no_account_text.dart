import 'package:flutter/material.dart';

import '../constants.dart';

class NoAccountText extends StatelessWidget {
  final VoidCallback? onSignUpTap;

  const NoAccountText({
    Key? key,
    this.onSignUpTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: onSignUpTap ??
              () {
                // Fallback: Navigate back to auth screen
                Navigator.pop(context);
              },
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 16, color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
