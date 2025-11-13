import 'dart:developer';

import 'package:app/constants.dart';
import 'package:app/screens/search_final/salon_card_new.dart';
import 'package:app/screens/search_final/search_provider_new.dart';
import 'package:app/screens/search_final/services_header_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/components/deals_dashboard.dart';
import '../home/components/services_dashboard.dart';
import '../test/salon_details_scrolling_tabs_effect_b.dart';
import '../test_scroll/salon_category_and_services_list.dart';

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
        'all',
        categoryId: categoryId,
        sortBy: 'total_price',
        sortOrder: 'asc',
      );
    } else if (_tabController.index == 2 && searchProvider.salons.isEmpty) {
      // Salons tab - trigger search if empty
      log('🏪 Salons tab active - triggering search');
      searchProvider.searchSalons(
        'all',
        sortBy: 'rating',
        sortOrder: 'desc',
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
      padding: const EdgeInsets.all(60),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: kPrimaryColor,
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
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
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

  /// Build empty state for services
  Widget _buildServicesEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Services Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
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
            Icon(
              Icons.local_offer_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Deals Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Check back later for amazing offers',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
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
            Icon(
              Icons.store_mall_directory_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Salons Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try searching in a different area',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
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
                color: kScreenBg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Services Tab
                    CustomScrollView(
                      controller: _servicesScrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 4),
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
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 6,
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
                          padding: const EdgeInsets.only(top: 4),
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
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 6,
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
                          padding: const EdgeInsets.only(top: 4),
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
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 6,
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
