// TODO: FAVOURITES SCREEN - Display list of user's favourite salons
// Integrated with POST /salons/favourite API
// Features: Pull-to-refresh, pagination, empty state, loading states

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:app/api_services/favourite_api.dart';
import 'package:app/models/FavouritesListResponse.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  static String routeName = "/favourites";

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final FavouriteAPI _favouriteAPI = FavouriteAPI();

  List<FavouriteSalon> favouriteSalons = [];
  bool isLoading = true;
  bool isRefreshing = false;
  bool hasError = false;
  String errorMessage = '';

  // Pagination
  int currentPage = 1;
  int lastPage = 1;
  int totalFavourites = 0;
  bool hasMorePages = false;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  /// Load favourites from API
  Future<void> _loadFavourites({bool refresh = false}) async {
    if (refresh) {
      if (!mounted) return;
      setState(() {
        isRefreshing = true;
        currentPage = 1;
        hasError = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    try {
      log('Loading favourites - Page: $currentPage');

      final result = await _favouriteAPI.getFavouritesList(page: currentPage);

      // Print complete raw data
      print("\n════════════════════════════════════════════════════════");
      print("📋 FAVOURITES API - COMPLETE RAW DATA");
      print("════════════════════════════════════════════════════════");
      print("🔹 Success: ${result['success']}");
      print("🔹 Message: ${result['message']}");
      print("\n📦 FULL API RESPONSE:");
      print(result['data']);
      print("════════════════════════════════════════════════════════\n");

      if (result['success'] == true) {
        final response = FavouritesListResponse.fromJson(result['data']);
        final paginatedData = response.response.data;

        // Print parsed data details
        print("\n════════════════════════════════════════════════════════");
        print("📊 FAVOURITES API - PARSED DATA");
        print("════════════════════════════════════════════════════════");
        print("📄 Status Code: ${response.statusCode}");
        print("📄 Message: ${response.message}");
        print("📄 Status: ${response.status}");
        print("\n📑 PAGINATION INFO:");
        print("   Current Page: ${paginatedData.currentPage}");
        print("   Last Page: ${paginatedData.lastPage}");
        print("   Per Page: ${paginatedData.perPage}");
        print("   Total Items: ${paginatedData.total}");
        print("   From: ${paginatedData.from}");
        print("   To: ${paginatedData.to}");
        print("   Next Page URL: ${paginatedData.nextPageUrl}");
        print("   Previous Page URL: ${paginatedData.prevPageUrl}");
        print("\n💝 FAVOURITE SALONS (${paginatedData.data.length}):");
        for (int i = 0; i < paginatedData.data.length; i++) {
          final salon = paginatedData.data[i];
          print("\n   [$i] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          print("   🏢 ID: ${salon.id}");
          print("   📝 Name: ${salon.name}");
          print("   👤 Vendor ID: ${salon.vendorId}");
          print("   🖼️  Logo: ${salon.logo}");
          print("   📸 Image: ${salon.image}");
          print("   🌍 Country: ${salon.country}");
          print("   🏙️  State: ${salon.state}");
          print("   🏘️  City: ${salon.city}");
          print("   📍 Area: ${salon.area}");
          print("   🗺️  Address: ${salon.address}");
          print("   📌 Latitude: ${salon.latitude}");
          print("   📌 Longitude: ${salon.longitude}");
          print("   ⏱️  Min Booking: ${salon.minBookingTime} min");
          print("   ⏱️  Max Booking: ${salon.maxBookingTime} min");
          print("   ⏱️  Min Cancellation: ${salon.minCancellationTime} min");
          print("   🏷️  Type: ${salon.type}");
          print("   🎭 Kind: ${salon.kind}");
          print("   👥 Salon For: ${salon.salonFor}");
          print("   ⭐ Average Rating: ${salon.averageRating}");
          print("   💬 Review Count: ${salon.reviewCount}");
          print("   ❤️  Is Favourite: ${salon.isFavourite}");
          print("   ✅ Status: ${salon.status}");
          print("   🚫 Suspended: ${salon.suspended}");
          print("   📄 About: ${salon.about}");
          print("   📜 Policy: ${salon.salonPolicy}");
          print("   ℹ️  Additional Info: ${salon.additionalInformation}");
          print("   🔗 Facebook: ${salon.facebook}");
          print("   🔗 Instagram: ${salon.instagram}");
          print("   🔗 Twitter: ${salon.twitter}");
          print("   🔗 LinkedIn: ${salon.linkedin}");
          print("   📅 Active Days: ${salon.activeDays.length} days");
          for (var day in salon.activeDays) {
            print(
                "      - ${day.day}: ${day.openingTime} - ${day.closingTime} (Status: ${day.status})");
          }
        }
        print("════════════════════════════════════════════════════════\n");

        if (!mounted) return;
        setState(() {
          if (refresh) {
            favouriteSalons = paginatedData.data;
          } else {
            favouriteSalons.addAll(paginatedData.data);
          }

          currentPage = paginatedData.currentPage;
          lastPage = paginatedData.lastPage;
          totalFavourites = paginatedData.total;
          hasMorePages = currentPage < lastPage;

          isLoading = false;
          isRefreshing = false;
          hasError = false;
        });

        log('✅ Loaded ${paginatedData.data.length} favourites');
        log('Current page: $currentPage, Last page: $lastPage, Total: $totalFavourites');
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isRefreshing = false;
          hasError = true;
          errorMessage = result['message'] ?? 'Failed to load favourites';
        });
        log('❌ Failed to load favourites: ${result['message']}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isRefreshing = false;
        hasError = true;
        errorMessage = 'An error occurred. Please try again.';
      });
      log('❌ Exception loading favourites: $e');
    }
  }

  /// Refresh favourites list
  Future<void> _onRefresh() async {
    await _loadFavourites(refresh: true);
  }

  /// Navigate to salon detail screen
  void _navigateToSalonDetail(int salonId) {
    log('Navigating to salon detail: $salonId');
    Navigator.pushNamed(
      context,
      SalonDetailsScrollingTabsEffectB.routeName,
      arguments: salonId.toString(), // Convert int to String
    ).then((_) {
      // Refresh list when returning from detail screen
      _loadFavourites(refresh: true);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading && favouriteSalons.isEmpty) {
      return _buildLoadingState();
    }

    if (hasError && favouriteSalons.isEmpty) {
      return _buildErrorState();
    }

    if (favouriteSalons.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: kPrimaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: favouriteSalons.length + (hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == favouriteSalons.length) {
            // Load more indicator
            return _buildLoadMoreIndicator();
          }

          final salon = favouriteSalons[index];
          return _buildFavouriteSalonCard(salon);
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

  Widget _buildErrorState() {
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
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadFavourites(refresh: true),
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

  Widget _buildFavouriteSalonCard(FavouriteSalon salon) {
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
