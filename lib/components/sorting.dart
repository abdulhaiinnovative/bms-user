import 'package:flutter/material.dart';

import '../constants.dart';

class Sorting extends StatelessWidget {
  const Sorting({
    Key? key,
  }) : super(key: key);

  static  int _selectedOptionIndex = 0;
  static  List<String> _sortingOptions = [
    'Sort by Service Name (A to Z)',
    'Sort by Service Name (Z to A)',
    'Sort by Price (High to Low)',
    'Sort by Price (Low to High)',
    'Sort by Rating (High to Low)',
    'Sort by Rating (Low to High)',
    'Sort by Added (Latest)',
    'Sort by Added (Old)',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0),
      child: Wrap(
        children: _sortingOptions.map((option) {
          int index = _sortingOptions.indexOf(option);
          return ListTile(
            title: Text(option),
            trailing: _selectedOptionIndex == index
                ? Icon(Icons.check, color: kPrimaryColor)
                : null,
            onTap: () {
              //setState(() {
              _selectedOptionIndex = index;
              //});
              Navigator.pop(context);
            },
          );
        }).toList(),

      ),
    );
  }
}
