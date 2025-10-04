import 'package:flutter/material.dart';

class CartSummarySection extends StatelessWidget {
  final int totalItems;
  final double totalAmount;
  final VoidCallback onContinue;
  final Color buttonColor;

  const CartSummarySection({
    super.key,
    required this.totalItems,
    required this.totalAmount,
    required this.onContinue,
    this.buttonColor = Colors.black, // Default to black or use your kPrimaryDarkColor
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // color: Colors.grey,
        // padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalItems Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Total: Rs ${totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
