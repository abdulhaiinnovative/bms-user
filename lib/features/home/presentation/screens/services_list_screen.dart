import 'package:app/features/home/presentation/screens/service_detail_screen.dart';
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
import 'package:app/features/auth/utils/auth_manager.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';

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

  Future<void> _proceedToBooking() async {
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

    // Check if user is authenticated
    final token = await AuthManager.getToken();
    if (token == null) {
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

                final double screenWidth = MediaQuery.of(context).size.width;
                final bool isWide = screenWidth > 500;

                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshServices(),
                  color: kPrimaryColor,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (isWide)
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 16,top: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.62,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final service = viewModel.services[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ServiceDetailScreen(serviceId: service.id!),
                                      ),
                                    );
                                  },
                                  child: _buildServiceCard(context, service, isWide: true),
                                );
                              },
                              childCount: viewModel.services.length,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final service = viewModel.services[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ServiceDetailScreen(serviceId: service.id!),
                                        ),
                                      );
                                    },
                                    child: _buildServiceCard(context, service, isWide: false),
                                  ),
                                );
                              },
                              childCount: viewModel.services.length,
                            ),
                          ),
                        ),
                      // Footer (Loading more / End of list)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              if (viewModel.isLoadingMore)
                                _buildLoadingCard(),
                              if (!viewModel.hasMoreData)
                                _buildEndOfListIndicator(viewModel),
                              const SizedBox(height: 80), // extra padding for cart bottom bar
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildServiceCard(BuildContext context, HomePage.Service service,
    {required bool isWide}) {
  final hasDiscount =
      service.discountType != null && service.oldPrice != null;

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    padding: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: const Color(0xffF5F5F5),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// IMAGE (same SearchServiceCard style)
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: (service.image != null && service.image!.isNotEmpty)
                  ? Image.network(
                      service.image!,
                      height: 95,
                      width: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 95,
                          width: 95,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 95,
                      width: 95,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
            ),

            /// DISCOUNT BADGE
            if (hasDiscount)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${((service.oldPrice! - service.price!) / service.oldPrice! * 100).toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 12),

        /// DETAILS (SearchServiceCard style)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                service.name ?? 'No Title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              /// DESCRIPTION
              if (service.shortDescription != null &&
                  service.shortDescription!.isNotEmpty)
                Text(
                  service.shortDescription!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),

              const SizedBox(height: 6),

              /// DURATION + GENDER
              Row(
                children: [
                  if (service.duration != null) ...[
                    Icon(Icons.access_time_rounded,
                        size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${service.duration}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],

                  if (service.gender != null) ...[
                    const SizedBox(width: 10),
                    Icon(
                      service.gender!.toLowerCase() == 'male'
                          ? Icons.male
                          : Icons.female,
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.gender!
                          .substring(0, 1)
                          .toUpperCase() +
                          service.gender!.substring(1).toLowerCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              /// PRICE
              Row(
                children: [
                  Text(
                    "PKR ${service.price ?? 0}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 8),
                    Text(
                      "PKR ${service.oldPrice}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        /// ARROW BUTTON
        Container(
          height: 42,
          width: 42,
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLoadingShimmer() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 500;
    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        },
      );
    }
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
        height: 100,
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
