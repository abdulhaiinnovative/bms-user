import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../constants.dart';
import '../models/salon_detail_models.dart' as salon_models;
import '../models/HomePageResponse.dart' as home_models;

String _cartItemTitle(dynamic item) {
  if (item is salon_models.Service) return item.name ?? 'Service';
  if (item is home_models.Service) return item.name ?? 'Service';
  if (item is salon_models.Deal) return item.name ?? 'Deal';
  if (item is home_models.Deal) return item.name ?? 'Deal';
  return 'Item';
}

double _cartItemUnitPrice(dynamic item) {
  if (item is salon_models.Service) return (item.price ?? 0).toDouble();
  if (item is home_models.Service) return (item.price ?? 0).toDouble();
  if (item is salon_models.Deal) {
    return (item.totalPrice ?? item.price ?? 0).toDouble();
  }
  if (item is home_models.Deal) {
    return (item.totalPrice ?? item.price ?? 0).toDouble();
  }
  return 0.0;
}

String? _cartItemDuration(dynamic item) {
  if (item is salon_models.Service) return item.duration?.toString();
  if (item is home_models.Service) return item.duration?.toString();
  return null;
}

String? _cartItemDescription(dynamic item) {
  if (item is salon_models.Service) return item.description;
  if (item is home_models.Service) return item.description;
  if (item is salon_models.Deal) {
    return item.services?.map((s) => s.name).whereType<String>().join(', ');
  }
  if (item is home_models.Deal) {
    return item.services?.map((s) => s.name).whereType<String>().join(', ');
  }
  return null;
}

Key _cartItemKey(dynamic item, int index) {
  if (item is salon_models.Service && item.id != null) {
    return ValueKey('salon_service_${item.id}');
  }
  if (item is home_models.Service && item.id != null) {
    return ValueKey('home_service_${item.id}');
  }
  if (item is salon_models.Deal && item.id != null) {
    return ValueKey('salon_deal_${item.id}');
  }
  if (item is home_models.Deal && item.id != null) {
    return ValueKey('home_deal_${item.id}');
  }
  return ValueKey('cart_item_$index');
}

/// Global helper class for showing cart modal throughout the app
class CartModalHelper {
  /// Show the cart modal from anywhere in the app
  static void showCartModal(
    BuildContext context, {
    VoidCallback? onProceed,
    String? proceedButtonText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Cart',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) => Text(
                            '${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) => cart.itemCount > 0
                          ? TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text('Clear Cart?'),
                                    content: const Text(
                                      'Are you sure you want to remove all items from your cart?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          cart.clearCart();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Clear All'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text('Clear All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Cart Items List
              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) => cart.itemCount == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add services or deals to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final entry = cart.items.entries.elementAt(index);
                            final item = entry.key;
                            final quantity = entry.value;

                            final name = _cartItemTitle(item);
                            final price = _cartItemUnitPrice(item);
                            final duration = _cartItemDuration(item);
                            final description = _cartItemDescription(item);

                            return Dismissible(
                              key: _cartItemKey(item, index),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (direction) {
                                cart.removeItem(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$name removed from cart'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        cart.addItem(item, quantity: quantity);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Item Icon
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              kPrimaryColor.withOpacity(0.15),
                                              kPrimaryColor.withOpacity(0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          (item is salon_models.Service ||
                                                  item is home_models.Service)
                                              ? Icons.content_cut_rounded
                                              : Icons.local_offer_rounded,
                                          color: kPrimaryColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Item Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      letterSpacing: -0.3,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      cart.removeItem(item),
                                                  icon: const Icon(Icons.close),
                                                  color: Colors.grey[400],
                                                  iconSize: 20,
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                            if (description != null &&
                                                description.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                description,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                  height: 1.4,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            if (duration != null) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$duration min',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Price
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        kPrimaryColor
                                                            .withOpacity(0.1),
                                                        kPrimaryColor
                                                            .withOpacity(0.05),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    'Rs ${price.toStringAsFixed(0)}',
                                                    style: const TextStyle(
                                                      color: kPrimaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),

                                                // Quantity controls
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          cart.updateQuantity(
                                                            item,
                                                            quantity - 1,
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.remove,
                                                          size: 18,
                                                        ),
                                                        color: quantity > 1
                                                            ? kPrimaryColor
                                                            : Colors.grey[600],
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                        ),
                                                        child: Text(
                                                          '$quantity',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          cart.updateQuantity(
                                                            item,
                                                            quantity + 1,
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.add,
                                                          size: 18,
                                                        ),
                                                        color: kPrimaryColor,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Bottom Summary & Actions
              Consumer<CartProvider>(
                builder: (context, cart, child) => cart.itemCount > 0
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Subtotal and Item Count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subtotal (${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''})',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Rs ${cart.totalAmount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Total
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        kPrimaryColor.withOpacity(0.1),
                                        kPrimaryColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rs ${cart.totalAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Proceed Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (onProceed != null) {
                                        onProceed();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryDarkColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      shadowColor:
                                          kPrimaryColor.withOpacity(0.3),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          proceedButtonText ??
                                              'Proceed to Booking',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
