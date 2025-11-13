import 'package:flutter/material.dart';


class PriceRange extends StatelessWidget {
  const PriceRange({
    Key? key,
  }) : super(key: key);

  static RangeValues _currentRangeValues = const RangeValues(20, 80);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Wrap(
        children:[





        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Price Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return RangeSlider(
                    values: _currentRangeValues,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    labels: RangeLabels(
                      _currentRangeValues.start.round().toString(),
                      _currentRangeValues.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Min:  ${_currentRangeValues.start.round()} Rupees',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Max:  ${_currentRangeValues.end.round()} Rupees',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),

    ]


      ),
    );
  }
}
