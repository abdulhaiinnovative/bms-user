import 'package:flutter/material.dart';
import 'package:app/constants.dart';

class ReviewCount extends StatelessWidget {
  final int reviews;

  ReviewCount({
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black26,
        //     blurRadius: 4,
        //     offset: Offset(2, 2),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          // Icon(
          //   Icons.location_pin,
          //   color: Colors.amber,
          //   size: 20,
          // ),
          SizedBox(width: 5),
          Text(
            '(${reviews}) Reviews',
            style: const TextStyle(
              color: Colors.black,
            ),

          ),
        ],
      ),
    );
  }
}
