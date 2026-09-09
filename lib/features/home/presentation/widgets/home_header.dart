// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'package:app/features/search/presentation/screens/search_service_screen_new.dart';
// import 'package:app/providers/cart_provider.dart';
// import 'package:app/screens/cart/cart_screen.dart';
// import 'package:app/constants.dart';
// import 'search_field.dart';
// import 'notification_bell_button.dart';
//
// class HomeHeader extends StatelessWidget {
//   final TextEditingController searchController = TextEditingController();
//
//   HomeHeader({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           //Expanded(child: SearchField(controller: searchController,)),
//           Expanded(
//             child: InkWell(
//               onTap: () {
//                 // your on press action (debug log removed)
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SearchServiceScreenNew(),
//                     settings: const RouteSettings(arguments: {
//                       'isFromBottomNav': true,
//                     }),
//                   ),
//                 );
//               },
//               child: IgnorePointer(
//                 // prevents actual text input
//                 child: SearchField(
//                   controller: searchController,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Cart icon with badge
//           Consumer<CartProvider>(
//             builder: (context, cart, child) {
//               return Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.shopping_cart_outlined),
//                     color: kPrimaryDarkColor,
//                     iconSize: 24,
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const CartScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   if (cart.itemCount > 0)
//                     Positioned(
//                       right: 6,
//                       top: 6,
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         constraints: const BoxConstraints(
//                           minWidth: 18,
//                           minHeight: 18,
//                         ),
//                         child: Text(
//                           cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//
//           ),
//           const SizedBox(width: 8),
//           // Notification bell with unread badge
//           const NotificationBellButton(),
//         ],
//       ),
//     );
//   }
// }
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

  HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchServiceScreenNew(),
                  settings: const RouteSettings(
                      arguments: {'isFromBottomNav': true}),
                ),
              ),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search salons, services...',
                        style:
                        TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Cart button
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                child: _HeaderIconButton(
                  icon: Icons.shopping_bag_outlined,
                  badge: cart.itemCount > 0
                      ? (cart.itemCount > 9 ? '9+' : '${cart.itemCount}')
                      : null,
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // Notification bell
          const NotificationBellButton(),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;

  const _HeaderIconButton({required this.icon, this.badge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          if (badge != null)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints:
                const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}