import 'dart:async';
import 'dart:developer';
import 'package:app/constants.dart';
import 'package:flutter/material.dart';
import 'package:app/api_services/home_screen_api.dart';
import '../../models/HomePageResponse.dart';
import 'components/categories_dashboard.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';
import 'components/popular_product.dart';
import 'components/salon_dashboard.dart';
import 'components/deals_dashboard.dart';
import 'components/services_dashboard.dart';
import 'components/special_offers.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Type1>? type1;
  List<CategorySection>? type2;
  List<TopSalonSection>? type3;
  List<DealSection>? type4;
  List<ServiceSection>? type5;
  bool _isLoading = true; // Added loading state
  String? _error; // Added error state

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log('p==000 working new ');
    log('p==001');
    loadData();
  }

  void loadData() async {
    HomeScreenAPI homeScreenAPI = HomeScreenAPI();

    try {
      // Await once and store the result
      HomePageResponse homePageResponse = await homeScreenAPI.fetchHomePageData();

      // Now update state with the fetched data
      setState(() {
        log('p==1');
        log('${homePageResponse.runtimeType}');
        type1 = homePageResponse.response.data.type1;
        type2 = homePageResponse.response.data.type2;
        type3 = homePageResponse.response.data.type3;
        type4 = homePageResponse.response.data.type4;
        type5 = homePageResponse.response.data.type5;

        log('type1  ${type1?.length ?? 0}  ${type1?.isNotEmpty == true ? type1![0].heading : 'null'} ${type1?.isNotEmpty == true ? type1![0].data.length : 0}');
        log('type2  ${type2?.length ?? 0}  ${type2?.isNotEmpty == true ? type2![0].heading : 'null'} ${type2?.isNotEmpty == true ? type2![0].data.length : 0}');
        log('type3  ${type3?.length ?? 0}');
        log('type4  ${type4?.length ?? 0}');
        // log('type5  ${type5?.length ?? 0}');

        log('\n\n*** Data ***');

        log('type1  ${type1?.length ?? 0}  ${type1?.isNotEmpty == true ? type1![0].heading : 'null'} ${type1?.isNotEmpty == true ? type1![0].data.length : 0}');
        for (int i = 0; i < (type1?.isNotEmpty == true ? type1![0].data.length : 0); i++) {
          log('type1 url  ${type1![0].data[i].url}');
          log('type1 image  ${type1![0].data[i].image}');
        }

        log('type2  ${type2?.length ?? 0}  ${type2?.isNotEmpty == true ? type2![0].heading : 'null'} ${type2?.isNotEmpty == true ? type2![0].data.length : 0}');
        log('type2 heading  ${type2?.isNotEmpty == true ? type2![0].heading : 'null'}');
        for (int i = 0; i < (type2?.isNotEmpty == true ? type2![0].data.length : 0); i++) {
          log('type2 url  ${type2![0].data[i].name}');
        }

        log('type3  ${type3?.length ?? 0}  ${type3?.isNotEmpty == true ? type3![0].heading : 'null'} ${type3?.isNotEmpty == true ? type3![0].data.length : 0}');
        log('type3 heading  ${type3?.isNotEmpty == true ? type3![0].heading : 'null'}');
        for (int i = 0; i < (type3?.isNotEmpty == true ? type3![0].data.length : 0); i++) {
          log('type3 url  ${type3![0].data[i].name}');
        }

        log('p==2');

        // You can now store the response in a variable or state if needed
        // For example:
        // this.homePageData = homePageResponse;
        _isLoading = false; // Data loaded
      });
    } catch (error) {
      //log('Error while loading home page data: $error');
      setState(() {
        _isLoading = false;
        _error = 'Failed to load data: $error';
      });
    }
  }

  static const List<Map<String, String>> items = [
    {'image': 'https://marketplace.canva.com/EAE6uxzge6c/1/0/1600w/canva-yellow-and-white-minimalist-big-sale-banner-BjBIq-T_6j4.jpg', 'route': '/screen1'},
    {'image': 'https://i.pinimg.com/564x/6d/11/3f/6d113f1ab4d679ac3f35f944d93e5b4b.jpg', 'route': '/screen2'},
    {'image': 'https://i.pinimg.com/564x/c9/c3/f4/c9c3f410aa70473bedeea18f66a7eb8c.jpg', 'route': '/screen3'},
  ];

  //const HomeScreen({super.key});

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

                SizedBox(height: 20,)

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
        child: Container(
          color: kScreenBg, // Set the background color for the entire screen
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                surfaceTintColor: Colors.white,
                pinned: false,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: HomeHeader(),
                ),
                //expandedHeight: 100,
                backgroundColor: Colors.white, // Set background to transparent
                elevation: 0, // Remove shadow
                automaticallyImplyLeading: false, // Hide the back button
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    //CarouselSliderWidget(items: items),
                    _isLoading || type2 == null || type3 == null || type4 == null
                        ? _buildShimmer()
                        : Column(
                      children: [
                        SizedBox(height: 10),
                        CategoriesDashboard(type2: type2!),
                        SizedBox(height: 10),
                        SalonDashboard(type3: type3!),
                        DealsDashboard(type4: type4!),
                        ServicesDashboard(type4: type5!),
                        SizedBox(height: 10),
                        //DiscountBanner(),
                        // SizedBox(height: 20),
                        // SpecialOffers(),
                        //Categories(),
                        // SectionHeader(title: N", onSeeAllPressed: () {
                        //   log('See All button pressed');
                        // },),
                        // PopularProducts(),
                        //SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}