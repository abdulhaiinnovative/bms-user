import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import '../../../../screens/test/salon_details_scrolling_tabs_effect_b.dart';
import '../viewmodels/top_salons_view_model.dart';
import '../widgets/salon_dashboard.dart' show FavoriteHeartWidget;
import '../../../../api_services/salon_detail_api.dart';
import '../../../../features/auth/utils/auth_manager.dart';
import 'package:shimmer/shimmer.dart';

class TopSalonsScreen extends StatefulWidget {
  static const String routeName = '/top-salons';

  const TopSalonsScreen({Key? key}) : super(key: key);

  @override
  State<TopSalonsScreen> createState() => _TopSalonsScreenState();
}

class _TopSalonsScreenState extends State<TopSalonsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopSalonsViewModel>().loadTopSalons();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200 pixels from the bottom
      context.read<TopSalonsViewModel>().loadMoreSalons();
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
          'Top Rated Salons',
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
      body: Consumer<TopSalonsViewModel>(
        builder: (context, viewModel, child) {
          // Initial loading state
          if (viewModel.isLoading) {
            return _buildLoadingShimmer();
          }

          // Error state
          if (viewModel.errorMessage != null && viewModel.salons.isEmpty) {
            return _buildErrorState(viewModel);
          }

          // Empty state
          if (viewModel.salons.isEmpty) {
            return _buildEmptyState();
          }

          final double screenWidth = MediaQuery.of(context).size.width;
          final bool isWide = screenWidth > 500;

          // Success state with data
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshSalons(),
            color: kPrimaryColor,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (isWide)
                  SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final salon = viewModel.salons[index];
                          return _buildSalonCard(context, salon, isWide: true);
                        },
                        childCount: viewModel.salons.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final salon = viewModel.salons[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildSalonCard(context, salon, isWide: false),
                          );
                        },
                        childCount: viewModel.salons.length,
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
                          _buildLoadingMoreIndicator(),
                        if (!viewModel.hasMoreData)
                          _buildEndOfListIndicator(viewModel),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalonCard(BuildContext context, salon, {required bool isWide}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SalonDetailsScrollingTabsEffectB(),
          settings: RouteSettings(arguments: '${salon.id}'),
        ),
      );
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.only(right: 10, left: 0),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// IMAGE SECTION (SearchSalonCard style)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  salon.image ?? salonImage,
                  height: 95,
                  width: 95,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(

                      height: 95,
                      width: 95,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              /// RATING BADGE
              if (salon.averageRating != null && salon.averageRating! > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          salon.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// FAVORITE ICON
              if (salon.isFavourite == true)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          /// DETAILS SECTION (SearchSalonCard style)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE + LOGO
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: kPrimaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (salon.logo != null && salon.logo!.isNotEmpty)
                              ? Image.network(
                                  salon.logo!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.store,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          salon.name ?? 'Unknown Salon',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// ADDRESS
                  if (salon.address != null && salon.address!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            salon.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 4),

                  /// REVIEWS
                  Row(
                    children: [
                      const Icon(
                        Icons.rate_review_rounded,
                        color: kPrimaryColor,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${salon.reviewCount ?? 0} Reviews',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
          childAspectRatio: 0.85,
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
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            height: 250,
          ),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildEndOfListIndicator(TopSalonsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'All ${viewModel.totalSalons} salons loaded',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TopSalonsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              viewModel.errorMessage ?? 'Failed to load salons',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshSalons(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            Icon(
              Icons.store_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No Salons Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'There are no top-rated salons available at the moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSalonFavButton extends StatefulWidget {
  final String salonId;
  final bool initialIsFavourite;

  const _TopSalonFavButton({
    Key? key,
    required this.salonId,
    required this.initialIsFavourite,
  }) : super(key: key);

  @override
  State<_TopSalonFavButton> createState() => _TopSalonFavButtonState();
}

class _TopSalonFavButtonState extends State<_TopSalonFavButton> {
  late bool isFavourite;
  bool isToggling = false;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.initialIsFavourite;
  }

  @override
  void didUpdateWidget(covariant _TopSalonFavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsFavourite != oldWidget.initialIsFavourite) {
      isFavourite = widget.initialIsFavourite;
    }
  }

  Future<void> _toggleFavourite() async {
    if (isToggling) return;
    final previousStatus = isFavourite;
    setState(() => isToggling = true);
    try {
      final token = await AuthManager.getToken();
      final salonApi = SalonDetailAPI();
      final newStatus = await salonApi.toggleFavorite(
          int.parse(widget.salonId), token);

      if (newStatus != null) {
        setState(() {
          isFavourite = newStatus;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newStatus ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  newStatus ? 'Added to favorites' : 'Removed from favorites',
                ),
              ],
            ),
            backgroundColor: newStatus ? Colors.green : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isFavourite = previousStatus;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to update favorite status'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      setState(() {
        isFavourite = previousStatus;
      });
    } finally {
      if (mounted) setState(() => isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavourite,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: isToggling
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
              )
            : Icon(
                isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavourite ? Colors.red : Colors.grey,
                size: 16,
              ),
      ),
    );
  }
}
