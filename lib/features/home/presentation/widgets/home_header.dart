import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/features/search/presentation/screens/search_service_screen_new.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/screens/cart/cart_screen.dart';
import 'package:app/constants.dart';
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
                // your on press action (debug log removed)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchServiceScreenNew(),
                    settings: const RouteSettings(arguments: {
                      'isFromBottomNav': true,
                    }),
                  ),
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
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: kPrimaryDarkColor,
                    iconSize: 24,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          // Notification bell with unread badge
          const NotificationBellButton(),
        ],
      ),
    );
  }
}
