import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../constants.dart';
import '../utils/cart_modal_helper.dart';

/// Reusable cart bottom bar component for the entire app
/// Shows cart summary and provides quick access to proceed with booking
class CartBottomBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onProceed;
  final String? buttonText;
  final String? proceedButtonText;
  final Color? buttonColor;
  final bool showItemCount;
  final int? totalItemsOverride;
  final double? totalAmountOverride;

  const CartBottomBar({
    Key? key,
    this.onTap,
    this.onProceed,
    this.buttonText,
    this.proceedButtonText,
    this.buttonColor,
    this.showItemCount = true,
    this.totalItemsOverride,
    this.totalAmountOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final displayItemCount = totalItemsOverride ?? cart.itemCount;
        final displayTotalAmount = totalAmountOverride ?? cart.totalAmount;

        // Hide if cart is empty
        if (displayItemCount == 0) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Cart info section
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showItemCount)
                          Text(
                            '$displayItemCount ${displayItemCount == 1 ? 'Item' : 'Items'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Rs ${displayTotalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Action button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (onTap != null) {
                            onTap!();
                          } else {
                            // Use global cart modal
                            CartModalHelper.showCartModal(
                              context,
                              onProceed: onProceed,
                              proceedButtonText: proceedButtonText,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                buttonColor ?? kPrimaryColor,
                                (buttonColor ?? kPrimaryColor).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (buttonColor ?? kPrimaryColor)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  buttonText ?? 'View Cart',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
