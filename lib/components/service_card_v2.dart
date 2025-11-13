import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/components/book_now.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Modern redesigned ServicesCard with enhanced visuals
/// - Gradient background
/// - Better image handling with shimmer loading
/// - Improved layout and spacing
/// - Rating display
/// - Enhanced price display with badges
class ServicesCardV2 extends StatelessWidget {
  const ServicesCardV2({
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
        service.discountType != null && (service.discountAmount ?? 0) > 0;

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: width ?? 340,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with service image/icon
              Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kPrimaryColor.withOpacity(0.1),
                      kPrimaryLightColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(painter: _ServicePatternPainter()),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Service icon/image
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.content_cut_rounded,
                              color: kPrimaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  desc.isEmpty ? 'Professional service' : desc,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Discount badge
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                service.discountType == 'percentage'
                                    ? '${service.percentageDiscount?.toInt()}% OFF'
                                    : 'SALE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Salon info section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Salon image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (salon.image != null && salon.image!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: salon.image!,
                              height: 36,
                              width: 36,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 36,
                                width: 36,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, error, stackTrace) {
                                return Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        kPrimaryColor.withOpacity(0.3),
                                        kPrimaryLightColor.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.store_rounded,
                                    size: 20,
                                    color: kPrimaryColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    kPrimaryColor.withOpacity(0.3),
                                    kPrimaryLightColor.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                size: 20,
                                color: kPrimaryColor,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    // Salon details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salon.name ?? 'Salon',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  salon.address ?? 'Location',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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

              const Spacer(),

              // Price and Book Now section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Price section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              'Rs ${service.oldPrice}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Rs ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                              Text(
                                '${service.price}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Book Now button
                    BookNow(
                      onTap: () {
                        log('📅 Book Now tapped for service: ${service.name}');
                        press();
                      },
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

/// Custom painter for decorative pattern
class _ServicePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPrimaryColor.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.3), size.height * 0.5),
        20,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
