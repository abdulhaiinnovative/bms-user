import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/models/SalonDetailApiResponse.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../api_services/salon_detail_api.dart';
import '../../components/ratings.dart';
import '../../constants.dart';
import '../../helper/CircularNetworkImage.dart';
import '../../helper/ReviewCount.dart';
import '../../models/HomePageResponse.dart';
import '../home/components/deals_dashboard.dart';
import '../home/components/services_dashboard.dart';
import '../test_scroll/salon_category_and_services_list.dart';
import 'data_source.dart';
import 'package:shimmer/shimmer.dart';

class SalonDetailsScrollingTabsEffectB extends StatefulWidget {
  const SalonDetailsScrollingTabsEffectB({super.key});
  static String routeName = "/scrolling_tabs_effect_b";

  @override
  _SalonDetailsScrollingTabsEffectB createState() =>
      _SalonDetailsScrollingTabsEffectB();
}

class _SalonDetailsScrollingTabsEffectB
    extends State<SalonDetailsScrollingTabsEffectB>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final AutoScrollController _autoScrollController = AutoScrollController();
  late TabController _tabController ;

  static String logs = "SalonDetail111   ";
  //late SalonDetailServiceWithGroupModel serviceItems;

  bool isExpanded = true;
  final Map<int, bool> _visibleItems = {0: true};
  ///late SalonDetailsClass salonDetails ;

  SalonData? salonDetailsss;

  Future<void> loadJson(id) async {
    try {
      SalonDetailAPI salonDetailAPI = SalonDetailAPI();
      final fetchedData = await salonDetailAPI.fetchSalonDetailData(id);

      if (mounted) {
        setState(() {
          salonDetailsss = fetchedData;

          /// Dispose previous TabController before creating a new one
          _tabController.dispose();
          _tabController = TabController(
            length: salonDetailsss?.sections?.length ?? 1,
            vsync: this,
          );

          _autoScrollController.addListener(() {
            if (mounted) {
              setState(() {
                isExpanded = !_isAppBarExpanded();
              });
            }
          });
        });
      }
    } catch (e) {
      log("Error fetching salon details: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // loadJson().then((value) {setState(() {
    //
    // });});
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   log('UI built, performing initialization tasks.');
    // });

    // Initialize _tabController with a default value
    _tabController = TabController(length: 1, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {
        log("args:::  $args");
        loadJson('${args}'); // Fetch data asynchronously
      });
    });
  }

  bool _isAppBarExpanded() {
    if (!_autoScrollController.hasClients) return false;
    return _autoScrollController.offset >
        (MediaQuery.of(context).size.height / 1.6 - kToolbarHeight);
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }

  Widget _wrapScrollTag({required int index, required Widget child}) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: _autoScrollController,
      index: index,
      child: child,
      highlightColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildSliverAppbar(BuildContext context) {
    if (salonDetailsss == null) return SliverToBoxAdapter();
    var size = MediaQuery.of(context).size;
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      snap: false,
      expandedHeight: size.height / 1.80,
      leading: !isExpanded
          ? IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: blackColor,
        ),
        onPressed: () => Navigator.of(context).pop(),
      )
          : Container(),

      title: !isExpanded
          ? Text(
        salonDetailsss?.name ?? "",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        overflow: TextOverflow.ellipsis,
      )
          : Container(),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        // title: !isExpanded ? Text("Detail View",style: TextStyle(color: blackColor),) : Container(),
        background: _buildSliverAppbarBackground(context),
      ),

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: isExpanded ? 0.0 : 1,
          child: TabBar(
            controller: _tabController,
            labelPadding: EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 5.0),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: ShapeDecoration(
              gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryDarkColor]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            labelStyle:
            TextStyle(color: blackColor, fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            //indicatorColor: Colors.white,
            //indicatorWeight: 2.5,
            isScrollable: true,
            //indicatorPadding:EdgeInsets.only(left: 30, right: 30),
            onTap: (index) async {
              _scrollToIndex(index);
            },
            // tabs: serviceItems!.data!.map((e) {
            //   return Tab(
            //     child: Text("  ${e.name}  "),
            //
            //     // text: 'Detail Business',
            //     // icon: Icon(Icons.three_k,color: whiteColor,),
            //   );
            // })!.toList(),
            //
            tabs: salonDetailsss!.sections!.map((e) {
              return Tab(
                child: Text("  ${e.name}  "),

                // text: 'Detail Business',
                // icon: Icon(Icons.three_k,color: whiteColor,),
              );
            })!.toList(),

          ),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildSliverAppbarBackground(BuildContext context) {
    var imageList = salonDetailsss?.images;
    final PageController _pageController = PageController();
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageList?.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Image.network(
                      imageList![index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      //height: MediaQuery.of(context).size.height / 4,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 10, // Positioned at the bottom
              left: 0,
              right: 0, // Stretch to full width
              child: Container(
                alignment: Alignment.center,
                // Center the content of the container
                padding: EdgeInsets.all(16.0),

                child: SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: imageList!.length,
                  effect: WormEffect(
                    dotWidth: 12.0,
                    dotHeight: 12.0,
                    spacing: 8.0,
                    dotColor: Colors.white.withOpacity(0.4),
                    activeDotColor: kPrimaryColor,
                  ), // Customizable effects
                ),
              ),
            ),
            Positioned(
              child: Container(
                decoration:
                BoxDecoration(color: whiteColor, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.favorite),
                  color: kPrimaryColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              right: 16,
              top: 32,
            ),
            Positioned(
              child: Container(
                decoration:
                BoxDecoration(color: whiteColor, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              left: 16,
              top: 32,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45, // 45% of screen width
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white, // Matches background
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12, // Shadow color
                      offset: Offset(0, -6), // Negative Y offset for top shadow
                      blurRadius: 6, // Soft shadow
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Text(
              salonDetailsss?.name ?? "",
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            )),
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Text(
                      '${salonDetailsss?.location?.address}',
                      //maxLines: 5,
                      overflow: TextOverflow.visible,
                    )),
              ],
            ),
        ),



        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Icon(
                salonDetailsss?.gender == 'female'
                    ? Icons.female
                    : salonDetailsss?.gender == 'male'
                    ? Icons.male
                    : Icons.transgender,  // For 'unisex' or any other option
                color: Colors.grey,
              ),
              SizedBox(width: 8), // Adds some space between the icon and the text
              Text(
                'For ${salonDetailsss!.gender}'  ,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),



        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Ratings(rating: salonDetailsss!.star ?? 0),
              ReviewCount(reviews: salonDetailsss!.review_count ?? 0),
            ],
          ),
        ),


        SizedBox(height: 10,),

        Divider(thickness: 1),
        ListTile(
          title: Text(
            "About Us",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.category, size: 16),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Text(
                      '${salonDetailsss!.about.toString()}',
                      //maxLines: 5,
                      overflow: TextOverflow.visible,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCategoryBody() {
    if (salonDetailsss == null) return SliverToBoxAdapter(); // Prevent crashes

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return VisibilityDetector(
            //key: Key(serviceItems.data[index].sId),
            key: Key(salonDetailsss!.sections![index].name.toString()),
            onVisibilityChanged: (info) {
              var visiblePercentage = info.visibleFraction * 100;
              if (visiblePercentage > 90) {
                setState(() {
                  _visibleItems[index] = true;
                });
              } else {
                _visibleItems.remove(index);
              }
              _calculateIndexAndJumpToTab();
            },
            child: _wrapScrollTag(
              index: index,
              child: Container(
                color: kScreenBg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCategoryTitle(context, salonDetailsss!.sections![index].name.toString()),



                    ..._buildCategoryItems(context, index),

                    // for (int i = 0; i < serviceItems.data.length; i++) ...[
                    //   _buildCategoryTitle(context, serviceItems.data[i].name),
                    //   //_buildItemList(serviceItem, "${i}"),
                    //   ..._buildCategoryItems(context, index),
                    //
                    // ],

                  ],
                ),
              ),
            ),
          );
        },
        ///childCount: serviceItems.data.length,
        childCount: salonDetailsss?.sections?.length,
      ),
    );
  }

  Widget _buildCategoryTitle(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft, // Align text to the left
        child: Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              //fontSize: 22
          ),
          textAlign: TextAlign.left, // Ensures text is left-aligned
        ),
      ),
    );
  }

  Widget _buildSalonReview(BuildContext context, Review review) {
    // Generate initials if image is empty
    String initials = '';
    if (review.user.image!.isEmpty) {
      List<String> names = review.user!.name!.split(' ');

      // If the name contains more than one part (e.g., "Muhammad Usman")
      if (names.length > 1) {
        initials = names[0].substring(0, 1).toUpperCase() +
            names[1].substring(0, 1).toUpperCase(); // First letter of first and second name
      } else {
        initials = "---=---";
        //initials = review?.user?.name?.substring(0, 2).toUpperCase(); // First two letters of the single name
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ReviewCard(review: review,),
    );

    // return Container(
    //   padding: EdgeInsets.all(16.0),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(8.0),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.grey.withOpacity(0.1),
    //         spreadRadius: 2,
    //         blurRadius: 5,
    //         offset: Offset(0, 3),
    //       ),
    //     ],
    //   ),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       // Profile Picture or Initials
    //       CircleAvatar(
    //         radius: 30.0,
    //         backgroundColor: kPrimaryDarkColor.withOpacity(0.9),
    //         backgroundImage: review.user.image!.isNotEmpty
    //             ? NetworkImage(review.user.image!)
    //             : null,
    //         child: review.user.image!.isEmpty
    //             ? Text(
    //           initials,
    //           style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 18.0,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         )
    //             : null,
    //       ),
    //       SizedBox(width: 16.0),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             // Full Name
    //             Text(
    //               review.user.name!,
    //               style: Theme.of(context).textTheme.titleLarge,
    //             ),
    //
    //             SizedBox(height: 4.0),
    //             // Date and Time
    //             Text(
    //               review.createdAt ?? "",
    //               style: Theme.of(context).textTheme.bodyMedium,
    //             ),
    //             SizedBox(height: 8.0),
    //             // Star Rating
    //
    //             Row(
    //               children: List.generate(
    //                 5,
    //                     (index) => Icon(
    //                   index < review.rating! ? Icons.star_rounded : Icons.star_border_rounded,
    //                   color: kPrimaryDarkColor,
    //                   size: 20.0,
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: 8.0),
    //             // Review Comment with max 4 lines
    //             Text(
    //               //review.review,
    //               review.comment!,
    //               style: Theme.of(context).textTheme.bodyLarge,
    //               maxLines: 4,
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  List<Widget> _buildCategoryItems(BuildContext context, int index) {
    if (salonDetailsss!.sections![index].data!.isEmpty) return [Container()];
    List<Staff> staff = [];
    List<Widget> _list = [];
    for (int i = 0; i < salonDetailsss!.sections![index].data!.length; i++) {
      if(salonDetailsss!.sections![index].type == '3'){
        // review Review
        _list.add(_buildSalonReview(context, salonDetailsss!.sections![index].data?[i]));
        //_list.add(_buildSalonServiceItem(context));

        // if((i+1) == salonDetailsss?.sections![index].data!.length){
        //   _list.add(_buildSeeAll(context, '1'));
        // }

      }else if(salonDetailsss!.sections![index].type == '6'){
        //deals Offer
        //_list.add(_buildSalonServiceItem(context));

        //_list.add(_buildDealsItem(context, salonDetailsss!.sections![index].data?[i]));
        _list.add(_buildDealsItem(context, salonDetailsss!.sections![index].data?[i]));

        // if((i+1) == salonDetailsss!.sections![index].data!.length){
        //   _list.add(_buildSeeAll(context, '1'));
        // }

      }else if(salonDetailsss!.sections![index].type == '2'){
        //deals Offer
        //_list.add(_buildSalonServiceItem(context));

        _list.add(_buildServiceItem(context, salonDetailsss!.sections![index].data?[i]));

        // if((i+1) == salonDetailsss!.sections![index].data!.length){
        //   _list.add(_buildSeeAll(context, '1'));
        // }

      }else if(salonDetailsss!.sections![index].type == '5'){
        //About
        _list.add(_buildAbout(context, salonDetailsss!.sections![index].data?[i], salonDetailsss!.about ?? ""));




      }else if(salonDetailsss!.sections![index].type == '4'){
        //staff

        staff.add(salonDetailsss!.sections![index].data?[i]);

        if((i+1) == salonDetailsss!.sections![index].data?.length) {
          _list.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: staff.map((item) =>
                    _buildSpecialistItem(context, item)).toList(),
              ),
            ),
          ));
        }

      }else {
        //services
        //_list.add(_buildSalonReview(context, salonDetails.sections[index].data[i]));
      }

      //   if(i == 1){
      //     _list.add(_buildSpecialistItem(serviceItems.data[index].services[i]));
      //   }else{
      //   }
      //
    }

    return _list;
  }

  Widget _buildDealsItem(BuildContext context, Deal deal) {

    final defaultSalon = Salon(
      name: 'Unknown Salon',
      image: logo,
      address: 'Unknown address',
      // … other required fields
    );

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: DealsCard(
        title: '${deal.name}' ?? 'No Title',
        image: deal.image ?? logo,
        salon: deal.salon ?? defaultSalon,
        services: deal.services != null
            ? deal.services!.map((s) => s.name).join(' • ')
            : '',
        price: deal.price ?? 0,
        discountValue: deal.discountValue ?? 0,
        discountType: deal.discountType ?? '-',
        press: () {
          //Navigator.pushNamed(context, ProductsScreen.routeName);
          Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: deal);
          log('Tapped Deal: ${deal.name}');
          log('Tapped Deal:salon id   ${deal.services?[0]?.salon?.id}');
          log('Tapped Deal:name   ${deal.services?[0]?.salon?.name}');
          log('Tapped Deal:image   ${deal.services?[0]?.salon?.image}');
          log('Tapped Deal:address   ${deal.services?[0]?.salon?.address}');
        },
      ),
    );


  }

  Widget _buildServiceItem(BuildContext context, Service service) {

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ServicesCard(
        service: service,
        title: '${service.name}' ?? 'No Title',
        //image: item.image ?? logo,
        image: "",
        salon: service.salon! ,
        desc: service.name ?? '',
        press: () {
          //Navigator.pushNamed(context, ProductsScreen.routeName);
          //Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: item);

          log('Tapped Deal: ${service.name}');
          // Navigator.pushNamed(context, SalonCategoryAndServicesListByService.routeName, arguments: item);
          // log('Tapped Deal: ${item.name}');
          // log('Tapped Deal:salon id   ${item?.salon?.id}');
          // log('Tapped Deal:name   ${item.salon?.name}');
          // log('Tapped Deal:image   ${item.salon?.image}');
          // log('Tapped Deal:address   ${item.salon?.address}');


          log('==================================');
          Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName, arguments: service);
          log('Tapped Deal: ${service.name}');
          log('Tapped Deal:salon id   ${service.salon?.id}');
          log('Tapped Deal:name   ${service.salon?.name}');
          log('Tapped Deal:image   ${service.salon?.image}');
          log('Tapped Deal:address   ${service.salon?.address}');
          log('----------------------------------');


        },
      ),
    );

  }

  InkWell _buildSeeAll(BuildContext context, String type) {
    return InkWell(
        onTap: () {
          // Action when tapped
          print("See All clicked ${type}");
        },
        child:
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            width: double.infinity, // Makes the button full width
            padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(10.0), // 5px rounded corners
              border: Border.all(
                color: kPrimaryDarkColor, // Blue border color
                width: 1.5, // Border width
              ),
            ),
            child: Center(
              child: Text(
                'See All',
                style: TextStyle(
                    color: kPrimaryDarkColor, // Blue border color
                    fontSize: 20.0, // Font size
                    fontWeight: FontWeight.w700
                ),
              ),
            ),
          ),
        )

    );

  }

  Widget _buildSpecialistItem(BuildContext context, Staff staff) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 200,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: kPrimaryDarkColor.withOpacity(0.1), // Background color of the box
                shape: BoxShape.rectangle, // Shape of the box
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for the box
                boxShadow: [
                  // BoxShadow(
                  //   color: Colors.grey.withOpacity(0.5), // Light grey shadow color
                  //   blurRadius: 4.0, // Blur radius of the shadow
                  //   offset: Offset(0, 4), // Position of the shadow
                  // ),
                ],

              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // Centers items vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Centers items horizontally
                children: [
                  CircularNetworkImage(
                    imageUrl: staff.image.toString(),
                    height: 120,
                    width: 120,
                    border: 3,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    staff.name.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center, // Ensure text is centered
                  ),
                  Text(
                    staff.experience.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center, // Ensure text is centered
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context, About about, String info) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity, // Makes the container full width
            //padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18, 118),
            child: Text(
              info.toString(),
              textAlign: TextAlign.left, // Center the text
              style: TextStyle(
                color: kPrimaryDarkColor, // Text color
                fontSize: 16.0, // Font size
                fontWeight: FontWeight.w500, // Font weight
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Opening Hours:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // Loop through opening timings
          ...?about.openingTimings?.map((timing) {
            // Check if the current day matches the opening timing day
            String currentDay = DateFormat('E').format(DateTime.now());
            bool isToday = currentDay == timing.day;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures left-right alignment
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle_outlined, // Plus icon
                        color: isToday ? kPrimaryColor : Colors.black.withOpacity(0.6), // Highlight icon if today
                        size: 10.0, // Icon size
                      ),
                      const SizedBox(width: 10),
                      Text(
                        timing.day.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.w400, // Highlight font weight if today
                          color: isToday ? kPrimaryColor :Colors.black.withOpacity(0.8),  // Highlight color if today
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${timing.openingTime} - ${timing.closingTime}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w400, // Highlight font weight if today
                      color: isToday ? kPrimaryColor :Colors.black.withOpacity(0.8), // Highlight color if today
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

        ],
      ),
    );
  }

  ///InkWell _buildSalonServiceItem(BuildContext context, Services service) {
  InkWell _buildSalonServiceItem(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            ///service.name+"-",
                            "service.name",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.start,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "service.subTitle",
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 4.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "Rs: service.price",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Background color of the box
                          shape: BoxShape.rectangle,
                          // Shape of the box
                          borderRadius: BorderRadius.circular(8.0),
                          // Rounded corners for the box
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              // Light grey shadow color
                              blurRadius: 4.0,
                              // Blur radius of the shadow
                              offset: Offset(0, 4), // Position of the shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite_border, // Plus icon
                            color: kPrimaryColor, // Icon color
                            size: 26.0, // Icon size
                          ),
                          onPressed: () {
                            // Add your onPressed code here for plus button
                          },
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Background color of the box
                          shape: BoxShape.rectangle,
                          // Shape of the box
                          borderRadius: BorderRadius.circular(8.0),
                          // Rounded corners for the box
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              // Light grey shadow color
                              blurRadius: 4.0,
                              // Blur radius of the shadow
                              offset: Offset(0, 4), // Position of the shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add, // Plus icon
                            color: Colors.black, // Icon color
                            size: 26.0, // Icon size
                          ),
                          onPressed: () {
                            // Add your onPressed code here for plus button
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2,
            color: Colors.transparent,
          )
        ],
      ),
      onTap: () {
        // todo do something
      },
    );
  }

  void _calculateIndexAndJumpToTab() {
    List<int> visibleIndexes = _visibleItems.keys.toList();
    visibleIndexes.sort();
    if (visibleIndexes.isNotEmpty) {
      _tabController.animateTo(visibleIndexes.first);
    }
  }

  // Shimmer loading widget
  Widget _buildShimmer() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          snap: false,
          expandedHeight: MediaQuery.of(context).size.height / 1.33,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  // Image carousel placeholder
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  // Salon name placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      width: 200,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  // Tags placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Gender placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  // Ratings placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 40,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  // Reward points tile placeholder
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      title: Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                      subtitle: Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Divider(thickness: 2),
                  // Salon info placeholder
                  ListTile(
                    title: Container(
                      width: 100,
                      height: 20,
                      color: Colors.white,
                    ),
                    trailing: Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                  // Top picks placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title placeholder
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 150,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category items placeholder (simulating services, staff, or reviews)
                    if (index == 0) // Simulate staff (horizontal scroll)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              3,
                                  (i) => Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                child: Container(
                                  width: 160,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (index == 1) // Simulate services or deals
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: List.generate(
                            2,
                                (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 200,
                                          height: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 80,
                                          height: 16,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else // Simulate reviews or about
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 80,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(
                                      5,
                                          (i) => Container(
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                        margin: const EdgeInsets.only(right: 4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // See All button placeholder
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: 3, // Simulate 3 sections (staff, services, reviews)
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: salonDetailsss == null
          ? _buildShimmer() // Show shimmer instead of CircularProgressIndicator
          : CustomScrollView(
        controller: _autoScrollController,
        slivers: <Widget>[
          _buildSliverAppbar(context),
          _buildServiceCategoryBody(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReviewCard extends StatelessWidget {
  final Review review;
  final double? width;

  const ReviewCard({
    Key? key,
    required this.review,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initials = review.user.name != null && review.user.name!.isNotEmpty
        ? review.user.name!.trim().split(" ").map((e) => e[0]).take(2).join()
        : "NA";

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: Container(
        width: width,
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer name & image
            Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user.name ?? '',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      // Text(
                      //   review.createdAt ?? '==',
                      //   style: const TextStyle(
                      //     color: Colors.black54,
                      //     fontSize: 14,
                      //   ),
                      //   overflow: TextOverflow.ellipsis,
                      //   maxLines: 1,
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Comment text
            Text(
              review.comment ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),


            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Ratings(rating: review.rating ?? 0),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

