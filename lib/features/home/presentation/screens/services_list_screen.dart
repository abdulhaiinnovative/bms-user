import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import '../viewmodels/services_view_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app/models/HomePageResponse.dart'
    as HomePage; // Use HomePage.Service from viewModel
import 'package:app/providers/cart_provider.dart';
import 'package:app/components/cart_bottom_bar.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';

class ServicesListScreen extends StatefulWidget {
  static const String routeName = '/services-list';

  final ServiceGender gender;

  const ServicesListScreen({
    Key? key,
    required this.gender,
  }) : super(key: key);

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final ScrollController _scrollController = ScrollController();
  late ServicesViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ServicesViewModel(gender: widget.gender);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadServices();
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
      _viewModel.loadMoreServices();
    }
  }

  void _proceedToBooking() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add services to cart first'),
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
        title: Text(
          _viewModel.title,
          style: const TextStyle(
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
            child: Consumer<ServicesViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return _buildLoadingShimmer();
                }

                if (viewModel.errorMessage != null &&
                    viewModel.services.isEmpty) {
                  return _buildErrorState(viewModel);
                }

                if (viewModel.services.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshServices(),
                  color: kPrimaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: viewModel.services.length + 1,
                    itemBuilder: (context, index) {
                      if (index == viewModel.services.length) {
                        if (viewModel.isLoadingMore) {
                          return _buildLoadingCard();
                        }
                        if (!viewModel.hasMoreData) {
                          return _buildEndOfListIndicator(viewModel);
                        }
                        return const SizedBox.shrink();
                      }

                      final service = viewModel.services[index];
                      return _buildServiceCard(context, service);
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

  Widget _buildServiceCard(BuildContext context, HomePage.Service service) {
    final hasDiscount =
        service.discountType != null && service.oldPrice != null;

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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      const Icon(Icons.local_offer_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${((service.oldPrice! - service.price!) / service.oldPrice! * 100).toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: hasDiscount ? 6 : 0),

              // Service Title
              Text(
                service.name ?? 'No Title',
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

              // Description
              if (service.shortDescription != null &&
                  service.shortDescription!.isNotEmpty)
                Text(
                  service.shortDescription!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 6),

              // Duration and Gender Tags
              Row(
                children: [
                  // Duration Tag
                  if (service.duration != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${service.duration} min',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (service.duration != null && service.gender != null)
                    const SizedBox(width: 6),

                  // Gender Tag
                  if (service.gender != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: service.gender?.toLowerCase() == 'male'
                            ? Colors.blue.withOpacity(0.1)
                            : service.gender?.toLowerCase() == 'female'
                                ? Colors.pink.withOpacity(0.1)
                                : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service.gender?.toLowerCase() == 'male'
                                ? Icons.male
                                : service.gender?.toLowerCase() == 'female'
                                    ? Icons.female
                                    : Icons.people,
                            size: 11,
                            color: service.gender?.toLowerCase() == 'male'
                                ? Colors.blue.shade700
                                : service.gender?.toLowerCase() == 'female'
                                    ? Colors.pink.shade700
                                    : Colors.purple.shade700,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            service.gender!.substring(0, 1).toUpperCase() +
                                service.gender!.substring(1).toLowerCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: service.gender?.toLowerCase() == 'male'
                                  ? Colors.blue.shade700
                                  : service.gender?.toLowerCase() == 'female'
                                      ? Colors.pink.shade700
                                      : Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(
                  height: (service.duration != null || service.gender != null)
                      ? 6
                      : 0),

              // Salon Info
              if (service.salon?.name != null)
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.5),
                        child: (service.salon?.image != null &&
                                service.salon!.image!.isNotEmpty)
                            ? Image.network(
                                service.salon!.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.store_rounded,
                                    size: 16,
                                    color: kPrimaryColor.withOpacity(0.5),
                                  );
                                },
                              )
                            : Icon(
                                Icons.store_rounded,
                                size: 16,
                                color: kPrimaryColor.withOpacity(0.5),
                              ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        service.salon!.name!,
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

              const SizedBox(height: 10),

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
                          "PKR ${service.price ?? 0}",
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
                            "PKR ${service.oldPrice}",
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
                      final isInCart = cart.isInCart(service);
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
                              final success = cart.toggleItem(service);

                              if (!success && cart.isDifferentSalon(service)) {
                                // Show confirmation dialog
                                final shouldClear = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Change Salon?'),
                                      content: Text(
                                          'Your cart contains items from ${cart.salonName ?? "another salon"}. '
                                          'Adding items from ${service.salon?.name ?? "this salon"} will clear your current cart. Continue?'),
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
                                  cart.toggleItem(service, forceClear: true);
                                  cart.setSalonInfo(
                                      service.salon?.id, service.salon?.name);
                                }
                              } else if (success) {
                                cart.setSalonInfo(
                                    service.salon?.id, service.salon?.name);
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
            height: 200,
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
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildEndOfListIndicator(ServicesViewModel viewModel) {
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

  Widget _buildErrorState(ServicesViewModel viewModel) {
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
              viewModel.errorMessage ?? 'Failed to load services',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshServices(),
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
            Icon(Icons.spa_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No Services Found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 10),
            Text(
              'There are no services available at the moment.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
