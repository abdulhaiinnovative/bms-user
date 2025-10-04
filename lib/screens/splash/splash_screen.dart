import 'dart:developer';

import 'package:app/screens/CategoryDetailsFetchAPIData.dart';
import 'package:app/screens/sign_in/sign_in_screen_b.dart';
import 'package:app/utlis/UtilsExtra.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/home/home_screen.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import '../../api_services/MyBookingsAPI.dart';
import '../../constants.dart';
import '../SalonFetchAPIData.dart';
import '../init_screen.dart';
import '../sign_in/sign_in_screen.dart';
import '../test_scroll/salon_category_and_services_list.dart';
import 'components/splash_content.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to BookMySpot\nSalon Booking Made Easy.",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8XxUpkWBocLNW6KTNJnZV1Gb-giGiQ5m77g&usqp=CAU"
    },
    {
      "text":
          "Ready to Pamper Yourself?\nBook Your Spot Today!",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQen7imq0ciJkw88dNfhtnah86obuK7ed23aA&usqp=CAU"
    },
    {
      "text": "Book My Spot\nWhere Style Meets Convenience!",
      "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQen7imq0ciJkw88dNfhtnah86obuK7ed23aA&usqp=CAU"
    },
  ];

  @override
  void initState() {
    super.initState();
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
                        onPressed: () async {


                           log('============ ${await UtilsExtra.getToken()}');

                           // Navigator.pushNamed(context, SignInScreenB.routeName);

                           UtilsExtra.clearUserDetails();

                          if(await UtilsExtra.getUserDetails() != null){
                            Navigator.pushNamed(context, InitScreen.routeName);
                            //Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName);
                          }else{
                            Navigator.pushNamed(context, SignInScreenB.routeName);
                          }


                          //
                          // Navigator.pushNamed(context, InitScreen.routeName);

                          // Navigator.pushNamed(context, SalonFetchAPIData.routeName);
                          //Navigator.pushNamed(context, CategoryDetailsFetchAPIData.routeName);

                          //Navigator.pushNamed(context, SearchFetchAPIData.routeName);





                        },
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
