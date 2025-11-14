// TODO: FAVOURITES SCREEN - Display list of user's favourite salons
// Migrated to MVVM architecture
// Features: Pull-to-refresh, pagination, empty state, loading states

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/presentation/viewmodels/favourites/favourites_view_model.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/models/FavouritesListResponse.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  static String routeName = "/favourites";

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favourites on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouritesViewModel>().loadFavourites();
    });
  }

  /// Navigate to salon detail screen
  void _navigateToSalonDetail(int salonId) {
    log('Navigating to salon detail: $salonId');
    Navigator.pushNamed(
      context,
      SalonDetailsScrollingTabsEffectB.routeName,
      arguments: salonId.toString(),
    ).then((_) {
      // Refresh list when returning from detail screen
      context.read<FavouritesViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favourites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Consumer<FavouritesViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(viewModel);
        },
      ),
    );
  }

  Widget _buildBody(FavouritesViewModel viewModel) {
    if (viewModel.isLoading && viewModel.favouriteSalons.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.isError && viewModel.favouriteSalons.isEmpty) {
      return _buildErrorState(viewModel);
    }

    if (viewModel.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      color: kPrimaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount:
            viewModel.favouriteSalons.length + (viewModel.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == viewModel.favouriteSalons.length) {
            // Load more
            if (!viewModel.isLoading) {
              viewModel.loadNextPage();
            }
            return _buildLoadMoreIndicator();
          }

          final salon = viewModel.favouriteSalons[index];
          return _buildFavouriteSalonCard(salon, viewModel, index);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your favourites...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(FavouritesViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Favourites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding salons to your favourites\nby tapping the heart icon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to home screen (first tab)
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Explore Salons',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
        ),
      ),
    );
  }

  Widget _buildFavouriteSalonCard(
      FavouriteSalon salon, FavouritesViewModel viewModel, int index) {
    // Build image URL

    final String imageUrl = salon.image.startsWith('http')
        ? salon.image
        : '$BASE_URL_IMAGE${salon.image}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => _navigateToSalonDetail(salon.id),
        child: SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadius),
            child: Container(
              color: kCardBG,
              child: Column(
                children: [
                  // Image on top
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 175,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    kPrimaryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.store,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      // Heart icon overlay
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content below image
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Salon name
                        Text(
                          salon.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        // Address with location icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                salon.address,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Rating and reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Star rating
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < salon.averageRating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  salon.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            // Review count
                            Row(
                              children: [
                                const Icon(
                                  Icons.reviews,
                                  color: kPrice,
                                  size: 18,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${salon.reviewCount}',
                                  style: const TextStyle(
                                    color: kPrice,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
