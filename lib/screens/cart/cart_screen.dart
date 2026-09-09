import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
// import '../../models/SalonServicesCategorizedResponse.dart'; // Unused import removed
import 'package:app/models/salon_detail_models.dart' as salon_models;
import 'package:app/models/HomePageResponse.dart' as home_models;
import '../../constants.dart';
import '../../utils/currency_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../test_scroll/select_professionals.dart';
import '../test_scroll/SelectDateScreen.dart';
import '../../utils/restriction_handler.dart';
import '../../features/profile/presentation/viewmodels/profile_view_model.dart';
import '../../features/auth/utils/auth_manager.dart';
import '../../features/auth/presentation/screens/auth/auth_screen.dart';

class CartScreen extends StatelessWidget {
  static String routeName = "/cart";

  const CartScreen({super.key});

  bool _cartHasServices(Map<dynamic, int> items) {
    return items.keys.any(
      (item) => item is salon_models.Service || item is home_models.Service,
    );
  }

  void _handleProceed(BuildContext context, CartProvider cart) async {
    if (cart.itemCount == 0) return;

    // Check if user is authenticated first
    final token = await AuthManager.getToken();
    if (token == null) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'Please sign in to proceed with checkout.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Get user profile data
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

    // Check if user can book (validates status, restriction, and profile completeness)
    final canBook = await RestrictionHandler.canUserBook(
      isRestricted: profileViewModel.userData?.isRestricted,
      status: profileViewModel.userData?.status,
      completeStatus: profileViewModel.userData?.completeStatus,
      context: context,
    );

    if (!canBook) {
      // RestrictionHandler already showed the appropriate dialog
      return;
    }

    final hasServices = _cartHasServices(cart.items);
    if (hasServices) {
      Navigator.pushNamed(
        context,
        SelectProfessionals.routeName,
        arguments: {
          'cartItems': cart.items,
          'salonName': cart.salonName,
          'salonImage': null,
          'salonAddress': null,
          'salon': null,
        },
      );
      return;
    }

    // Deals-only cart: skip professional selection and go directly to calendar.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectDateScreen(),
        settings: RouteSettings(
          arguments: {
            'cartItems': cart.items,
            'salonName': cart.salonName,
            'salonImage': null,
            'salonAddress': null,
            'salon': null,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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
            );
          }

          return Column(
            children: [
              // Salon info section (if available)
              if (cart.salonName != null && cart.salonName!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (cart.salonLogo != null && cart.salonLogo!.isNotEmpty)
                                ? Image.network(
                              cart.salonLogo!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                                : (cart.salonImage != null && cart.salonImage!.isNotEmpty)
                                ? Image.network(
                              cart.salonImage!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[200],
                              child: const Icon(Icons.store, size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Booking at',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cart.salonName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final entry = cart.items.entries.elementAt(index);
                    final item = entry.key;
                    final quantity = entry.value;

                    return _buildCartItem(context, cart, item, quantity);
                  },
                ),
              ),

              // Enhanced summary section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Item count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Items',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatCurrency(
                                  cart.totalAmount),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatCurrency(
                                  cart.totalAmount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Checkout button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleProceed(context, cart);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartProvider cart, dynamic item, int quantity) {
    String name = '';
    double price = 0.0;
    String? imageUrl;
    bool isDeal = false;

    if (item is salon_models.Service) {
      name = item.name ?? 'Service';
      price = (item.price ?? 0).toDouble();
      isDeal = false;
    } else if (item is home_models.Service) {
      name = item.name ?? 'Service';
      price = (item.price ?? 0).toDouble();
      isDeal = false;
    } else if (item is salon_models.Deal) {
      name = item.name ?? 'Deal';
      price = (item.totalPrice ?? item.price ?? 0).toDouble();
      imageUrl = item.image;
      isDeal = true;
    } else if (item is home_models.Deal) {
      name = item.name ?? 'Deal';
      price = (item.totalPrice ?? item.price ?? 0).toDouble();
      imageUrl = item.image;
      isDeal = true;
    } else {
      name = 'Item';
      price = 0.0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: isDeal && imageUrl == null
                      ? const LinearGradient(
                          colors: [kPrimaryColor, kPrimaryDarkColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isDeal && imageUrl == null
                      ? null
                      : kPrimaryLightColor.withOpacity(0.15),
                ),
                child: isDeal && imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimaryColor,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.local_offer,
                          size: 28,
                          color: kPrimaryColor,
                        ),
                      )
                    : Icon(
                        isDeal ? Icons.local_offer : Icons.content_cut,
                        size: 28,
                        color: isDeal && imageUrl == null
                            ? Colors.white
                            : kPrimaryColor,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          cart.removeItem(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name removed from cart'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isDeal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.formatCurrency(price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: quantity > 1
                                  ? () =>
                                      cart.updateQuantity(item, quantity - 1)
                                  : null,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: quantity > 1
                                      ? kPrimaryColor
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  cart.updateQuantity(item, quantity + 1),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: kPrimaryColor,
                                ),
                              ),
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
    );
  }
}
