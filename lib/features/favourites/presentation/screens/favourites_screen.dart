// TODO: FAVOURITES SCREEN - Display list of user's favourite salons
// Migrated to MVVM architecture
// Features: Pull-to-refresh, pagination, empty state, loading states

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/presentation/viewmodels/favourites/favourites_view_model.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';
import '../../../../screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/models/FavouritesListResponse.dart';
import 'package:shimmer/shimmer.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  static String routeName = "/favourites";

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive =>
      false; // Don't keep alive - this causes screen to rebuild on tab switch

  @override
  void initState() {
    super.initState();
    _loadFavouritesIfAuthenticated();
  }

  void _loadFavouritesIfAuthenticated() {
    // Load favourites on init - but only if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is authenticated before loading
      final authProvider = context.read<AuthProvider>();

      if (!authProvider.isAuthenticated) {
        return;
      }

      try {
        // Always refresh to get latest data when tab is opened
        context.read<FavouritesViewModel>().loadFavourites(refresh: true);
      } catch (e) {
        // swallow; view model handles error state
      }
    });
  }

  /// Navigate to salon detail screen
  void _navigateToSalonDetail(int salonId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalonDetailsScrollingTabsEffectB(),
        settings: RouteSettings(arguments: salonId.toString()),
      ),
    ).then((_) {
      // Refresh list when returning from detail screen
      try {
        context.read<FavouritesViewModel>().refresh();
      } catch (e) {
        // refresh error handled by view model
      }
    }).catchError((error) {
      // ignore navigation error
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
        actions: [
          Consumer<FavouritesViewModel>(
            builder: (context, viewModel, child) {
              // Show refresh indicator when loading but has data (refetching)
              if (viewModel.isLoading && viewModel.favouriteSalons.isNotEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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

    // Show empty state instead of error if no favourites
    // This handles cases where the error is due to empty data or type mismatches
    if (viewModel.favouriteSalons.isEmpty) {
      // Check if it's an auth error
      final errorMessage = viewModel.errorMessage ?? '';
      final isAuthError = errorMessage.contains('login') ||
          errorMessage.contains('Unauthorized');

      if (viewModel.isError && isAuthError) {
        // Only show error state for auth errors
        return _buildErrorState(viewModel);
      }

      // For all other cases (including type errors, empty data, or no error), show empty state
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(FavouritesViewModel viewModel) {
    final errorMessage =
        viewModel.errorMessage ?? 'Unable to load your favourites right now';
    final isAuthError =
        errorMessage.contains('login') || errorMessage.contains('Unauthorized');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isAuthError
                    ? kPrimaryColor.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuthError ? Icons.lock_outline : Icons.cloud_off_outlined,
                size: 64,
                color: isAuthError ? kPrimaryColor : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuthError
                  ? 'Authentication Required'
                  : 'Oops! Something went wrong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                if (isAuthError) {
                  // Navigate to login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                } else {
                  // Try again
                  viewModel.refresh();
                }
              },
              icon: Icon(isAuthError ? Icons.login : Icons.refresh,
                  color: Colors.white),
              label: Text(
                isAuthError ? 'Login' : 'Try Again',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 80,
                color: kPrimaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favourites Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t added any salons to your favourites.\nExplore amazing salons and save your favorites here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Switch to home tab (index 0)
                // Find InitScreen state in the widget tree
                State? initScreenState;
                context.visitAncestorElements((ancestor) {
                  if (ancestor is StatefulElement) {
                    final state = ancestor.state;
                    // Check if this is the InitScreen state
                    if (state.runtimeType.toString() == '_InitScreenState') {
                      initScreenState = state;
                      return false; // Stop searching
                    }
                  }
                  return true; // Continue visiting ancestors
                });

                // Call updateCurrentIndex if found
                if (initScreenState != null) {
                  (initScreenState as dynamic).updateCurrentIndex(0);
                }
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
