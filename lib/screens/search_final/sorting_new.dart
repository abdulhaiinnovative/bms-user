import 'package:flutter/material.dart';


class SortingNew extends StatelessWidget {
  final int tabIndex;

  const SortingNew({Key? key, required this.tabIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define sorting options for each tab (Services, Deals, Salons)
    final List<Map<String, dynamic>> sortingOptions = tabIndex == 0
        ? [
      {'label': 'Sort by Name (A to Z)', 'sortBy': 'name', 'sortOrder': 'asc'},
      {'label': 'Sort by Name (Z to A)', 'sortBy': 'name', 'sortOrder': 'desc'},
      {'label': 'Sort by Price (High to Low)', 'sortBy': 'price', 'sortOrder': 'desc'},
      {'label': 'Sort by Price (Low to High)', 'sortBy': 'price', 'sortOrder': 'asc'},
    ]
        : tabIndex == 1
        ? [
      {'label': 'Sort by Name (A to Z)', 'sortBy': 'name', 'sortOrder': 'asc'},
      {'label': 'Sort by Name (Z to A)', 'sortBy': 'name', 'sortOrder': 'desc'},
      {'label': 'Sort by Price (High to Low)', 'sortBy': 'total_price', 'sortOrder': 'desc'},
      {'label': 'Sort by Price (Low to High)', 'sortBy': 'total_price', 'sortOrder': 'asc'},
    ]
        : [
      {'label': 'Sort by Name (A to Z)', 'sortBy': 'name', 'sortOrder': 'asc'},
      {'label': 'Sort by Name (Z to A)', 'sortBy': 'name', 'sortOrder': 'desc'},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0),
      child: Wrap(
        children: sortingOptions.asMap().entries.map((entry) {
          Map<String, dynamic> option = entry.value;
          return ListTile(
            title: Text(option['label']),
            trailing: null, // Checkmark can be added if needed
            onTap: () {
              Navigator.pop(context, {
                'sortBy': option['sortBy'],
                'sortOrder': option['sortOrder'],
              });
            },
          );
        }).toList(),
      ),
    );
  }
}