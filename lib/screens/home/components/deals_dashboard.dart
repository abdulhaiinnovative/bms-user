import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import '../../../components/book_now.dart';
import '../../test_scroll/salon_category_and_services_list.dart';
import 'section_title.dart';

class DealsDashboard extends StatelessWidget {
  final List<DealSection> type4;

  const DealsDashboard({
    Key? key,
    required this.type4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: type4.map((section) {
        return Container(
          height: 240,
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SectionTitle(
                  title: section.heading,
                  press: () {},
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
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: GestureDetector(
        onTap: press, // Attach the press callback here
        child: Container(
          width: width,
          height: 175,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: kCardBG,
            borderRadius: BorderRadius.circular(kRadius),
            // boxShadow: [
            //   BoxShadow(
            //     color: kShadow,
            //     blurRadius: 1,
            //     offset: Offset(0, 0),
            //   ),
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 5),
              Text(
                services,
                style: const TextStyle(
                  color: kPrimaryDarkColor,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Text(
              //   '30 min - 1 hr',
              //   style: const TextStyle(
              //     color: Colors.black,
              //
              //   ),
              //   overflow: TextOverflow.ellipsis,
              // ),

              const SizedBox(height: 10),
              Row(
                children: [
                  // ClipOval(
                  //   child: Image.network(
                  //     salon.image!,
                  //     height: 30,
                  //     width: 30,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),

                  const SizedBox(width: 5),

                  Expanded(
                    // Use this if inside a Row
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name ?? '',
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          salon.address ?? '',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Rs: $price',
                      style: const TextStyle(
                          color: kPrice,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 10),

                  if (discountValue != 0)
                    Flexible(
                      child: discountType == 'amount'
                          ? Text(
                              'Rs: ${(price + discountValue)}',
                              style: const TextStyle(
                                color: kBeforeDiscount,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              'Rs: ${(price + (price * discountValue / 100)).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: kBeforeDiscount,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),

                  const Spacer(),
                  BookNow(
                    onTap: () {
                      log('📅 Book Now tapped for deal: $title');
                      Navigator.pushNamed(
                        context,
                        SalonCategoryAndServicesList.routeName,
                        arguments: deal,
                      );
                    },
                  ),

                  /// if(discountValue != 0)
                  /// SalePercentage(off: discountValue, type: discountType,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
