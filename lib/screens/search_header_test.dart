import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app/components/filter_categories.dart';
import 'package:app/components/filter_location.dart';
import 'package:app/components/price_range.dart';
import 'package:app/components/sorting.dart';
import 'package:app/constants.dart';

import 'package:app/features/home/presentation/widgets/search_field.dart';

class ServicesHeaderTest extends StatelessWidget {
  TextEditingController searchController = TextEditingController();

  ServicesHeaderTest({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 60),
                Expanded(
                    child: SearchField(
                  controller: searchController,
                )),
                const SizedBox(width: 8),
                CircleIconButton(
                  onPressed: () {
                    log('IconButton pressed');
                  },
                  icon: Icons.favorite,
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
                        Text('..Sort'),
                      ],
                    ),
                  ),
                  onTap: () {
                    log("Click event on Container");
                    showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return const Sorting();
                        });
                  },
                ),

                const SizedBox(width: 4),

                // InkWell(
                //
                //   child: Container(
                //     padding: EdgeInsets.all(8.0),
                //     child: const Row(
                //       children: <Widget>[
                //         Icon(Icons.filter_alt),
                //         SizedBox(width: 4),
                //         Text('Filter'),
                //       ],
                //     ),
                //   ),
                //
                //   onTap: () {
                //     log("Click event on Container");
                //
                //   },
                // ),

                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        FilterItem(
                          label: 'Category',
                          onTap: () => {
                            log('Filter tapped: Location'),
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return const FilterCategories();
                                })
                          },
                        ),

                        FilterItem(
                          label: 'Location',
                          onTap: () => {
                            log('Filter tapped: Location'),
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return const FilterLocation();
                                })
                          },
                        ),

                        FilterItem(
                          label: 'PECHS',
                          onTap: () => {
                            log('Filter tapped: Location'),
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return const FilterLocation();
                                  //LocationPage(),
                                })
                          },
                        ),
                        FilterItem(
                          label: 'Rs: 500 - Rs:3000',
                          onTap: () => {
                            log('Filter tapped: Location'),
                            showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return const PriceRange();
                                })
                          },
                        ),

                        FilterItem(
                          label: 'Category 2',
                          onTap: () => log('Filter tapped: Category 2'),
                        ),
                        FilterItem(
                          label: 'Category 3',
                          onTap: () => log('Filter tapped: Category 3'),
                        ),
                        // Add more FilterItem widgets as needed
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // Container(
            //   padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
            //
            //   child: Container(
            //     //padding: EdgeInsets.fromLTRB(0, 10, 20, 5),
            //     decoration: BoxDecoration(
            //       color: kSecondaryColor.withOpacity(0.2),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //
            //
            //     child: TabBar(
            //       labelColor: Colors.white,
            //       unselectedLabelColor: Colors.black,
            //       indicator: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10),
            //         color: Colors.pink,
            //       ),
            //       indicatorSize: TabBarIndicatorSize.tab,
            //       tabs: const [
            //         Tab(text: 'List'),
            //         Tab(text: 'Map2'),
            //       ],
            //     ),
            //   ),
            // ),
          ])),
    );
  }
}

class FilterItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterItem({super.key, required this.label, required this.onTap});

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
                style: const TextStyle(
                  color: kPrimaryDarkColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                onPressed: () {
                  log('=--=-=');
                },
                icon: const Icon(
                  Icons.cancel,
                  color: kPrimaryDarkColor,
                  size: 22,
                ),
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

  const CircleIconButton({
    super.key,
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
        padding: const EdgeInsets.all(0), // Remove default padding
        constraints: const BoxConstraints(), // Remove default constraints
      ),
    );
  }
}
