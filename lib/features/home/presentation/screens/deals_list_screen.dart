import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import '../../../../screens/test_scroll/salon_category_and_services_list.dart';
import '../viewmodels/deals_view_model.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer';
import '../../../../models/HomePageResponse.dart';

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
      body: ChangeNotifierProvider.value(
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
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount:
                    viewModel.deals.length + (viewModel.hasMoreData ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= viewModel.deals.length) {
                    if (viewModel.isLoadingMore) {
                      return _buildLoadingCard();
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
    );
  }

  Widget _buildDealCard(BuildContext context, Deal deal) {
    final hasDiscount = deal.discountValue != null && deal.discountValue! > 0;

    return GestureDetector(
      onTap: () {
        log('📍 Navigating to deal: ${deal.name}');
        Navigator.pushNamed(
          context,
          SalonCategoryAndServicesList.routeName,
          arguments: deal,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kPrimaryColor.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    deal.image ?? logo,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: Icon(Icons.local_offer,
                            size: 40, color: Colors.grey[400]),
                      );
                    },
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          deal.discountType == 'amount'
                              ? 'PKR ${deal.discountValue} OFF'
                              : '${deal.discountValue}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Deal Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.name ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (deal.salon?.name != null)
                      Row(
                        children: [
                          Icon(Icons.store, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              deal.salon!.name!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'PKR ${deal.price ?? 0}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor,
                          ),
                        ),
                        if (deal.totalPrice != null &&
                            deal.totalPrice! > (deal.price ?? 0)) ...[
                          const SizedBox(width: 4),
                          Text(
                            'PKR ${deal.totalPrice}',
                            style: TextStyle(
                              fontSize: 10,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
