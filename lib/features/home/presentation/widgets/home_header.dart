import 'package:flutter/material.dart';

import 'package:app/screens/search_final/search_service_screen_new.dart';
import 'search_field.dart';
import 'notification_bell_button.dart';

class HomeHeader extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //Expanded(child: SearchField(controller: searchController,)),
          Expanded(
            child: InkWell(
              onTap: () {
                // your on press action
                print("SearchField tapped");
                Navigator.pushNamed(
                  context,
                  SearchServiceScreenNew.routeName,
                  arguments: {
                    'isFromBottomNav': true,
                  },
                );
              },
              child: IgnorePointer(
                // prevents actual text input
                child: SearchField(
                  controller: searchController,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // IconBtnWithCounter(
          //   svgSrc: "assets/icons/Cart Icon.svg",
          //   press: () => Navigator.pushNamed(context, CartScreen.routeName),
          // ),
          const SizedBox(width: 8),
          // Notification bell with unread badge
          const NotificationBellButton(),
        ],
      ),
    );
  }
}
