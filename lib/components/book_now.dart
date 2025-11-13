import 'package:flutter/material.dart';
import 'package:app/constants.dart';

class BookNow extends StatelessWidget {
  final VoidCallback? onTap;

  const BookNow({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: kPrimaryDarkColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Book Now',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
