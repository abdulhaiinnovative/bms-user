import 'package:app/features/home/presentation/screens/deals_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart'; // For DealSection and HomePage.Deal
import 'package:app/models/salon_detail_models.dart'
    as SalonModels; // For SalonData, Salon types
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';
import 'package:app/providers/cart_provider.dart';
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
      children: widget.type4.map((section) {
        return Container(
          height: 240,
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
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
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: section.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = section.data[index];

                    // item.salon is HomePage.Salon, not compatible with salon_detail_models.Salon
                    // Salon details should be fetched separately via API if needed

                    return DealsCard(
                      title: item.name ?? 'No Title',
                      image: item.image ?? logo,
                      salon: null, // Salon data not available in HomePage.Deal
                      deal: item,
                      services: item.services != null
                          ? item.services!.map((s) => s.name).join(' • ')
                          : '',
                      price: item.price ?? 0,
                      discountValue: item.discountValue ?? 0,
                      discountType: item.discountType ?? '-',
                      width: 320,
                      // press: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) =>
                      //           const SalonCategoryAndServicesList(),
                      //       settings: RouteSettings(arguments: item),
                      //     ),
                      //   );
                      // },
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
  }) : super(key: key);

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
      padding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
      child: Container(
        width: width,
        constraints: const BoxConstraints(
          minHeight: 180,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Discount Badge
              if (hasDiscount)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        discountType == 'amount'
                            ? 'Rs $discountValue OFF'
                            : '$discountValue% OFF',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
      
              SizedBox(height: hasDiscount ? 8 : 0),
      
              // Deal Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      
              const SizedBox(height: 5),
      
              // Services List
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
      
              const SizedBox(height: 7),
      
              // Salon Name with Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      size: 13,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      salonName ?? salon?.name ?? 'Unknown Salon',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      
              const SizedBox(height: 8),
      
              // Price and Book Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price Section
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "PKR $price",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor,
                            height: 1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(height: 2),
                          Text(
                            "PKR $oldPrice",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red[400],
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      
                  const SizedBox(width: 8),
      
                  // Book Button with Cart functionality
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final isInCart = cart.isInCart(deal);
                      return Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color:
                              isInCart ? Colors.grey.shade400 : kPrimaryColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (isInCart
                                      ? Colors.grey.shade400
                                      : kPrimaryColor)
                                  .withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final success = cart.toggleItem(deal);
      
                              if (!success && cart.isDifferentSalon(deal)) {
                                // Show confirmation dialog
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
                                          child:
                                              const Text('Clear & Continue'),
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
                            borderRadius: BorderRadius.circular(18),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isInCart ? "Added" : "Book Now",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isInCart
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 16,
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
            ],
          ),
        ),
      ),
    );
  }
}
