import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import '../viewmodels/deals_view_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app/models/HomePageResponse.dart'
    as HomePage; // Use HomePage.Deal from viewModel
import 'package:app/providers/cart_provider.dart';
import 'package:app/components/cart_bottom_bar.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import '../../../auth/utils/auth_manager.dart';
import '../../../auth/presentation/screens/auth/auth_screen.dart';

class DealsListScreen extends StatefulWidget {
  static const String routeName = '/deals-list';

  const DealsListScreen({Key? key}) : super(key: key);

  @override
  State<DealsListScreen> createState() => _DealsListScreenState();
}

class _DealsListScreenState extends State<DealsListScreen> {
  final ScrollController _scrollController = ScrollController();
  late DealsViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = DealsViewModel();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadDeals();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreDeals();
    }
  }

  void _proceedToBooking() async {
    // Check if user is authenticated
    final token = await AuthManager.getToken();

    if (token == null) {
      // Show sign-in dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'Please sign in to proceed with booking.',
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
                  // Navigate to sign in screen
                  Navigator.pushNamed(context, AuthScreen.routeName);
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

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add deals to cart first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      SelectProfessionals.routeName,
      arguments: {
        'cartItems': cartProvider.items,
        'salonName': cartProvider.salonName,
        'salonId': cartProvider.salonId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Deals',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ChangeNotifierProvider.value(
            value: _viewModel,
            child: Consumer<DealsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return _buildLoadingShimmer();
                }

                if (viewModel.errorMessage != null && viewModel.deals.isEmpty) {
                  return _buildErrorState(viewModel);
                }

                if (viewModel.deals.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshDeals(),
                  color: kPrimaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: viewModel.deals.length + 1,
                    itemBuilder: (context, index) {
                      if (index == viewModel.deals.length) {
                        if (viewModel.isLoadingMore) {
                          return _buildLoadingCard();
                        }
                        if (!viewModel.hasMoreData) {
                          return _buildEndOfListIndicator(viewModel);
                        }
                        return const SizedBox.shrink();
                      }

                      final deal = viewModel.deals[index];
                      return _buildDealCard(context, deal);
                    },
                  ),
                );
              },
            ),
          ),
          // Cart Bottom Bar
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.itemCount == 0) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CartBottomBar(
                  onProceed: _proceedToBooking,
                  buttonText: 'View Cart',
                  proceedButtonText: 'Proceed to Booking',
                  buttonColor: kPrimaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, HomePage.Deal deal) {
    final hasDiscount = deal.discountValue != null && deal.discountValue! > 0;
    final int oldPrice = deal.discountType == 'amount'
        ? (deal.price ?? 0) + (deal.discountValue ?? 0)
        : ((deal.price ?? 0) +
                ((deal.price ?? 0) * (deal.discountValue ?? 0) / 100))
            .toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: kPrimaryColor.withOpacity(0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Discount Badge
              if (hasDiscount)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        deal.discountType == 'amount'
                            ? 'Rs ${deal.discountValue} OFF'
                            : '${deal.discountValue}% OFF',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: hasDiscount ? 8 : 0),

              // Deal Title
              Text(
                deal.name ?? 'No Title',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 5),

              // Services List
              if (deal.services != null && deal.services!.isNotEmpty)
                Text(
                  deal.services!.map((s) => s.name).join(' • '),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 7),

              // Salon Name with Icon
              if (deal.salon?.name != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        size: 13,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        deal.salon!.name!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Price and Book Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price Section
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "PKR ${deal.price ?? 0}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor,
                            height: 1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(height: 2),
                          Text(
                            "PKR $oldPrice",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.red[400],
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Book Button with Cart functionality
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      final isInCart = cart.isInCart(deal);
                      return Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color:
                              isInCart ? Colors.grey.shade400 : kPrimaryColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (isInCart
                                      ? Colors.grey.shade400
                                      : kPrimaryColor)
                                  .withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final success = cart.toggleItem(deal);

                              if (!success && cart.isDifferentSalon(deal)) {
                                // Show confirmation dialog
                                final shouldClear = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Change Salon?'),
                                      content: Text(
                                          'Your cart contains items from ${cart.salonName ?? "another salon"}. '
                                          'Adding items from ${deal.salon?.name ?? "this salon"} will clear your current cart. Continue?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Clear & Continue'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldClear == true) {
                                  cart.toggleItem(deal, forceClear: true);
                                  cart.setSalonInfo(
                                      deal.salon?.id, deal.salon?.name);
                                }
                              } else if (success) {
                                cart.setSalonInfo(
                                    deal.salon?.id, deal.salon?.name);
                              }
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isInCart ? "Added" : "Book Now",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isInCart
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildEndOfListIndicator(DealsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'You\'ve reached the end',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(DealsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              viewModel.errorMessage ?? 'Failed to load deals',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshDeals(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No Deals Found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 10),
            Text(
              'There are no deals available at the moment.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
