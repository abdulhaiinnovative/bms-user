import 'dart:developer';

import 'package:flutter/material.dart';

class CartSummarySection extends StatefulWidget {
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
  State<CartSummarySection> createState() => _CartSummarySectionState();
}

class _CartSummarySectionState extends State<CartSummarySection> {
@override
void initState() {
  super.initState();
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');

  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
  log(  '🛒 CartSummarySection: totalItems=${widget.totalItems}, totalAmount=${widget.totalAmount}');
}
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
                  '${widget.totalItems} Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Total: Rs ${widget.totalAmount.toStringAsFixed(0)}',
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
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.buttonColor,
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
