// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/cart_provider.dart';
// import '../constants.dart';
// import '../models/salon_detail_models.dart' as salon_models;
// import '../models/HomePageResponse.dart' as home_models;

// String _cartItemTitle(dynamic item) {
//   if (item is salon_models.Service) return item.name ?? 'Service';
//   if (item is home_models.Service) return item.name ?? 'Service';
//   if (item is salon_models.Deal) return item.name ?? 'Deal';
//   if (item is home_models.Deal) return item.name ?? 'Deal';
//   return 'Item';
// }

// double _cartItemUnitPrice(dynamic item) {
//   if (item is salon_models.Service) return (item.price ?? 0).toDouble();
//   if (item is home_models.Service) return (item.price ?? 0).toDouble();
//   if (item is salon_models.Deal) {
//     return (item.totalPrice ?? item.price ?? 0).toDouble();
//   }
//   if (item is home_models.Deal) {
//     return (item.totalPrice ?? item.price ?? 0).toDouble();
//   }
//   return 0.0;
// }

// String? _cartItemDuration(dynamic item) {
//   if (item is salon_models.Service) return item.duration?.toString();
//   if (item is home_models.Service) return item.duration?.toString();
//   return null;
// }

// String? _cartItemDescription(dynamic item) {
//   if (item is salon_models.Service) return item.description;
//   if (item is home_models.Service) return item.description;
//   if (item is salon_models.Deal) {
//     return item.services?.map((s) => s.name).whereType<String>().join(', ');
//   }
//   if (item is home_models.Deal) {
//     return item.services?.map((s) => s.name).whereType<String>().join(', ');
//   }
//   return null;
// }

// Key _cartItemKey(dynamic item, int index) {
//   if (item is salon_models.Service && item.id != null) {
//     return ValueKey('salon_service_${item.id}');
//   }
//   if (item is home_models.Service && item.id != null) {
//     return ValueKey('home_service_${item.id}');
//   }
//   if (item is salon_models.Deal && item.id != null) {
//     return ValueKey('salon_deal_${item.id}');
//   }
//   if (item is home_models.Deal && item.id != null) {
//     return ValueKey('home_deal_${item.id}');
//   }
//   return ValueKey('cart_item_$index');
// }

// /// Global helper class for showing cart modal throughout the app
// class CartModalHelper {
//   /// Show the cart modal from anywhere in the app
//   static void showCartModal(
//     BuildContext context, {
//     VoidCallback? onProceed,
//     String? proceedButtonText,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: true,
//       enableDrag: true,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.75,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 20,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Drag Handle
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 width: 50,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),

//               // Header
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Your Cart',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: -0.5,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Consumer<CartProvider>(
//                           builder: (context, cart, child) => Text(
//                             '${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Consumer<CartProvider>(
//                       builder: (context, cart, child) => cart.itemCount > 0
//                           ? TextButton.icon(
//                               onPressed: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => AlertDialog(
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     title: const Text('Clear Cart?'),
//                                     content: const Text(
//                                       'Are you sure you want to remove all items from your cart?',
//                                     ),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () => Navigator.pop(context),
//                                         child: const Text('Cancel'),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           cart.clearCart();
//                                           Navigator.pop(context);
//                                           Navigator.pop(context);
//                                         },
//                                         style: TextButton.styleFrom(
//                                           foregroundColor: Colors.red,
//                                         ),
//                                         child: const Text('Clear All'),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                               icon: const Icon(Icons.delete_outline, size: 20),
//                               label: const Text('Clear All'),
//                               style: TextButton.styleFrom(
//                                 foregroundColor: Colors.red,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                               ),
//                             )
//                           : const SizedBox.shrink(),
//                     ),
//                   ],
//                 ),
//               ),

//               const Divider(height: 1, thickness: 1),

//               // Cart Items List
//               Expanded(
//                 child: Consumer<CartProvider>(
//                   builder: (context, cart, child) => cart.itemCount == 0
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[100],
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.shopping_cart_outlined,
//                                   size: 64,
//                                   color: Colors.grey[400],
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               Text(
//                                 'Your cart is empty',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Add services or deals to get started',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : ListView.builder(
//                           controller: scrollController,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           itemCount: cart.items.length,
//                           itemBuilder: (context, index) {
//                             final entry = cart.items.entries.elementAt(index);
//                             final item = entry.key;
//                             final quantity = entry.value;

//                             final name = _cartItemTitle(item);
//                             final price = _cartItemUnitPrice(item);
//                             final duration = _cartItemDuration(item);
//                             final description = _cartItemDescription(item);

//                             return Dismissible(
//                               key: _cartItemKey(item, index),
//                               direction: DismissDirection.endToStart,
//                               background: Container(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 alignment: Alignment.centerRight,
//                                 padding: const EdgeInsets.only(right: 20),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: const Icon(
//                                   Icons.delete_outline,
//                                   color: Colors.white,
//                                   size: 28,
//                                 ),
//                               ),
//                               onDismissed: (direction) {
//                                 cart.removeItem(item);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('$name removed from cart'),
//                                     duration: const Duration(seconds: 2),
//                                     behavior: SnackBarBehavior.floating,
//                                     action: SnackBarAction(
//                                       label: 'Undo',
//                                       onPressed: () {
//                                         cart.addItem(item, quantity: quantity);
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: Border.all(
//                                     color: Colors.grey[200]!,
//                                     width: 1.5,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.04),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       // Item Icon
//                                       Container(
//                                         width: 56,
//                                         height: 56,
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             colors: [
//                                               kPrimaryColor.withOpacity(0.15),
//                                               kPrimaryColor.withOpacity(0.05),
//                                             ],
//                                             begin: Alignment.topLeft,
//                                             end: Alignment.bottomRight,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: Icon(
//                                           (item is salon_models.Service ||
//                                                   item is home_models.Service)
//                                               ? Icons.content_cut_rounded
//                                               : Icons.local_offer_rounded,
//                                           color: kPrimaryColor,
//                                           size: 28,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),

//                                       // Item Details
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     name,
//                                                     style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       fontSize: 16,
//                                                       letterSpacing: -0.3,
//                                                     ),
//                                                     maxLines: 2,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                                 IconButton(
//                                                   onPressed: () =>
//                                                       cart.removeItem(item),
//                                                   icon: const Icon(Icons.close),
//                                                   color: Colors.grey[400],
//                                                   iconSize: 20,
//                                                   padding: EdgeInsets.zero,
//                                                   constraints:
//                                                       const BoxConstraints(),
//                                                 ),
//                                               ],
//                                             ),
//                                             if (description != null &&
//                                                 description.isNotEmpty) ...[
//                                               const SizedBox(height: 6),
//                                               Text(
//                                                 description,
//                                                 style: TextStyle(
//                                                   fontSize: 13,
//                                                   color: Colors.grey[600],
//                                                   height: 1.4,
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ],
//                                             if (duration != null) ...[
//                                               const SizedBox(height: 6),
//                                               Row(
//                                                 children: [
//                                                   Icon(
//                                                     Icons.access_time,
//                                                     size: 14,
//                                                     color: Colors.grey[500],
//                                                   ),
//                                                   const SizedBox(width: 4),
//                                                   Text(
//                                                     '$duration min',
//                                                     style: TextStyle(
//                                                       fontSize: 12,
//                                                       color: Colors.grey[600],
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                             const SizedBox(height: 12),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 // Price
//                                                 Container(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                     horizontal: 12,
//                                                     vertical: 6,
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                     gradient: LinearGradient(
//                                                       colors: [
//                                                         kPrimaryColor
//                                                             .withOpacity(0.1),
//                                                         kPrimaryColor
//                                                             .withOpacity(0.05),
//                                                       ],
//                                                     ),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8),
//                                                   ),
//                                                   child: Text(
//                                                     'Rs ${price.toStringAsFixed(0)}',
//                                                     style: const TextStyle(
//                                                       color: kPrimaryColor,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 16,
//                                                     ),
//                                                   ),
//                                                 ),

//                                                 // Quantity controls
//                                                 Container(
//                                                   decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                       color: Colors.grey[300]!,
//                                                     ),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       IconButton(
//                                                         onPressed: () {
//                                                           cart.updateQuantity(
//                                                             item,
//                                                             quantity - 1,
//                                                           );
//                                                         },
//                                                         icon: const Icon(
//                                                           Icons.remove,
//                                                           size: 18,
//                                                         ),
//                                                         color: quantity > 1
//                                                             ? kPrimaryColor
//                                                             : Colors.grey[600],
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8),
//                                                         constraints:
//                                                             const BoxConstraints(),
//                                                       ),
//                                                       Container(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .symmetric(
//                                                           horizontal: 12,
//                                                         ),
//                                                         child: Text(
//                                                           '$quantity',
//                                                           style:
//                                                               const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w700,
//                                                             fontSize: 14,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       IconButton(
//                                                         onPressed: () {
//                                                           cart.updateQuantity(
//                                                             item,
//                                                             quantity + 1,
//                                                           );
//                                                         },
//                                                         icon: const Icon(
//                                                           Icons.add,
//                                                           size: 18,
//                                                         ),
//                                                         color: kPrimaryColor,
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8),
//                                                         constraints:
//                                                             const BoxConstraints(),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ),

//               // Bottom Summary & Actions
//               Consumer<CartProvider>(
//                 builder: (context, cart, child) => cart.itemCount > 0
//                     ? Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.15),
//                               blurRadius: 20,
//                               offset: const Offset(0, -5),
//                             ),
//                           ],
//                         ),
//                         child: SafeArea(
//                           top: false,
//                           child: Padding(
//                             padding: const EdgeInsets.all(24),
//                             child: Column(
//                               children: [
//                                 // Subtotal and Item Count
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Subtotal (${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''})',
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.grey[700],
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Rs ${cart.totalAmount.toStringAsFixed(0)}',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.grey[800],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),

//                                 // Total
//                                 Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         kPrimaryColor.withOpacity(0.1),
//                                         kPrimaryColor.withOpacity(0.05),
//                                       ],
//                                     ),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         'Total Amount',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         'Rs ${cart.totalAmount.toStringAsFixed(0)}',
//                                         style: const TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                           color: kPrimaryColor,
//                                           letterSpacing: -0.5,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),

//                                 // Proceed Button
//                                 SizedBox(
//                                   width: double.infinity,
//                                   height: 56,
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                       if (onProceed != null) {
//                                         onProceed();
//                                       }
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: kPrimaryDarkColor,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(16),
//                                       ),
//                                       elevation: 0,
//                                       shadowColor:
//                                           kPrimaryColor.withOpacity(0.3),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           proceedButtonText ??
//                                               'Proceed to Booking',
//                                           style: const TextStyle(
//                                             fontSize: 17,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 0.3,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Container(
//                                           padding: const EdgeInsets.all(4),
//                                           decoration: BoxDecoration(
//                                             color:
//                                                 Colors.white.withOpacity(0.2),
//                                             borderRadius:
//                                                 BorderRadius.circular(6),
//                                           ),
//                                           child: const Icon(
//                                             Icons.arrow_forward,
//                                             size: 18,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../constants.dart';
import '../models/salon_detail_models.dart' as salon_models;
import '../models/HomePageResponse.dart' as home_models;

// ─── Design tokens ────────────────────────────────────────────────────────────
/// ─── Design tokens (OLD THEME COLORS) ──────────────────────────────────────

const _kPrimary      = kPrimaryColor;
const _kPrimaryLight = Color(0xFFF3EFFF);
const _kPrimaryMid   = kPrimaryColor;
const _kPrimaryDark  = kPrimaryDarkColor;

const _kTextDark     = Color(0xFF1F1F1F);
const _kMuted        = Color(0xFF757575);

const _kBorder       = Color(0xFFE6E6E6);
const _kBg           = Color(0xFFF8F8F8);
const _kCardBg       = Colors.white;

const _kDanger       = Colors.red;
const _kDangerLight  = Color(0xFFFFEBEE);

// ─── Item helpers ─────────────────────────────────────────────────────────────

String _cartItemTitle(dynamic item) {
  if (item is salon_models.Service) return item.name ?? 'Service';
  if (item is home_models.Service)  return item.name ?? 'Service';
  if (item is salon_models.Deal)    return item.name ?? 'Deal';
  if (item is home_models.Deal)     return item.name ?? 'Deal';
  return 'Item';
}

double _cartItemUnitPrice(dynamic item) {
  if (item is salon_models.Service) return (item.price ?? 0).toDouble();
  if (item is home_models.Service)  return (item.price ?? 0).toDouble();
  if (item is salon_models.Deal)    return (item.totalPrice ?? item.price ?? 0).toDouble();
  if (item is home_models.Deal)     return (item.totalPrice ?? item.price ?? 0).toDouble();
  return 0.0;
}

String? _cartItemDuration(dynamic item) {
  if (item is salon_models.Service) return item.duration?.toString();
  if (item is home_models.Service)  return item.duration?.toString();
  return null;
}

String? _cartItemDescription(dynamic item) {
  if (item is salon_models.Service) return item.description;
  if (item is home_models.Service)  return item.description;
  if (item is salon_models.Deal) {
    return item.services?.map((s) => s.name).whereType<String>().join(' • ');
  }
  if (item is home_models.Deal) {
    return item.services?.map((s) => s.name).whereType<String>().join(' • ');
  }
  return null;
}

bool _isService(dynamic item) =>
    item is salon_models.Service || item is home_models.Service;

Key _cartItemKey(dynamic item, int index) {
  if (item is salon_models.Service && item.id != null) return ValueKey('salon_service_${item.id}');
  if (item is home_models.Service  && item.id != null) return ValueKey('home_service_${item.id}');
  if (item is salon_models.Deal    && item.id != null) return ValueKey('salon_deal_${item.id}');
  if (item is home_models.Deal     && item.id != null) return ValueKey('home_deal_${item.id}');
  return ValueKey('cart_item_$index');
}

// ─── CartModalHelper ──────────────────────────────────────────────────────────

class CartModalHelper {
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
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, scrollController) => _CartSheet(
          scrollController: scrollController,
          onProceed: onProceed,
          proceedButtonText: proceedButtonText,
        ),
      ),
    );
  }
}

// ─── Cart sheet widget ────────────────────────────────────────────────────────

class _CartSheet extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback? onProceed;
  final String? proceedButtonText;

  const _CartSheet({
    required this.scrollController,
    this.onProceed,
    this.proceedButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 6),
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _CartHeader(),

          // Thin divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: _kBorder,
          ),

          // Items list — expands
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) => cart.itemCount == 0
                  ? _EmptyCartView()
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final entry = cart.items.entries.elementAt(index);
                        return _CartItemTile(
                          item: entry.key,
                          quantity: entry.value,
                          index: index,
                        );
                      },
                    ),
            ),
          ),

          // Summary + CTA
          Consumer<CartProvider>(
            builder: (context, cart, _) => cart.itemCount > 0
                ? _CartSummary(
                    cart: cart,
                    onProceed: onProceed,
                    proceedButtonText: proceedButtonText,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 14),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: _kPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Title + count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Cart',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                    letterSpacing: -0.4,
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (_, cart, __) => Text(
                    cart.itemCount == 0
                        ? 'No items yet'
                        : '${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      fontSize: 13,
                      color: _kMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Clear button
          Consumer<CartProvider>(
            builder: (context, cart, _) => cart.itemCount > 0
                ? _ClearButton(cart: cart)
                : const SizedBox(width: 44),
          ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final CartProvider cart;
  const _ClearButton({required this.cart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _ClearCartDialog(cart: cart),
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _kDangerLight,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: _kDanger,
          size: 20,
        ),
      ),
    );
  }
}

class _ClearCartDialog extends StatelessWidget {
  final CartProvider cart;
  const _ClearCartDialog({required this.cart});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Clear Cart?',
        style: TextStyle(fontWeight: FontWeight.w800, color: _kTextDark),
      ),
      content: const Text(
        'Are you sure you want to remove all items from your cart?',
        style: TextStyle(color: _kMuted, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: _kMuted, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () {
            cart.clearCart();
            Navigator.pop(context);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: _kDanger),
          child: const Text('Clear All',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 52,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _kTextDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add services or deals to get started',
            style: TextStyle(
              fontSize: 14,
              color: _kMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart item tile ───────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final int quantity;
  final int index;

  const _CartItemTile({
    required this.item,
    required this.quantity,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cart     = Provider.of<CartProvider>(context, listen: false);
    final name     = _cartItemTitle(item);
    final price    = _cartItemUnitPrice(item);
    final duration = _cartItemDuration(item);
    final desc     = _cartItemDescription(item);
    final isServ   = _isService(item);

    return Dismissible(
      key: _cartItemKey(item, index),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _kDanger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) {
        cart.removeItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name removed from cart'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _kTextDark,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(14),
            action: SnackBarAction(
              label: 'Undo',
              textColor: _kPrimaryMid,
              onPressed: () => cart.addItem(item, quantity: quantity),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isServ
                      ? Icons.content_cut_rounded
                      : Icons.local_offer_rounded,
                  color: _kPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + close
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: _kTextDark,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => cart.removeItem(item),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 15, color: _kMuted),
                          ),
                        ),
                      ],
                    ),

                    // Description
                    if (desc != null && desc.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kMuted,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Duration badge
                    if (duration != null) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: _kMuted),
                            const SizedBox(width: 4),
                            Text(
                              '$duration min',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _kMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Price + qty controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kPrimaryLight,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            'Rs ${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: _kPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),

                        // Qty stepper
                        _QuantityStepper(
                          quantity: quantity,
                          onDecrement: () =>
                              cart.updateQuantity(item, quantity - 1),
                          onIncrement: () =>
                              cart.updateQuantity(item, quantity + 1),
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
  }
}

// ─── Quantity stepper ─────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: quantity > 1 ? _kPrimaryLight : const Color(0xFFF3F4F6),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(9)),
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 17,
                color: quantity > 1 ? _kPrimary : _kMuted,
              ),
            ),
          ),

          // Count
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: _kTextDark,
              ),
            ),
          ),

          // Plus
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(9)),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 17,
                color: _kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom summary ───────────────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  final CartProvider cart;
  final VoidCallback? onProceed;
  final String? proceedButtonText;

  const _CartSummary({
    required this.cart,
    this.onProceed,
    this.proceedButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtotal row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal (${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''})',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Rs ${cart.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kTextDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Total banner
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFC4B5FD), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kPrimaryDark,
                      ),
                    ),
                    Text(
                      'Rs ${cart.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _kPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Proceed button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onProceed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: _kPrimary.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        proceedButtonText ?? 'Proceed to Booking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
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
    );
  }
}
