import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/HomePageResponse.dart';


class ServicesCard extends StatelessWidget {
  final String title;
  final int price;
  final int discountAmount;
  final String discountType;
  final int? oldPrice;
  final String gender;
  final String duration;
  final String desc;
  final Salon? salon;
  final GestureTapCallback press;

  const ServicesCard({
    Key? key,
    required this.title,
    required this.price,
    required this.discountAmount,
    required this.discountType,
    this.oldPrice,
    required this.gender,
    required this.duration,
    required this.desc,
    this.salon,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin:  const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: kShadow2,
              blurRadius: 4.0,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 14, color: kPrimaryColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (salon != null)
                    Text(
                      salon?.name ?? "",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Rs $price',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrice),
                      ),
                      if (oldPrice != null && oldPrice! > price)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Rs $oldPrice',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (duration.isNotEmpty)
                    Text(
                      'Duration: $duration',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  if (gender.isNotEmpty)
                    Text(
                      'For: $gender',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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