import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';
import 'section_title.dart';

class ServicesDashboard extends StatelessWidget {
  final List<ServiceSection> type4;

  const ServicesDashboard({Key? key, required this.type4}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter out the generic "Services" section, keep only "Men's Services" and "Women's Services"
    final filteredSections = type4.where((section) {
      final heading = section.heading.toLowerCase();
      // Keep sections that contain 'men' or 'women', exclude plain 'services'
      return heading.contains('men') || heading.contains('women');
    }).toList();

    return Column(
      children: filteredSections.map((section) {
        return Container(
          height: 280,
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SectionTitle(
                  title: section.heading,
                  press: () {
                    // Determine if it's men's or women's services based on heading
                    // Check for 'women' first since 'women' contains 'men'
                    final heading = section.heading.toLowerCase();
                    final route = heading.contains('women')
                        ? '/services-list-women'
                        : '/services-list-men';
                    Navigator.pushNamed(context, route);
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
                    return ServicesCard(
                      service: item,
                      title: item.name ?? 'No Title',
                      //image: item.image ?? logo,
                      image: "",
                      salon: item.salon!,
                      desc: item.name ?? '',
                      width: 320,
                      press: () {
                        //Navigator.pushNamed(context, ProductsScreen.routeName);
                        //Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: item);

                        log('Tapped Deal: ${item.name}');
                        // Navigator.pushNamed(context, SalonCategoryAndServicesListByService.routeName, arguments: item);
                        // log('Tapped Deal: ${item.name}');
                        // log('Tapped Deal:salon id   ${item?.salon?.id}');
                        // log('Tapped Deal:name   ${item.salon?.name}');
                        // log('Tapped Deal:image   ${item.salon?.image}');
                        // log('Tapped Deal:address   ${item.salon?.address}');

                        log('==================================');
                        Navigator.pushNamed(
                          context,
                          SalonCategoryAndServicesList.routeName,
                          arguments: item,
                        );
                        log('Tapped Deal: ${item.name}');
                        log('Tapped Deal:salon id   ${item.salon?.id}');
                        log('Tapped Deal:name   ${item.salon?.name}');
                        log('Tapped Deal:image   ${item.salon?.image}');
                        log('Tapped Deal:address   ${item.salon?.address}');
                        log('----------------------------------');
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

class ServicesCard extends StatelessWidget {
  const ServicesCard({
    Key? key,
    required this.title,
    required this.image,
    required this.desc,
    required this.press,
    required this.salon,
    required this.service,
    this.width,
  }) : super(key: key);

  final String title, image;
  final String desc;
  final Salon salon;
  final Service service;
  final GestureTapCallback press;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount =
        service.discountType != null && service.oldPrice != null;

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: width,
          constraints: const BoxConstraints(
            minHeight: 180,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                kPrimaryColor.withOpacity(0.02),
              ],
            ),
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
          child: Stack(
            children: [
              // Decorative corner accent
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.08),
                        kPrimaryColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Discount Badge
                    if (hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
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
                            const Icon(Icons.local_offer_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${((service.oldPrice! - service.price!) / service.oldPrice! * 100).toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: hasDiscount ? 6 : 0),

                    // Service Title
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

                    // Description
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Duration Tag
                    if (service.duration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${service.duration} min',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: service.duration != null ? 6 : 0),

                    // Salon Info
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: kPrimaryColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.5),
                            child: (salon.image != null &&
                                    salon.image!.isNotEmpty)
                                ? Image.network(
                                    salon.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.store_rounded,
                                        size: 16,
                                        color: kPrimaryColor.withOpacity(0.5),
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.store_rounded,
                                    size: 16,
                                    color: kPrimaryColor.withOpacity(0.5),
                                  ),
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

                    const SizedBox(height: 10),

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
                                "PKR ${service.price ?? 0}",
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
                                  "PKR ${service.oldPrice}",
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
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kPrimaryColor,
                                kPrimaryColor.withOpacity(0.85),
                              ],
                            ),
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
                                log('📅 Book Now tapped for service: ${service.name}');
                                Navigator.pushNamed(
                                  context,
                                  SalonCategoryAndServicesList.routeName,
                                  arguments: service,
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
            ],
          ),
        ),
      ),
    );
  }
}
