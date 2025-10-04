import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../models/Cart.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: AspectRatio(
            aspectRatio: 0.88,
            child: 
            
            
            // Container(
            //   padding: const EdgeInsets.all(4),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFF5F6F9),
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child: Image.network(cart.product.images[0],
            //     fit: BoxFit.cover,),
            // ),


              ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for images
                child: Image.network(
                  cart.product.images[0],
                  fit: BoxFit.cover,
                ),
              ),
            
            
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cart.product.title,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              maxLines: 2, // Limits the text to 2 lines
              overflow: TextOverflow.ellipsis, // Adds an ellipsis (...) at the end if text is too long
              softWrap: true, // Allows text to wrap onto the next line
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "\$${cart.product.price}",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: kPrimaryColor),
                children: [
                  TextSpan(
                      text: " x${cart.numOfItem}",
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
