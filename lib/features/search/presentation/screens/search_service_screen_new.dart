import 'dart:developer';

import 'package:app/constants.dart';
import '../widgets/salon_card_new.dart';
import '../providers/search_provider_new.dart';
import '../widgets/services_header_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/features/home/presentation/widgets/deals_dashboard.dart';
import 'package:app/features/home/presentation/widgets/services_dashboard.dart';
import '../../../../screens/test/salon_details_scrolling_tabs_effect_b.dart';
import '../../../../screens/test_scroll/salon_category_and_services_list.dart';

// TODO: [FEATURE] Add advanced search filters (price range, rating, distance)
// TODO: [FEATURE] Implement voice search functionality
// TODO: [FEATURE] Add search history and suggestions
// TODO: [FEATURE] Add "Near Me" location-based search
// TODO: [FEATURE] Implement saved searches functionality
// TODO: [ENHANCEMENT] Add search result sorting (relevance, price, rating, distance)
// TODO: [ENHANCEMENT] Show "Did you mean..." suggestions for typos
// TODO: [UX] Add pull-to-refresh on all tabs
// TODO: [UX] Implement infinite scroll pagination for all tabs
// TODO: [OPTIMIZATION] Cache search results for faster loading
// TODO: [ANALYTICS] Track popular search terms

class SearchServiceScreenNew extends StatefulWidget {
  const SearchServiceScreenNew({super.key});

  static String routeName = "/search_services";

  @override
  _SearchServiceScreenState createState() => _SearchServiceScreenState();
}

class _SearchServiceScreenState extends State<SearchServiceScreenNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _servicesScrollController = ScrollController();
  final ScrollController _salonsScrollController = ScrollController();
  final ScrollController _dealsScrollController = ScrollController();

  int? categoryId;
  String? categoryName;
  bool? isFromBottomNav;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access ModalRoute and Provider here
    try {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      categoryId = args?['categoryId'] as int?;
      categoryName = args?['categoryName'] as String?;
      isFromBottomNav = args?['isFromBottomNav'] as bool?;
      print("isFromBottomNav: $isFromBottomNav");
    } catch (e) {
      print("Error accessing ModalRoute: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        log('📌 Tab switched to index: ${_tabController.index}');
        _triggerTabSearch();
        setState(() {});
      }
    });

    final searchProvider =
        Provider.of<SearchProviderNew>(context, listen: false);

    // Infinite scroll listeners
    _servicesScrollController.addListener(() {
      if (_servicesScrollController.position.extentAfter < 50) {
        searchProvider.loadMore();
      }
    });
    _salonsScrollController.addListener(() {
      if (_salonsScrollController.position.extentAfter < 50) {
        searchProvider.loadMore();
      }
    });
    _dealsScrollController.addListener(() {
      if (_dealsScrollController.position.extentAfter < 50) {
        searchProvider.loadMore();
      }
    });
  }

  /// Trigger search based on current tab
  void _triggerTabSearch() {
    final searchProvider =
        Provider.of<SearchProviderNew>(context, listen: false);

    if (_tabController.index == 0 && searchProvider.services.isEmpty) {
      // Services tab - already loaded by ServicesHeaderNew
      log('🔵 Services tab active - data should be loaded by header');
    } else if (_tabController.index == 1 && searchProvider.deals.isEmpty) {
      // Deals tab - trigger search if empty
      log('🏷️ Deals tab active - triggering search');
      searchProvider.searchDeals(
        '',
        categoryId: categoryId,
        sortBy: 'price_low',
      );
    } else if (_tabController.index == 2 && searchProvider.salons.isEmpty) {
      // Salons tab - trigger search if empty
      log('🏪 Salons tab active - triggering search');
      searchProvider.searchSalons(
        '',
        sortBy: 'rating',
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _servicesScrollController.dispose();
    _salonsScrollController.dispose();
    _dealsScrollController.dispose();
    super.dispose();
  }

  /// Build a loading widget
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.2),
                        kPrimaryColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: kPrimaryColor,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Searching...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finding the best results for you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an error widget
  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state for services
  Widget _buildServicesEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor.withOpacity(0.1),
                    kPrimaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No Services Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Try adjusting your search or filters to find what you\'re looking for',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state for deals
  Widget _buildDealsEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.15),
                    Colors.orange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.local_offer_rounded,
                size: 64,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No Deals Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Check back later for amazing offers and exclusive deals',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state for salons
  Widget _buildSalonsEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor.withOpacity(0.1),
                    kPrimaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 64,
                color: kPrimaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No Salons Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Try searching in a different area or adjust your filters',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProviderNew>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (non-scrollable)
            ServicesHeaderNew(
              tabController: _tabController,
              backButtonNav: isFromBottomNav,
              categoryId: categoryId,
              categoryName: categoryName,
            ),
            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
            // Body (scrollable tabs)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kScreenBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Services Tab
                    CustomScrollView(
                      controller: _servicesScrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          sliver: searchProvider.isLoading &&
                                  searchProvider.services.isEmpty
                              ? SliverToBoxAdapter(child: _buildLoadingState())
                              : searchProvider.error != null
                                  ? SliverToBoxAdapter(
                                      child: _buildErrorState(
                                          searchProvider.error!))
                                  : searchProvider.services.isEmpty
                                      ? SliverToBoxAdapter(
                                          child: _buildServicesEmptyState())
                                      : SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              final service = searchProvider
                                                  .services[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: ServicesCard(
                                                  title: service.name ?? "",
                                                  image: "",
                                                  salon: service.salon!,
                                                  service: service,
                                                  desc:
                                                      service.description ?? "",
                                                  press: () {
                                                    log('🔵 Service tapped: ${service.name}');
                                                    log('   Salon ID: ${service.salon?.id}');
                                                    log('   Salon: ${service.salon?.name}');
                                                    Navigator.pushNamed(
                                                      context,
                                                      SalonCategoryAndServicesList
                                                          .routeName,
                                                      arguments: service,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            childCount:
                                                searchProvider.services.length,
                                          ),
                                        ),
                        ),
                      ],
                    ),
                    // Deals Tab
                    CustomScrollView(
                      controller: _dealsScrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          sliver: searchProvider.isLoading &&
                                  searchProvider.deals.isEmpty
                              ? SliverToBoxAdapter(child: _buildLoadingState())
                              : searchProvider.error != null
                                  ? SliverToBoxAdapter(
                                      child: _buildErrorState(
                                          searchProvider.error!))
                                  : searchProvider.deals.isEmpty
                                      ? SliverToBoxAdapter(
                                          child: _buildDealsEmptyState())
                                      : SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              final deal =
                                                  searchProvider.deals[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4,
                                                ),
                                                child: DealsCard(
                                                  title: deal.name ?? "",
                                                  price: deal.totalPrice ?? 0,
                                                  deal: deal,
                                                  services: deal.services !=
                                                          null
                                                      ? deal.services!
                                                          .map((s) => s.name)
                                                          .join(' • ')
                                                      : '',
                                                  discountValue:
                                                      deal.discountValue ?? 0,
                                                  discountType:
                                                      deal.discountType ?? "",
                                                  salon: deal.salon!,
                                                  image: deal.image ?? "",
                                                  press: () {
                                                    log('🏷️ Deal tapped: ${deal.name}');
                                                    log('   Total Price: ${deal.totalPrice}');
                                                    log('   Salon: ${deal.salon?.name}');
                                                    Navigator.pushNamed(
                                                      context,
                                                      SalonCategoryAndServicesList
                                                          .routeName,
                                                      arguments: deal,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            childCount:
                                                searchProvider.deals.length,
                                          ),
                                        ),
                        ),
                      ],
                    ),
                    // Salons Tab
                    CustomScrollView(
                      controller: _salonsScrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          sliver: searchProvider.isLoading &&
                                  searchProvider.salons.isEmpty
                              ? SliverToBoxAdapter(child: _buildLoadingState())
                              : searchProvider.error != null
                                  ? SliverToBoxAdapter(
                                      child: _buildErrorState(
                                          searchProvider.error!))
                                  : searchProvider.salons.isEmpty
                                      ? SliverToBoxAdapter(
                                          child: _buildSalonsEmptyState())
                                      : SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              final salon =
                                                  searchProvider.salons[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: SalonCard(
                                                  name: salon.name ?? "",
                                                  image: salon.image ?? '',
                                                  address: salon.address ?? "",
                                                  about: salon.about ?? "",
                                                  average_rating:
                                                      0, // TODO: Enable when API provides rating
                                                  review_count:
                                                      salon.reviewCount ?? 0,
                                                  is_favourite:
                                                      salon.isFavourite ??
                                                          false,
                                                  press: () {
                                                    log('🏪 Salon tapped: ${salon.name}');
                                                    log('   Address: ${salon.address}');
                                                    log('   Reviews: ${salon.reviewCount}');
                                                    Navigator.pushNamed(
                                                      context,
                                                      SalonDetailsScrollingTabsEffectB
                                                          .routeName,
                                                      arguments: '${salon.id}',
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            childCount:
                                                searchProvider.salons.length,
                                          ),
                                        ),
                        ),
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
}
