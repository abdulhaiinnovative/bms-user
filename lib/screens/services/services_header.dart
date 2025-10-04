import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:app/components/filter_categories.dart';
import 'package:app/components/filter_location.dart';
import 'package:app/components/price_range.dart';
import 'package:app/components/sorting.dart';
import 'package:app/constants.dart';

import '../../api_services/search_salon_api.dart';
import '../../models/SalonMain.dart';
import '../../providers/SearchProvider.dart';
import '../cart/cart_screen.dart';
import '../home/components/icon_btn_with_counter.dart';
import '../home/components/search_field.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/components/filter_categories.dart';
import 'package:app/components/filter_location.dart';
import 'package:app/components/price_range.dart';
import 'package:app/components/sorting.dart';
import 'package:app/constants.dart';

import '../cart/cart_screen.dart';
import '../home/components/icon_btn_with_counter.dart';
import '../home/components/search_field.dart';


import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServicesHeader extends StatefulWidget {
  final TabController tabController; // Accept tabController from parent

  const ServicesHeader({Key? key, required this.tabController}) : super(key: key);

  @override
  _ServicesHeaderState createState() => _ServicesHeaderState();
}

class _ServicesHeaderState extends State<ServicesHeader> {
  TextEditingController searchController = TextEditingController();

  void _showBottomSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 60),
              Expanded(child: SearchField(controller: searchController)),
              const SizedBox(width: 8),

              CircleIconButton(
                onPressed: () async {
                  log('IconButton pressed: ${searchController.text}');

                  if (widget.tabController.index == 0) {
                    log('Service.');
                    if (searchController.text.isNotEmpty) {
                      Provider.of<SearchProvider>(context, listen: false)
                          .searchServices("", searchController.text);
                    }
                  } else if (widget.tabController.index == 1) {
                    log('Deals');
                    if (searchController.text.isNotEmpty) {
                      Provider.of<SearchProvider>(context, listen: false)
                          .searchSalons(searchController.text, "");
                    }
                  } else {
                  log('Salon');
                  if (searchController.text.isNotEmpty) {
                  Provider.of<SearchProvider>(context, listen: false)
                      .searchSalons(searchController.text, "");
                  }
                  }
                },
                icon: Icons.circle,
                iconColor: kPrimaryDarkColor,
                backgroundColor: kPrimaryDarkColor.withOpacity(0.15),
                borderColor: kPrimaryDarkColor.withOpacity(0.01),
                borderWidth: 2.0,
                iconSize: 25,
                circleSize: 37,
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),

              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.sort),
                      SizedBox(width: 4),
                      Text('Sort'),
                    ],
                  ),
                ),
                onTap: () {
                  log("Click event on Sort");
                  _showBottomSheet(Sorting());
                },
              ),

              const SizedBox(width: 4),

              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.filter_alt),
                      SizedBox(width: 4),
                      Text('Filter'),
                    ],
                  ),
                ),
                onTap: () {
                  log("Click event on Filter");
                  // Handle filter action here
                },
              ),

              const SizedBox(width: 8),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      FilterItem(
                        label: 'Category',
                        onTap: () => _showBottomSheet(FilterCategories()),
                      ),
                      FilterItem(
                        label: 'Location',
                        onTap: () => _showBottomSheet(FilterLocation()),
                      ),
                      FilterItem(
                        label: 'PECHS',
                        onTap: () => _showBottomSheet(FilterLocation()),
                      ),
                      FilterItem(
                        label: 'Rs: 500 - Rs:3000',
                        onTap: () => _showBottomSheet(PriceRange()),
                      ),
                      FilterItem(
                        label: 'Category 2',
                        onTap: () => log('Filter tapped: Category 2'),
                      ),
                      FilterItem(
                        label: 'Category 3',
                        onTap: () => log('Filter tapped: Category 3'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

      Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 5),

        child: Container(
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
              child: TabBar(
                controller: widget.tabController, // Use widget.tabController
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.pink,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Services'),
                  Tab(text: 'Deals'),
                  Tab(text: 'Salon'),
                ],
              ),
            ),
      ),
        ],
      ),
    );
  }
}



class FilterItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  FilterItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 0, right: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 14, top: 0, bottom: 2, right: 2),
          decoration: BoxDecoration(
            //color: kPrimaryDarkColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(width: 1.5, color: kPrimaryDarkColor),

          ),
          child: Row(
            children: <Widget>[
              Text(
                label,
                style: TextStyle(color: kPrimaryDarkColor,
                  fontSize: 18,
                  fontWeight:  FontWeight.w800,
                ),
              ),
              SizedBox(width: 2),

              IconButton(onPressed: (){
                log('=--=-------');

              },
                icon: Icon(Icons.cancel, color: kPrimaryDarkColor, size: 22,),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double iconSize;
  final double circleSize;

  CircleIconButton({
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.iconSize,
    required this.circleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: iconSize),
        padding: EdgeInsets.all(0), // Remove default padding
        constraints: BoxConstraints(), // Remove default constraints
      ),
    );
  }
}
