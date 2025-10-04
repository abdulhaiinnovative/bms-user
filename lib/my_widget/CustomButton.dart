import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding; // Change to EdgeInsetsGeometry type
  final double width; // Add width parameter

  const CustomButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    //this.padding = const EdgeInsets.only(left: 25.0, right: 25, top: 16), // Use default value correctly
    this.padding = const EdgeInsets.all(16),
    this.width = double.infinity, // Default to full width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding, // Use the padding property here
      child: SizedBox( // Use SizedBox to define the width
        width: width, // Set the desired width
        child: ElevatedButton(
          onPressed: onPressed, // Use the onPressed callback here
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Button background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(vertical: 18), // Padding inside the button
            elevation: 2, // Adjust the elevation as needed
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
