import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/constants.dart';
import '../../../models/HomePageResponse.dart';
import '../../products/products_screen.dart';
import '../../search_final/search_service_screen_new.dart';
import '../../services/services_screen.dart';
import 'section_title.dart';

class CategoriesDashboard extends StatelessWidget {
  final List<CategorySection> type2;

  const CategoriesDashboard({
    Key? key,
    required this.type2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: type2.map((section) {
        return Container(
          height: 100, // Adjust height if needed
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SectionTitle(
                  title: section.heading,
                  press: () {},
                ),
              ),
              //const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: section.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = section.data[index];
                    return CategoryCard(
                      title: item.name ?? '',
                      image: logo,
                      desc: '',
                      press: () {
                        /// Navigator.pushNamed(context, ServicesScreen.routeName);
                        ///
                        Navigator.pushNamed(context, SearchServiceScreenNew.routeName,
                          arguments: {
                            'categoryName': item.name,
                            'categoryId': item.id,
                            'isFromBottomNav': true,
                          },
                        );

                        log('Category tapped: ${item.name}');
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



class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.title,
    required this.image,
    required this.desc,
    required this.press,
  }) : super(key: key);

  final String title, image;
  final String desc;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          // Container(
          //     padding: const EdgeInsets.all(8),
          //     height: 90,
          //     width: 90,
          //     decoration: BoxDecoration(
          //       color: kShadowWithPrimary,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: FadeInImage.assetNetwork(
          //       placeholder: placeHolder,
          //       image: image,
          //       fit: BoxFit.cover,
          //     )
          // ),
          // const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin:  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: kCardBG,
              borderRadius: BorderRadius.circular(20),
              //border: Border.all(color: kPrimaryColor),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
