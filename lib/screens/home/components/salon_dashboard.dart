import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:app/constants.dart';
import 'package:app/components/ratings.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/products/products_screen.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';

import '../../../api_services/salon_detail_api.dart';
import '../../../helper/CircularNetworkImage.dart';
import '../../../helper/ReviewCount.dart';
import '../../../models/SalonDetailApiResponse.dart';
import '../../salon/salon_screen.dart';
import '../../test/scroll_sync_tabs.dart';
import '../../test/salon_details_scrolling_tabs_effect.dart';
import '../../test_scroll/salon_category_and_services_list.dart';
import 'section_title.dart';

class SalonDashboard extends StatelessWidget {
  final List<TopSalonSection> type3;

  const SalonDashboard({
    Key? key,
    required this.type3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: type3.map((section) {
        return Container(
          height: 338,
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
                    return SalonCard(
                      title: item.name ?? 'No Name',
                      image: item.image ?? salonImage,
                      desc: item.about ?? 'No description available',
                      address: item.address ?? "",
                      area: item.area ?? "",
                      rating: item.averageRating ?? 0,
                      reviews: item.reviewCount ?? 0,

                      press: () {

                        //working
                        Navigator.pushNamed(context, SalonDetailsScrollingTabsEffectB.routeName, arguments: '${item.id}',);


                        // working salon detail segmented
                        //Navigator.pushNamed(context, SalonScreen.routeName);


                        // Navigator.pushNamed(context, ProductsScreen.routeName);

                        // Navigator.pushNamed(context, ScrollSyncTabs.routeName);

                        // working salon
                        // Navigator.pushNamed(context, SalonDetailsScrollingTabsEffect.routeName);

                        //may be category
                        // Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName);


                        // SalonDetailAPI salonDetailAPI = SalonDetailAPI();
                        // //late SalonData? salonDetailsss =
                        // salonDetailAPI.fetchSalonDetailData("1");
                        log('Tapped salon: ${item.name}');

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


class SalonCard extends StatelessWidget {

  const SalonCard({
    Key? key,
    required this.title,
    required this.image,
    required this.desc,

    required this.address,
    required this.area,
    required this.rating,
    required this.reviews,

    required this.press,
  }) : super(key: key);

  final String title, image, address, area;
  final String desc;
  final int rating, reviews;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),

      child: GestureDetector(
        onTap: press,
        child: SizedBox(
          width: 320,
          //height: 280,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadius),

            child: Container(
              color: kCardBG,

              child: Column(
                children: [

              Stack(
              children: [
              Container(
                width: 320,
                height: 175,
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/place_holder.png', // Path to your placeholder image
                  image: image, // URL to the main image
                  fit: BoxFit.cover,
                ),
              ),
              // Positioned(
              //   bottom: 10,
              //   left: 10,
              //   child: Ratings(rating: 4.3),
              // ),
              //
              //   Positioned(
              //     bottom: 10,
              //     right: 10,
              //     child: ReviewCount(reviews: 4),
              //   ),

              ],
              ),

                  //SizedBox(height: 5),
                  Row(
                    children: [

                      // CircularNetworkImage(
                      //   imageUrl: logo,
                      //   height: 60,
                      //   width: 60,
                      //   border: 3,
                      // ),
                      // SizedBox(width: 5),

                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 10,
                          ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Text(
                                  //   desc,
                                  //   style: const TextStyle(
                                  //     color: Colors.black,
                                  //   ),
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          address,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),



                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Ratings(rating: rating , compact: true,),
                                      ReviewCount(reviews: reviews),
                                    ],
                                  )






                                ],

                          ),
                        ),
                      ),

                      // Lottie.asset(
                      //   'assets/images/sale_2.json',
                      //   width: 70,
                      //   height: 70,
                      // ),

                    ],
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


