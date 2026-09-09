import 'package:app/features/home/presentation/screens/deal_detail_screen.dart';
import 'package:app/features/home/presentation/screens/deals_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart'; // For DealSection and HomePage.Deal
import 'package:app/models/salon_detail_models.dart'
    as SalonModels; // For SalonData, Salon types
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';
import 'package:app/providers/cart_provider.dart';
import '../../../../models/home/SalonData.dart' as HomeSalonData;
import 'section_title.dart';

class DealsDashboard extends StatefulWidget {
  final List<DealSection> type4;

  const DealsDashboard({
    Key? key,
    required this.type4,
  }) : super(key: key);

  @override
  State<DealsDashboard> createState() => _DealsDashboardState();
}

class _DealsDashboardState extends State<DealsDashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: widget.type4.map((section) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SectionTitle(
                  title: section.heading,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DealsListScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300, // ✅ only this fixed, not whole container
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: section.data.length,
                  itemBuilder: (context, index) {
                    final item = section.data[index];

                    // Convert HomePage.Salon to home/SalonData for DealDetailScreen
                    final salonDataForDetail = item.salon != null
                        ? HomeSalonData.SalonData(
                            id: item.salon!.id,
                            name: item.salon!.name,
                            logo: item.salon!.logo,
                            image: item.salon!.image,
                            address: item.salon!.address,
                          )
                        : null;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DealDetailScreen(
                                    deal: item, salon: salonDataForDetail)));
                      },
                      child: DealsCard(
                        title: item.name ?? 'No Title',
                        image: item.image ?? logo,
                        salon: null,
                        salonName: item.salon!.name ?? "UNKNOWN NAME",
                        deal: item,
                        services: item.services != null
                            ? item.services!.map((s) => s.name).join(' • ')
                            : '',
                        price: item.price ?? 0,
                        discountValue: item.discountValue ?? 0,
                        discountType: item.discountType ?? '-',
                        width: 180,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DealsCard extends StatelessWidget {
  const DealsCard({
    Key? key,
    required this.title,
    required this.image,
    required this.services,
    this.salon, // Made optional since HomePage.Deal doesn't have compatible salon data
    this.salonName, // Optional salon name for when salon object is not available
    required this.price,
    required this.discountValue,
    required this.discountType,
    this.deal,
    this.width,
    this.matchedCount,
  }) : super(key: key);
  final int? matchedCount;

  final String title, image;
  final String services, discountType;
  final SalonModels.Salon? salon; // Made optional
  final String? salonName; // Added for search results
  final Deal? deal;
  final int price, discountValue;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountValue != 0;
    final int oldPrice = discountType == 'amount'
        ? price + discountValue
        : (price + (price * discountValue / 100)).toInt();

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 3),
      child: Container(
        width: width,
        constraints: const BoxConstraints(
          minHeight: 120,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kPrimaryColor.withOpacity(0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 110,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 36, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 110,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 36, color: Colors.grey),
                          ),
                        ),
                ),

                /// 🔥 DISCOUNT BADGE (TOP LEFT)
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            discountType == 'amount'
                                ? 'Rs $discountValue OFF'
                                : '$discountValue% OFF',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description (Services)
                  Text(
                    services,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Salon Name
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          // shape: BoxShape.circle,
                          border: Border.all(
                            color: kPrimaryColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Builder(
                            builder: (context) {

                              final String? salonLogoUrl =
                              (salon?.logo != null && salon!.logo!.isNotEmpty)
                                  ? salon!.logo
                                  : (salon?.image != null && salon!.image!.isNotEmpty)
                                  ? salon!.image
                                  : (deal?.salon?.logo != null && deal!.salon!.logo!.isNotEmpty)
                                  ? deal!.salon!.logo
                                  : (deal?.salon?.image != null && deal!.salon!.image!.isNotEmpty)
                                  ? deal!.salon!.image
                                  : null;

                              if (salonLogoUrl != null && salonLogoUrl.isNotEmpty) {
                                return Image.network(
                                  salonLogoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.store,
                                      size: 14,
                                      color: Colors.grey,
                                    );
                                  },
                                );
                              }

                              return const Icon(
                                Icons.store,
                                size: 14,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salonName!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Price Section
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "PKR $price",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: kPrimaryColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text(
                              "PKR $oldPrice",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red[400],
                                decorationThickness: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Book Button
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final isInCart = cart.isInCart(deal);
                      return Container(
                        width: double.infinity,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              isInCart ? Colors.grey.shade400 : kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final success = cart.toggleItem(deal);

                              if (!success && cart.isDifferentSalon(deal)) {
                                final shouldClear = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Change Salon?'),
                                      content: Text(
                                          'Your cart contains items from ${cart.salonName ?? "another salon"}. '
                                          'Adding items from ${salon?.name ?? "this salon"} will clear your current cart. Continue?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Clear & Continue'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldClear == true) {
                                  cart.toggleItem(deal, forceClear: true);
                                  cart.setSalonInfo(salon?.id, salon?.name);
                                }
                              } else if (success) {
                                cart.setSalonInfo(salon?.id, salon?.name);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isInCart ? "Added" : "Book Now",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isInCart
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
