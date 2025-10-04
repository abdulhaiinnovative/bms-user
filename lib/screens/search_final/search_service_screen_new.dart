import 'dart:developer';

import 'package:app/constants.dart';
import 'package:app/screens/search_final/deal_card_new.dart';
import 'package:app/screens/search_final/salon_card_new.dart';
import 'package:app/screens/search_final/search_provider_new.dart';
// import 'package:app/screens/search_final/services_card_new.dart';
import 'package:app/screens/search_final/services_header_new.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class _SearchServiceScreenState extends State<SearchServiceScreenNew> with SingleTickerProviderStateMixin {
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
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
    final searchProvider = Provider.of<SearchProviderNew>(context, listen: false);


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

  @override
  void dispose() {
    _tabController.dispose();
    _servicesScrollController.dispose();
    _salonsScrollController.dispose();
    _dealsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProviderNew>(context);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                surfaceTintColor: Colors.white,
                pinned: true,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ServicesHeaderNew(tabController: _tabController, backButtonNav: isFromBottomNav, categoryId: categoryId, categoryName: categoryName),
                ),
                expandedHeight: 180,
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
            ];
          },
          body: Container(
            color: kScreenBg,
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: TabBarView(

              controller: _tabController,
              children: [
                CustomScrollView(
                  controller: _servicesScrollController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          if (searchProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (searchProvider.error != null) {
                            return Center(child: Text("Error: ${searchProvider.error}"));
                          }
                          if (searchProvider.services.isEmpty) {
                            return const Center(child: Text("No services found"));
                          }
                          return Container(
                            padding: const EdgeInsets.fromLTRB(2, 2, 1, 1),
                            child:

                            ServicesCard(
                              title: searchProvider?.services?[index].name ?? "",
                              image: "",
                              salon: searchProvider.services[index].salon !,
                              service: searchProvider.services[index],

                              // price: searchProvider?.services?[index].price ?? 0,
                              // discountAmount: searchProvider?.services?[index]?.discountAmount ?? 0,
                              // discountType: searchProvider?.services?[index]?.discountType ?? "",
                              // oldPrice: searchProvider?.services?[index]?.oldPrice ?? 0 ,
                              // gender: searchProvider.services[index].gender ?? "",
                              // duration: searchProvider.services[index].duration ?? "",
                              // salon: null, //searchProvider.services[index].salon,
                              desc: searchProvider.services[index].description  ?? "",
                              press: () {

                                Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: searchProvider.services[index]);
                                log('Tapped Deal: ${searchProvider.services[index].name}');
                                log('Tapped Deal:salon id   ${searchProvider.services[index].salon?.id}');
                                log('Tapped Deal:name   ${searchProvider.services[index].salon?.name}');
                                log('Tapped Deal:image   ${searchProvider.services[index].salon?.image}');
                                log('Tapped Deal:address   ${searchProvider.services[index].salon?.address}');

                              },
                            ),

                          );
                        },
                        childCount: searchProvider.isLoading || searchProvider.error != null ? 1 : searchProvider.services.length,
                      ),
                    ),
                  ],
                ),
                CustomScrollView(
                  controller: _dealsScrollController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          if (searchProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (searchProvider.error != null) {
                            return Center(child: Text("Error: ${searchProvider.error}"));
                          }
                          if (searchProvider.deals.isEmpty) {
                            return const Center(child: Text("No deals found"));
                          }
                          return Container(
                            padding: const EdgeInsets.fromLTRB(2, 2, 1, 1),
                            child:

                            DealsCard(
                              title: searchProvider.deals[index].name ?? "",
                              price: searchProvider.deals[index].totalPrice ?? 0,

                              /// required this.title,
                              /// required this.image,
                              // required this.services,
                              /// required this.salon,
                              /// required this.price,
                              /// required this.discountValue,
                              /// required this.discountType,
                              /// required this.press,


                              services: searchProvider.deals[index].services != null
                                  ? searchProvider.deals[index].services!.map((s) => s.name).join(' • ')
                                  : '',
                              //services: searchProvider.deals[index].price  ?? 0,
                              discountValue: searchProvider.deals[index].discountValue ?? 0 ,
                              discountType: searchProvider.deals[index].discountType ?? "",
                              //oldPrice: searchProvider.deals[index].price  ?? 0,
                              //duration: searchProvider.deals[index].services!.isNotEmpty? searchProvider.deals[index].services!.map((s) => s.duration).join(', '): '',
                              salon: searchProvider.deals[index].salon!,
                              //desc: searchProvider.deals[index].services!.isNotEmpty ? searchProvider.deals[index].services!.map((s) => s.description).join(', ') : '',
                              //validUntil: searchProvider.deals[index].endDate,
                              image: searchProvider.deals[index].image ?? "",
                              press: () {

                                Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: searchProvider.deals[index]);
                                log('Tapped Deal: ${searchProvider.deals[index].name}');
                                log('Tapped Deal:salon id   ${searchProvider.deals[index].salon?.id}');
                                log('Tapped Deal:name   ${searchProvider.deals[index].salon?.name}');
                                log('Tapped Deal:image   ${searchProvider.deals[index].salon?.image}');
                                log('Tapped Deal:address   ${searchProvider.deals[index].salon?.address}');

                              },
                            ),
                          );
                        },
                        childCount: searchProvider.isLoading || searchProvider.error != null ? 1 : searchProvider.deals.length,
                      ),
                    ),
                  ],
                ),
                CustomScrollView(
                  controller: _salonsScrollController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          if (searchProvider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (searchProvider.error != null) {
                            return Center(child: Text("Error: ${searchProvider.error}"));
                          }
                          if (searchProvider.salons.isEmpty) {
                            return const Center(child: Text("No salons found"));
                          }
                          return

                            Container(
                            padding: const EdgeInsets.fromLTRB(2, 2, 1, 1),
                            child: SalonCard(
                              name: searchProvider.salons[index].name ?? "",
                              image: searchProvider.salons[index].image ?? 'assets/images/default_logo.png',
                              address: searchProvider.salons[index].address ?? "",
                              about: searchProvider.salons[index].about ?? "",
                              average_rating: 0,//searchProvider.salons[index].averageRating ?? 0,
                              review_count: searchProvider.salons[index].reviewCount ?? 0,
                              is_favourite: searchProvider.salons[index].isFavourite ?? true,
                              press: () {
                                print('SalonCard');
                                Navigator.pushNamed(context, SalonDetailsScrollingTabsEffectB.routeName, arguments: '${searchProvider.salons[index].id}',);


                              },
                            ),
                          );
                        },
                        childCount: searchProvider.isLoading || searchProvider.error != null ? 1 : searchProvider.salons.length,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}