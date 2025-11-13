import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';

class CircularNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double border;

  const CircularNetworkImage({super.key, 
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.border,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: kGradientColorRing,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(border), // Border width
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}