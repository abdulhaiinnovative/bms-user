import 'dart:developer';

import 'package:app/components/book_now.dart';
import 'package:app/components/sale_amount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/components/sale_percentage.dart';
import 'package:app/constants.dart';
import 'package:app/components/ratings.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/products/products_screen.dart';
import '../../test_scroll/salon_category_and_services_list.dart';
import '../../test_scroll/salon_category_and_services_list_by_service.dart';
import 'section_title.dart';

class ServicesDashboard extends StatelessWidget {
  final List<ServiceSection> type4;

  const ServicesDashboard({
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
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                    return ServicesCard(
                      service: item,
                      title: '${item.name}' ?? 'No Title',
                      //image: item.image ?? logo,
                      image: "",
                      salon: item.salon! ,
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
                        Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: item);
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
    return Container(



      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),

      child: GestureDetector(
        onTap: press, // Attach the press callback here
        child: Container(
          width: width,
          height: 150,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kRadius),

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
              SizedBox(width: 5),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              Row(
                children: [

                  ClipOval(
                    child: Image.network(
                      salon.image!,
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(width: 5),

                  Expanded( // Use this if inside a Row
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name ?? '',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          salon.address ?? '',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  )



                ],
              ),
              Spacer(),



              Row(
                children: [
                  Text(
                    'Rs: ${service.price}',
                    style: const TextStyle(
                        color: kPrice,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(width: 15),

                  if (service.discountType != null)
                    Text(
                      'Rs: ${service.oldPrice}',
                      style: const TextStyle(
                        color: kBeforeDiscount,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                  Spacer(),

                  if (service.discountType == 'price')
                    BookNow()
                    ////SaleAmount(sale: service.discountAmount ?? 0)
                  else if (service.discountType == 'percentage')
                    BookNow()
                    ///SalePercentage(off: service.percentageDiscount ?? 0, type:  '',),


                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}
