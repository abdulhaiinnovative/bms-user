import 'package:flutter/material.dart';
import 'package:app/constants.dart';

class Ratings extends StatelessWidget {
  final int rating;
  final bool compact; // New argument for compact mode

  const Ratings({
    required this.rating,
    this.compact = false, // Default is full stars view
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (compact)
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            )
          else
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  color: index < rating ? Colors.amber : Colors.grey[400],
                  size: 20,
                );
              }),
            ),
          const SizedBox(width: 5),
          Text(
            '$rating',
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
