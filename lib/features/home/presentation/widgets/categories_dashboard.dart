import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/features/search/presentation/screens/search_service_screen_new.dart';
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
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: SectionTitle(
                  title: section.heading,
                  press: () => _showAllCategoriesModal(context, section),
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
                        Navigator.pushNamed(
                          context,
                          SearchServiceScreenNew.routeName,
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

  /// Show bottom modal with all categories
  void _showAllCategoriesModal(BuildContext context, CategorySection section) {
    log('📋 Showing all categories modal for: ${section.heading}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header section with title and count
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Column(
                      children: [
                        Text(
                          section.heading,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${section.data.length} ${section.data.length == 1 ? 'Category' : 'Categories'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[200],
                  ),

                  // Categories list
                  Expanded(
                    child: section.data.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No categories available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: section.data.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final item = section.data[index];

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    log('Category selected from modal: ${item.name}');
                                    Navigator.pop(context); // Close modal
                                    Navigator.pushNamed(
                                      context,
                                      SearchServiceScreenNew.routeName,
                                      arguments: {
                                        'categoryName': item.name,
                                        'categoryId': item.id,
                                        'isFromBottomNav': true,
                                      },
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Category name
                                        Expanded(
                                          child: Text(
                                            item.name ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                        // Arrow icon
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color:
                                                kPrimaryColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            );
          },
        );
      },
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: kPrimaryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kPrimaryColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
