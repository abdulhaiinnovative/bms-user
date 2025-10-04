import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app/constants.dart';

class SaleAmount extends StatelessWidget {
  final int sale;

  SaleAmount({
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black26,
          //   blurRadius: 2,
          //   offset: Offset(2, 2),
          // ),
        ],
      ),
      child: Row(
        children: [
          //

          SizedBox(width: 5),
          Text(
            'Save Rs: ${sale}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
