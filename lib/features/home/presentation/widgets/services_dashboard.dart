import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart'; // For ServiceSection and HomePage.Service/Salon
import 'package:app/models/salon_detail_models.dart'
    as SalonModels; // For SalonData types
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';
import 'package:app/providers/cart_provider.dart';
import '../screens/services_list_screen.dart';
import '../viewmodels/services_view_model.dart';
import 'section_title.dart';

class ServicesDashboard extends StatefulWidget {
  final List<ServiceSection> type4;

  const ServicesDashboard({Key? key, required this.type4}) : super(key: key);

  @override
  State<ServicesDashboard> createState() => _ServicesDashboardState();
}

class _ServicesDashboardState extends State<ServicesDashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the generic "Services" section, keep only "Men's Services" and "Women's Services"
    final filteredSections = widget.type4.where((section) {
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
                    final gender = heading.contains('women')
                        ? ServiceGender.women
                        : ServiceGender.men;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServicesListScreen(
                          gender: gender,
                        ),
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
                    return ServicesCard(
                      service: item,
                      title: item.name ?? 'No Title',
                      //image: item.image ?? logo,
                      image: "",
                      salon: item.salon!,
                      desc: item.name ?? '',
                      width: 320,
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
    this.salon, // Made optional since Service objects don't have salon data
    this.salonName, // Optional salon name for when salon object is not available
    required this.service,
    this.width,
  }) : super(key: key);

  final String title, image;
  final String desc;
  final Salon? salon; // Made optional
  final String? salonName; // Added for search results
  final Service service;

  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount =
        service.discountType != null && service.oldPrice != null;

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

              // Duration and Gender Tags
              Row(
                children: [
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

                  if (service.duration != null && service.gender != null)
                    const SizedBox(width: 6),

                  // Gender Tag
                  if (service.gender != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: service.gender?.toLowerCase() == 'male'
                            ? Colors.blue.withOpacity(0.1)
                            : service.gender?.toLowerCase() == 'female'
                                ? Colors.pink.withOpacity(0.1)
                                : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service.gender?.toLowerCase() == 'male'
                                ? Icons.male
                                : service.gender?.toLowerCase() == 'female'
                                    ? Icons.female
                                    : Icons.people,
                            size: 11,
                            color: service.gender?.toLowerCase() == 'male'
                                ? Colors.blue.shade700
                                : service.gender?.toLowerCase() == 'female'
                                    ? Colors.pink.shade700
                                    : Colors.purple.shade700,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            service.gender!.substring(0, 1).toUpperCase() +
                                service.gender!.substring(1).toLowerCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: service.gender?.toLowerCase() == 'male'
                                  ? Colors.blue.shade700
                                  : service.gender?.toLowerCase() == 'female'
                                      ? Colors.pink.shade700
                                      : Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(
                  height: (service.duration != null || service.gender != null)
                      ? 6
                      : 0),

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
                      child: (salon?.image != null && salon!.image!.isNotEmpty)
                          ? Image.network(
                              salon!.image!,
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

                  // Book Button with Cart functionality
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final isInCart = cart.isInCart(service);
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
                              final success = cart.toggleItem(service);

                              if (!success && cart.isDifferentSalon(service)) {
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
                                          child: const Text('Clear & Continue'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldClear == true) {
                                  cart.toggleItem(service, forceClear: true);
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
