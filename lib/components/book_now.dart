import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app/constants.dart';

class BookNow extends StatelessWidget {

  BookNow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimaryDarkColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Book Now',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
