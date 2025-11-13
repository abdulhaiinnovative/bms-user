import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/components/book_now.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Modern redesigned DealsCard with enhanced visuals
/// - Eye-catching gradient backgrounds
/// - Better image display
/// - Prominent discount badges
/// - Improved layout with visual hierarchy
/// - Service list with icons
class DealsCardV2 extends StatelessWidget {
  const DealsCardV2({
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
    final bool hasDiscount = discountValue > 0;
    final int originalPrice = hasDiscount
        ? (discountType == 'amount'
              ? price + discountValue
              : (price + (price * discountValue / 100)).toInt())
        : price;

    final int savingsAmount = hasDiscount ? originalPrice - price : 0;

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: width ?? 340,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.orange.shade50.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with deal icon and discount badge
                  Container(
                    height: 85,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF6B6B).withOpacity(0.15),
                          const Color(0xFFFFA500).withOpacity(0.15),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: 30,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF6B6B).withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Deal icon
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B6B),
                                      Color(0xFFFFA500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF6B6B,
                                      ).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_offer_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6B6B),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'HOT DEAL',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Services included
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Services Included',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          services.isEmpty ? 'Multiple services' : services,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Salon info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Row(
                      children: [
                        // Salon image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              (salon.image != null && salon.image!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: salon.image!,
                                  height: 32,
                                  width: 32,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 32,
                                    width: 32,
                                    color: Colors.grey[200],
                                  ),
                                  errorWidget: (context, error, stackTrace) {
                                    return Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange.shade300,
                                            Colors.orange.shade400,
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.store_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade300,
                                        Colors.orange.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.store_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                salon.name ?? 'Salon',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                salon.address ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Price and Book Now
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Price section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  'Rs $originalPrice',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Rs ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF6B6B),
                                    ),
                                  ),
                                  Text(
                                    '$price',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6B6B),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      'Save Rs $savingsAmount',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Book Now button
                        BookNow(
                          onTap: () {
                            log('📅 Book Now tapped for deal: $title');
                            press();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Discount badge (top right)
              if (hasDiscount)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      discountType == 'percentage'
                          ? '$discountValue% OFF'
                          : 'Rs $discountValue OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
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
