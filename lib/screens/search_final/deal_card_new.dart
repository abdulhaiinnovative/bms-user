
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants.dart';
// import '../../models/HomePageResponse.dart';
import '../../models/HomePageResponse.dart';


class DealCard extends StatelessWidget {
  final String title;
  final int price;
  final int discountAmount;
  final String discountType;
  final int? oldPrice;
  final String duration;
  final String desc;
  final String? validUntil;
  final String? image;
  final Salon? salon;
  final GestureTapCallback press;

  const DealCard({
    Key? key,
    required this.title,
    required this.price,
    required this.discountAmount,
    required this.discountType,
    this.oldPrice,
    required this.duration,
    required this.desc,
    this.validUntil,
    this.image,
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
          boxShadow: [
            BoxShadow(
              color: kShadow2,
              blurRadius: 4.0,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: image!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    margin: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset('assets/images/default_logo.png'),
                ),
              )

            else
              Image.asset('assets/images/default_logo.png', width: 80, height: 80),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 14, color: kTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (salon != null)
                    Text(
                      salon?.name ?? "" ,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  SizedBox(height: 5),

                  if (validUntil != null)
                    Text(
                      'Valid until: $validUntil',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  if (duration.isNotEmpty)
                    Text(
                      'Duration: $duration',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                  Row(
                    children: [
                      Text(
                        'Rs $price',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrice),
                      ),
                      if (oldPrice != null && oldPrice! > price)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Rs $oldPrice',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
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
    );
  }
}
