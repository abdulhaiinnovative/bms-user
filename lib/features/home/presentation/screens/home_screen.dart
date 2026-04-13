import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import '../viewmodels/home_view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/home_header.dart';
import '../widgets/categories_dashboard.dart';
import '../widgets/salon_dashboard.dart';
import '../widgets/deals_dashboard.dart';
import '../widgets/services_dashboard.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app/components/cart_bottom_bar.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isActiveTab;

  const HomeScreen({super.key, this.isActiveTab = true});
  static String routeName = "/home";

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _proceedToBooking() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add services or deals to cart first'),
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
        // Home context doesn't have a selected salon; booking flow can still proceed.
        'salonName': cartProvider.salonName,
        'salonId': cartProvider.salonId,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Load data using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  // Shimmer loading widget
  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Shimmer for CategoriesDashboard
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Simulate 5 category items
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 160,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 50,
                            height: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Shimmer for SalonDashboard
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3, // Simulate 3 salon items
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 320,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
        // Shimmer for ServicesDashboard
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3, // Simulate 3 service items
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 320,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Container(
            color: kScreenBg,
            child: Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      surfaceTintColor: Colors.white,
                      pinned: false,
                      floating: true,
                      snap: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: HomeHeader(),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          viewModel.isLoading || !viewModel.hasData
                              ? _buildShimmer()
                              : Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    CategoriesDashboard(
                                        type2: viewModel.categories!),
                                    const SizedBox(height: 8),
                                    SalonDashboard(type3: viewModel.salons!),
                                    // Only show deals section if not empty
                                    if (viewModel.deals != null &&
                                        viewModel.deals!.isNotEmpty &&
                                        viewModel.deals!.any((section) =>
                                            section.data.isNotEmpty)) ...[
                                      const SizedBox(height: 8),
                                      DealsDashboard(type4: viewModel.deals!),
                                    ],
                                    // Only show services section if not empty (men/women sections)
                                    if (viewModel.services != null &&
                                        viewModel.services!.isNotEmpty &&
                                        viewModel.services!.any((section) =>
                                            section.data.isNotEmpty)) ...[
                                      const SizedBox(height: 8),
                                      ServicesDashboard(
                                          type4: viewModel.services!),
                                    ],
                                    const SizedBox(height: 16),
                                    // Keep content visible above the cart bar when it's shown.
                                    const SizedBox(height: 84),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Show cart bottom bar only when not on home tab
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              // Don't show if cart is empty or if on home tab
              if (cart.itemCount == 0 || !widget.isActiveTab) {
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
    ));
  }
}
