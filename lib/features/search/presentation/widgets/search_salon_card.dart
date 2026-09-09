import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../constants.dart';

class SearchSalonCard extends StatelessWidget {
  const SearchSalonCard({
    Key? key,
    required this.name,
    required this.image,
    required this.address,
    required this.about,
    required this.average_rating,
    required this.review_count,
    required this.is_favourite,
    required this.press,
    required this.logo,
    this.width,
  }) : super(key: key);

  final String name, image, address, about, logo;
  final int review_count;
  final num average_rating;
  final bool is_favourite;
  final GestureTapCallback press;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: width ?? double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.only(right: 10, left: 10),
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
                  child: logo.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: logo,
                          height: 95,
                          width: 95,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 95,
                            width: 95,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 95,
                            width: 95,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          height: 95,
                          width: 95,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.grey,
                          ),
                        ),
                ),

                /// RATING BADGE
                /// RATING BADGE
                if (average_rating > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomLeft: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            average_rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                 // Favorite icon
                if (is_favourite)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                           topLeft: Radius.circular(14),
                           bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            /// DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE AND LOGO
                    Row(
                      children: [
                         Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kPrimaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (logo.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: logo,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => const Icon(Icons.store, size: 14, color: Colors.grey),
                                  )
                                : const Icon(Icons.store, size: 14, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// DESCRIPTION
                    if (about.isNotEmpty)
                      Text(
                        about,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),

                    const SizedBox(height: 8),

                    /// ADDRESS
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                     const SizedBox(height: 4),
                     /// REVIEWS
                    Row(
                       children: [
                         const Icon(
                            Icons.rate_review_rounded,
                            color: kPrimaryColor,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$review_count ${review_count == 1 ? 'Review' : 'Reviews'}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                       ],
                     ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            /// ARROW BUTTON
            Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
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
