import 'package:flutter/material.dart';

class CustomButtonGoogle extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const CustomButtonGoogle({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 16),
      child: GestureDetector(
        onTap: onPressed, // Use the onPressed callback here
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: color,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 18),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
