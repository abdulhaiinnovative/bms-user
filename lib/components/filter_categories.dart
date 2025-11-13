import 'package:flutter/material.dart';

import '../constants.dart';

class FilterCategories extends StatelessWidget {
  const FilterCategories({
    Key? key,
  }) : super(key: key);

  static  int _selectedOptionIndex = 0;
  static  final List<String> _sortingOptions = [
    'Bridal',
    'Nails',
    'Make up',
    'Massage',
    'Hair cut',
    'Hair style',
    'Eye',
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
                ? const Icon(Icons.check, color: kPrimaryColor)
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
