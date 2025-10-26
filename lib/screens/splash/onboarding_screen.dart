import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/utlis/UtilsExtra.dart';
import '../../constants.dart';
import '../init_screen.dart';
import '../auth/auth_screen.dart';
import 'components/splash_content.dart';

class OnboardingScreen extends StatefulWidget {
  static String routeName = "/onboarding";

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to BookMySpot\nSalon Booking Made Easy.",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8XxUpkWBocLNW6KTNJnZV1Gb-giGiQ5m77g&usqp=CAU"
    },
    {
      "text": "Ready to Pamper Yourself?\nBook Your Spot Today!",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQen7imq0ciJkw88dNfhtnah86obuK7ed23aA&usqp=CAU"
    },
    {
      "text": "Book My Spot\nWhere Style Meets Convenience!",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQen7imq0ciJkw88dNfhtnah86obuK7ed23aA&usqp=CAU"
    },
  ];

  Future<void> _completeOnboarding() async {
    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    // Check if user is logged in
    log('============ ${await UtilsExtra.getToken()}');
    final userDetails = await UtilsExtra.getUserDetails();

    if (!mounted) return;

    if (userDetails != null) {
      Navigator.pushReplacementNamed(context, InitScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, AuthScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: kAnimationDuration,
                            margin: const EdgeInsets.only(right: 5),
                            height: 6,
                            width: currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? kPrimaryColor
                                  : const Color(0xFFD8D8D8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      ElevatedButton(
                        onPressed: _completeOnboarding,
                        child: const Text("Continue"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
