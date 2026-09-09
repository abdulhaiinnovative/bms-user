import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/models/home/SalonData.dart';

import '../../../home/presentation/screens/service_detail_screen.dart';

class SearchServiceCard extends StatelessWidget {
  const SearchServiceCard({
    Key? key,
    required this.title,
    required this.image,
    required this.service,
    this.salon,
    this.salonName,
    this.desc,
    this.width,
  }) : super(key: key);

  final String title;
  final String image;
  final String? desc;
  final Salon? salon;
  final String? salonName;
  final Service service;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount =
        service.discountType != null && service.oldPrice != null;

    return GestureDetector(
      onTap: () {
        // Navigate to service detail screen with service ID
        print("SERVICE ${service.id}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(serviceId: service.id!),
          ),
        );
      },
      child: Container(
        width: width ?? double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.only(
          right: 10,
          left: 0,
          top: 0,
          bottom: 0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// IMAGE
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: image.isNotEmpty
                      ? Image.network(
                    image,
                    height: 95,
                    width: 95,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 95,
                        width: 95,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                      : Container(
                    height: 95,
                    width: 95,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),

                /// DISCOUNT BADGE
                if (hasDiscount)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '${((service.oldPrice! - service.price!) / service.oldPrice! * 100).toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                /// TITLE
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                // Reduced spacing after image for a tighter look


                /// DESCRIPTION
                if (desc != null && desc!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      desc!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                /// DURATION + GENDER
                Row(
                  children: [
                    if (service.duration != null) ...[
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.duration}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],

                    if (service.gender != null) ...[
                      const SizedBox(width: 10),
                      Icon(
                        service.gender!.toLowerCase() == 'male'
                            ? Icons.male
                            : service.gender!.toLowerCase() == 'female'
                                ? Icons.female
                                : Icons.people,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.gender!
                                .substring(0, 1)
                                .toUpperCase() +
                            service.gender!
                                .substring(1)
                                .toLowerCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                /// PRICE
                Row(
                  children: [
                    Text(
                      "PKR ${service.price ?? 0}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        "PKR ${service.oldPrice}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
                            ),
    ),
            const SizedBox(width: 10),

            /// ARROW BUTTON
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            ],
        ),
      ),
    );
  }
}