import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/models/home/SalonData.dart' as HomeSalonData;
import 'package:app/features/home/presentation/screens/deal_detail_screen.dart';

class SearchDealsCard extends StatelessWidget {
  const SearchDealsCard({
    Key? key,
    required this.title,
    required this.image,
    this.services,
    this.salon,
    this.salonName,
    this.deal,
    required this.price,
    required this.discountValue,
    required this.discountType,
    this.width,
  }) : super(key: key);

  final String title;
  final String image;
  final String? services;
  final HomeSalonData.SalonData? salon;
  final String? salonName;
  final Deal? deal;
  final int price;
  final int discountValue;
  final String discountType;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discountValue != 0;
    final int oldPrice = discountType == 'amount'
        ? price + discountValue
        : (price + (price * discountValue / 100)).toInt();

    return GestureDetector(
      onTap: () {
        if (deal == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DealDetailScreen(deal: deal!, salon: salon),
          ),
        );
      },
      child: Container(
        width: width ?? double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.only(right: 10, left: 0,top: 0,bottom: 0),
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                        discountType == 'amount'
                            ? 'Rs $discountValue OFF'
                            : '$discountValue% OFF',
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

                  /// SALON NAME
                  if (salonName != null && salonName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kPrimaryColor.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Builder(builder: (context) {
                                final String salonLogoUrl =
                                salon?.logo?.isNotEmpty == true
                                    ? salon!.logo!
                                    : salon?.image?.isNotEmpty == true
                                    ? salon!.image!
                                    : deal?.salon?.logo?.isNotEmpty == true
                                    ? deal!.salon!.logo!
                                    : deal?.salon?.image ?? '';

                                if (salonLogoUrl.isNotEmpty) {
                                  return Image.network(
                                    salonLogoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(Icons.store,
                                          size: 16, color: Colors.grey);
                                    },
                                  );
                                }

                                return const Icon(Icons.store,
                                    size: 16, color: Colors.grey);
                              }),
                            ),
                          ),

                          // Container(
                          //   padding: const EdgeInsets.all(5),
                          //   decoration: BoxDecoration(
                          //     color: kPrimaryColor.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child:
                          //   Icon(
                          //     Icons.store_rounded,
                          //     size: 13,
                          //     color: kPrimaryColor,
                          //   ),
                          // ),
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
                    ),

                  /// SERVICES LIST
                  if (services != null && services!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        services!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  /// PRICE
                  Row(
                    children: [
                      Text(
                        "PKR $price",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          "PKR $oldPrice",
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
