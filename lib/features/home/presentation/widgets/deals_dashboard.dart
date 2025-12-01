import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';
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
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
    log('🔖 DealsDashboard: Initialized with ${widget.type4.length} sections');
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
                    Navigator.pushNamed(context, '/deals-list');
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
                    log('salon?.name: ${item.services}');

                    final defaultSalon = Salon(
                      name: 'Unknown Salon',
                      image: logo,
                      address: 'Unknown address',
                      // … other required fields
                    );

                    return DealsCard(
                      title: item.name ?? 'No Title',
                      image: item.image ?? logo,
                      salon: item.salon ?? defaultSalon,
                      deal: item,
                      services: item.services != null
                          ? item.services!.map((s) => s.name).join(' • ')
                          : '',
                      price: item.price ?? 0,
                      discountValue: item.discountValue ?? 0,
                      discountType: item.discountType ?? '-',
                      width: 320,
                      press: () {
                        //Navigator.pushNamed(context, ProductsScreen.routeName);
                        Navigator.pushNamed(
                            context, SalonCategoryAndServicesList.routeName,
                            arguments: item);
                        log('Tapped Deal: ${item.name}');
                        log('Tapped Deal:salon id   ${item.services?[0].salon?.id}');
                        log('Tapped Deal:name   ${item.services?[0].salon?.name}');
                        log('Tapped Deal:image   ${item.services?[0].salon?.image}');
                        log('Tapped Deal:address   ${item.services?[0].salon?.address}');
                      },
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
    required this.salon,
    required this.price,
    required this.discountValue,
    required this.discountType,
    required this.press,
    this.deal,
    this.width,
  }) : super(key: key);

  final String title, image;
  final String services, discountType;
  final Salon salon;
  final Deal? deal;
  final int price, discountValue;
  final double? width;

  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountValue != 0;
    final int oldPrice = discountType == 'amount'
        ? price + discountValue
        : (price + (price * discountValue / 100)).toInt();

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
      child: GestureDetector(
        onTap: press,
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
                        salon.name ?? 'Unknown Salon',
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

                    // Book Button
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            log('📅 Book Now tapped for deal: $title');
                            Navigator.pushNamed(
                              context,
                              SalonCategoryAndServicesList.routeName,
                              arguments: deal,
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Book Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
