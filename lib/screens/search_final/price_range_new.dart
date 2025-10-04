import 'package:flutter/material.dart';

import '../../constants.dart';



class PriceRangeNew extends StatefulWidget {
  const PriceRangeNew({Key? key}) : super(key: key);

  @override
  _PriceRangeNewState createState() => _PriceRangeNewState();
}

class _PriceRangeNewState extends State<PriceRangeNew> {
  RangeValues _currentRangeValues = const RangeValues(100, 100000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Price Range',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          RangeSlider(
            values: _currentRangeValues,
            min: 100,
            max: 100000,
            divisions: 999, // (100000 - 100) / 100 = 999 steps
            labels: RangeLabels(
              'Rs ${_currentRangeValues.start.round()}',
              'Rs ${_currentRangeValues.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
            activeColor: kPrimaryColor,
            inactiveColor: kPrimaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: Rs ${_currentRangeValues.start.round()}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Max: Rs ${_currentRangeValues.end.round()}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'minPrice': _currentRangeValues.start,
                'maxPrice': _currentRangeValues.end,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Apply', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}