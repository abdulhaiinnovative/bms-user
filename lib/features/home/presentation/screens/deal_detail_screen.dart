// import 'package:app/models/home/SalonData.dart';
// import 'package:flutter/material.dart';
// import 'package:app/models/HomePageResponse.dart';
// import 'package:app/constants.dart';
// import 'package:provider/provider.dart';
// import '../../../../providers/cart_provider.dart';
// import '../../../../components/cart_bottom_bar.dart';

// class DealDetailScreen extends StatefulWidget {
//   final Deal deal;
//   final SalonData? salon;

//   const DealDetailScreen({Key? key, required this.deal, this.salon}) : super(key: key);

//   @override
//   State<DealDetailScreen> createState() => _DealDetailScreenState();
// }

// class _DealDetailScreenState extends State<DealDetailScreen> {

//   @override
//   Widget build(BuildContext context) {
//     final deal = widget.deal;

//     return Scaffold(
//       backgroundColor: kScreenBg,
//       appBar: AppBar(
//         title: const Text('Deal Details'),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),

//       bottomNavigationBar: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const CartBottomBar(),
//           _buildBookButton(deal),
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(bottom: 80),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [


//             if (widget.salon != null)
//               _buildSalonSection(widget.salon!),
//             // Deal details card (image, name, price, discount)
//             _buildDetailsCard(deal),


//             // Services included in the deal
//             if (deal.services != null && deal.services!.isNotEmpty)
//               _buildServicesSection(deal),

//             // if (deal.description != null && deal.description!.isNotEmpty)
//             //   _buildDescriptionSection(deal.description!),
//           ],
//         ),
//       ),
//     );
//   }

//   /// 🔥 MAIN CARD
//   Widget _buildDetailsCard(Deal deal) {
//     final bool hasDiscount = deal.discountValue != null && deal.discountValue != 0;

//     final int oldPrice = deal.discountType == 'amount'
//         ? (deal.price ?? 0) + (deal.discountValue ?? 0)
//         : ((deal.price ?? 0) +
//         ((deal.price ?? 0) * (deal.discountValue ?? 0) / 100))
//         .toInt();

//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           /// IMAGE
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(22),
//             ),
//             child: Image.network(
//               deal.image ?? '',
//               width: double.infinity,
//               height: 180,
//               fit: BoxFit.cover,
//             ),
//           ),

//           /// CONTENT
//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 /// TITLE + DISCOUNT
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         deal.name ?? '',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),

//                     if (hasDiscount)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: Colors.red.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           deal.discountType == 'amount'
//                               ? 'Rs ${deal.discountValue} OFF'
//                               : '${deal.discountValue}% OFF',
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),

//                 const SizedBox(height: 7),

//                 /// PRICE
//                 Row(
//                   children: [
//                     Text(
//                       'PKR ${deal.price ?? 0}',
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         color: kPrimaryColor,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     if (hasDiscount)
//                       Text(
//                         'PKR $oldPrice',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[500],
//                           decoration: TextDecoration.lineThrough,
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 🔥 SERVICES LIST
//   Widget _buildServicesSection(Deal deal) {
//     return _sectionWrapper(
//       title: "Services Included",
//       child: Column(
//         children: deal.services!.map((s) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle, size: 16, color: kPrimaryColor),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     s.name ?? '',
//                     style: const TextStyle(fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }


//   /// 🔥 SALON
//   Widget _buildSalonSection(SalonData salon) {
//     final String? logo = salon.logo;
//     final String? image = salon.image;
//     final String? name = salon.name;
//     final String? address = salon.address;

//     final String? finalImage =
//     (logo != null && logo.isNotEmpty)
//         ? logo
//         : (image != null && image.isNotEmpty)
//         ? image
//         : null;

//     return _sectionWrapper(
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: finalImage != null
//                 ? Image.network(
//               finalImage,
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => _fallbackSalonIcon(),
//             )
//                 : _fallbackSalonIcon(),
//           ),
//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name?.isNotEmpty == true ? name! : 'Salon',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   address?.isNotEmpty == true ? address! : 'No address available',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//   Widget _fallbackSalonIcon() {
//     return Container(
//       width: 60,
//       height: 60,
//       color: Colors.grey[200],
//       child: const Icon(Icons.store, color: Colors.grey),
//     );
//   }

//   /// 🔥 WRAPPER
//   Widget _sectionWrapper({String? title, required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 15,
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (title != null) ...[
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//           child,
//         ],
//       ),
//     );
//   }

//   /// 🔥 BUTTON
//   Widget _buildBookButton(Deal deal) {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Consumer<CartProvider>(
//           builder: (context, cart, child) {
//             final isInCart = cart.isInCart(deal);

//             return SizedBox(
//               height: 52,
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   cart.toggleItem(deal);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isInCart ? Colors.grey : kPrimaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: Text(
//                   isInCart ? "Added" : "Book Now",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:app/models/home/SalonData.dart';
import 'package:flutter/material.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/constants.dart';
import 'package:provider/provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../components/cart_bottom_bar.dart';
import 'package:app/features/auth/utils/auth_manager.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;
  final SalonData? salon;

  const DealDetailScreen({Key? key, required this.deal, this.salon})
      : super(key: key);

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  Future<void> _proceedToBooking() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.itemCount == 0) return;

    final token = await AuthManager.getToken();
    if (token == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'Please sign in to proceed with booking.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
            ],
          );
        },
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectProfessionals(),
        settings: RouteSettings(
          arguments: {
            'cartItems': cartProvider.items,
            'salonName': cartProvider.salonName,
            'salonId': cartProvider.salonId,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;

    return Scaffold(
      backgroundColor: kScreenBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            radius: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CartBottomBar(onProceed: _proceedToBooking, buttonText: 'View Cart', proceedButtonText: 'Proceed to Booking'),
          _buildBookButton(deal),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero + deal info fused ──
            _buildHeroCard(deal),

            const SizedBox(height: 4),

            // ── Salon ──
            if (widget.salon != null) _buildSalonSection(widget.salon!),

            // ── Services included ──
            if (deal.services != null && deal.services!.isNotEmpty)
              _buildServicesSection(deal),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HERO CARD
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(Deal deal) {
    final bool hasDiscount =
        deal.discountValue != null && deal.discountValue != 0;

    final int oldPrice = deal.discountType == 'amount'
        ? (deal.price ?? 0) + (deal.discountValue ?? 0)
        : ((deal.price ?? 0) +
                ((deal.price ?? 0) * (deal.discountValue ?? 0) / 100))
            .toInt();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero image ──────────────────────────────────────────────
          Stack(
            children: [
              Image.network(
                deal.image ?? '',
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image_outlined,
                      size: 48, color: Colors.grey),
                ),
              ),
              // gradient scrim
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // discount pill
              if (hasDiscount)
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      deal.discountType == 'amount'
                          ? 'Rs ${deal.discountValue} OFF'
                          : '${deal.discountValue}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Deal name + price ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_offer_rounded,
                      color: kPrimaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    deal.name ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Price ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'PKR ${deal.price ?? 0}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryColor,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 10),
                  Text(
                    'PKR $oldPrice',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SALON SECTION
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildSalonSection(SalonData salon) {
    final String? finalImage =
        (salon.logo != null && salon.logo!.isNotEmpty)
            ? salon.logo
            : (salon.image != null && salon.image!.isNotEmpty)
                ? salon.image
                : null;

    return _sectionCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: finalImage != null
                ? Image.network(
                    finalImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackSalonIcon(),
                  )
                : _fallbackSalonIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salon.name?.isNotEmpty == true ? salon.name! : 'Salon',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        salon.address?.isNotEmpty == true
                            ? salon.address!
                            : 'No address available',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackSalonIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.store_rounded, color: kPrimaryColor, size: 22),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SERVICES INCLUDED
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildServicesSection(Deal deal) {
    return _sectionCard(
      title: "Services Included",
      icon: Icons.spa_rounded,
      child: Column(
        children: deal.services!.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isLast = i == deal.services!.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 14, color: kPrimaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.name ?? '',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1, color: Colors.grey[100]),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // REUSABLE SECTION CARD
  // ─────────────────────────────────────────────────────────────────────
  Widget _sectionCard({
    String? title,
    IconData? icon,
    Color? accentColor,
    required Widget child,
  }) {
    final color = accentColor ?? kPrimaryColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && icon != null) ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // BOOK BUTTON
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBookButton(Deal deal) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!)),
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            final isInCart = cart.isInCart(deal);

            return SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cart.toggleItem(deal);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.grey[300] : kPrimaryColor,
                  foregroundColor:
                      isInCart ? Colors.grey[700] : Colors.white,
                  elevation: isInCart ? 0 : 2,
                  shadowColor: kPrimaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInCart
                          ? Icons.check_circle_rounded
                          : Icons.calendar_month_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInCart ? "Added to Cart" : "Book Now",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}