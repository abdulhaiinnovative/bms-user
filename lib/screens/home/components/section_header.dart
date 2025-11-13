import 'package:flutter/material.dart';

import '../../../constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllPressed;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      padding: const EdgeInsets.symmetric(
        //horizontal: 20,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        //color: const Color(0xFF4A3298),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAllPressed,
            child: const Text(
              'See All',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
