import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/models/SalonDetailApiResponse.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../api_services/salon_detail_api.dart';
import '../../api_services/favourite_api.dart';
import '../../components/ratings.dart';
import '../../constants.dart';
import '../../helper/CircularNetworkImage.dart';
import '../../helper/ReviewCount.dart';
import '../../models/HomePageResponse.dart';
import 'package:app/features/home/presentation/widgets/deals_dashboard.dart';
import 'package:app/features/home/presentation/widgets/services_dashboard.dart';
import '../test_scroll/salon_category_and_services_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app/helper/auth_dialog_helper.dart';

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
  late TabController _tabController;

  static String logs = "SalonDetail111   ";
  //late SalonDetailServiceWithGroupModel serviceItems;

  bool isExpanded = true;
  final Map<int, bool> _visibleItems = {0: true};

  ///late SalonDetailsClass salonDetails ;

  SalonData? salonDetailsss;

  // TODO: FAVOURITES STATE - Manage favourite status for salon
  // Favourite state management
  // Note: isFavourite is initialized from salonDetailsss?.isFavourite in loadJson()
  // and then maintained separately to allow immediate UI updates without refetching
  bool isFavourite = false;
  bool isTogglingFavourite = false;
  final FavouriteAPI _favouriteAPI = FavouriteAPI();

  Future<void> loadJson(id) async {
    try {
      log("=== loadJson called with id: $id ===");
      SalonDetailAPI salonDetailAPI = SalonDetailAPI();
      final fetchedData = await salonDetailAPI.fetchSalonDetailData(id);

      // Print complete salon data
      print("\n════════════════════════════════════════════════════════");
      print("📍 SALON DETAIL SCREEN - DATA LOADED");
      print("════════════════════════════════════════════════════════");
      print("🏢 SALON ID: ${fetchedData?.id}");
      print("📝 SALON NAME: ${fetchedData?.name}");
      print("📅 CREATED AT: ${fetchedData?.createdAt}");
      print("👥 GENDER: ${fetchedData?.gender}");
      print("🏷️ TYPE: ${fetchedData?.type}");
      print("🎭 KIND: ${fetchedData?.kind}");
      print("⭐ RATING: ${fetchedData?.star}");
      print("💬 REVIEW COUNT: ${fetchedData?.review_count}");
      print("❤️ IS FAVOURITE: ${fetchedData?.isFavourite}");
      print("🖼️ LOGO: ${fetchedData?.logo}");
      print("📸 IMAGES COUNT: ${fetchedData?.images.length}");
      if (fetchedData?.images.isNotEmpty ?? false) {
        print("   Images:");
        fetchedData?.images.asMap().forEach((index, img) {
          print("   [$index]: $img");
        });
      }
      print("\n📍 LOCATION:");
      print("   Address: ${fetchedData?.location?.address}");
      print("   Latitude: ${fetchedData?.location?.lat}");
      print("   Longitude: ${fetchedData?.location?.long}");
      print("\n🔗 SOCIAL MEDIA:");
      print("   Facebook: ${fetchedData?.fackebook}");
      print("   Instagram: ${fetchedData?.instagram}");
      print("   Twitter: ${fetchedData?.twitter}");
      print("   LinkedIn: ${fetchedData?.linkedin}");
      print("\n📄 ABOUT:");
      print(fetchedData?.about ?? 'N/A');
      print("\n📜 POLICY:");
      print(fetchedData?.policy ?? 'N/A');
      print("\n📑 SECTIONS (${fetchedData?.sections?.length ?? 0}):");
      if (fetchedData?.sections != null) {
        fetchedData?.sections?.asMap().forEach((index, section) {
          print("   [$index] ${section.name} (Type: ${section.type})");
          print("       Data items: ${section.data?.length ?? 0}");
          if (section.data != null &&
              section.data is List &&
              section.data!.isNotEmpty) {
            for (int i = 0; i < section.data.length; i++) {
              var item = section.data[i];
              // Handle different section types
              if (item is Service) {
                print(
                    "       - Service $i: ${item.name} (ID: ${item.id}, Price: ${item.price})");
              } else if (item is Deal) {
                print(
                    "       - Deal $i: ${item.name} (ID: ${item.id}, Total: ${item.totalPrice})");
              } else if (item is Staff) {
                print(
                    "       - Staff $i: ${item.name} (ID: ${item.id}, Email: ${item.email})");
              } else if (item is Review) {
                print(
                    "       - Review $i: ${item.comment} (Rating: ${item.rating}, User: ${item.user.name})");
              } else if (item is About) {
                print(
                    "       - About $i: Address: ${item.address}, Desc: ${item.desc?.substring(0, item.desc!.length > 50 ? 50 : item.desc!.length)}...");
              } else {
                print("       - Item $i: ${item.toString()}");
              }
            }
          }
        });
      }
      print("════════════════════════════════════════════════════════\n");

      log("Fetched salon data: ${fetchedData?.name}");
      log("Sections count: ${fetchedData?.sections?.length}");
      log("Images count: ${fetchedData?.images.length}");
      log("Is Favourite: ${fetchedData?.isFavourite}");

      if (mounted) {
        setState(() {
          salonDetailsss = fetchedData;
          // TODO: FAVOURITES INIT - Initialize favourite state from API response
          // Set initial favourite state from API response
          isFavourite = fetchedData?.isFavourite ?? false;
          log("✅ Initial favourite state set to: $isFavourite");

          if (salonDetailsss?.sections != null) {
            for (int i = 0; i < salonDetailsss!.sections!.length; i++) {
              log("Section $i: ${salonDetailsss!.sections![i].name}, type: ${salonDetailsss!.sections![i].type}, data length: ${salonDetailsss!.sections![i].data?.length}");
            }
          }

          /// Dispose previous TabController before creating a new one
          _tabController.dispose();
          _tabController = TabController(
            length: salonDetailsss?.sections?.length ?? 1,
            vsync: this,
          );
          log("TabController initialized with ${salonDetailsss?.sections?.length ?? 1} tabs");

          _autoScrollController.addListener(() {
            if (mounted) {
              setState(() {
                isExpanded = !_isAppBarExpanded();
              });
            }
          });
        });
      } else {
        log("WARNING: Widget not mounted, skipping setState");
      }
    } catch (e, stackTrace) {
      log("❌ ERROR in loadJson: $e");
      log("Stack trace: $stackTrace");
      if (mounted) {
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading salon details: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // TODO: FAVOURITES TOGGLE - Add/remove salon from favourites
  // This method calls the API to toggle favourite status
  // Shows loading state, updates UI, and displays success/error messages
  /// Toggle favourite status for the salon
  Future<void> _toggleFavourite() async {
    if (salonDetailsss?.id == null) {
      log('❌ Cannot toggle favourite: Salon ID is null');
      return;
    }

    if (isTogglingFavourite) {
      log('Already toggling favourite, please wait...');
      return;
    }

    setState(() {
      isTogglingFavourite = true;
    });

    try {
      final result = await _favouriteAPI.toggleFavourite(
        shareId: salonDetailsss!.id.toString(),
        shareType: 'salon',
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            isFavourite = result['isFavourite'] ?? false;
            isTogglingFavourite = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Success'),
              backgroundColor: kPrimaryColor,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );

          log('✅ Favourite toggled successfully: $isFavourite');
        } else {
          setState(() {
            isTogglingFavourite = false;
          });

          // Handle error - show dialog for auth errors, snackbar for others
          AuthDialogHelper.handleError(
            context,
            result['message'] ?? 'Failed to update favourite',
            authDialogTitle: 'Login Required',
            authDialogMessage: 'To save your favorite salons and services, please login or create an account.',
            authDialogIcon: Icons.favorite_border,
          );

          log('❌ Failed to toggle favourite: ${result['message']}');
        }
      }
    } catch (e) {
      log('❌ Error toggling favourite: $e');
      if (mounted) {
        setState(() {
          isTogglingFavourite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
        loadJson('$args'); // Fetch data asynchronously
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
      highlightColor: Colors.black.withOpacity(0.1),
      child: child,
    );
  }

  Widget _buildSliverAppbar(BuildContext context) {
    if (salonDetailsss == null) return const SliverToBoxAdapter();
    var size = MediaQuery.of(context).size;
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      snap: false,
      expandedHeight: size.height / 1.60,
      leading: !isExpanded
          ? IconButton(
              icon: const Icon(
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
        preferredSize: const Size.fromHeight(40),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isExpanded ? 0.0 : 1,
          child: TabBar(
            controller: _tabController,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 5.0),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: ShapeDecoration(
              gradient: const LinearGradient(
                  colors: [kPrimaryColor, kPrimaryDarkColor]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            labelStyle:
                const TextStyle(color: blackColor, fontWeight: FontWeight.bold),
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
            }).toList(),
          ),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildSliverAppbarBackground(BuildContext context) {
    var imageList = salonDetailsss?.images;
    final PageController pageController = PageController();
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: PageView.builder(
                controller: pageController,
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
                padding: const EdgeInsets.all(16.0),

                child: SmoothPageIndicator(
                  controller: pageController, // PageController
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
            // TODO: FAVOURITES UI - Heart icon button for add/remove favourites
            // Shows filled heart when favourited, outlined when not
            // Displays loading spinner during API call
            // Icon reflects backend state (isFavourite from API response)
            Positioned(
              right: 16,
              top: 32,
              child: Container(
                decoration: const BoxDecoration(
                    color: whiteColor, shape: BoxShape.circle),
                child: isTogglingFavourite
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(kPrimaryColor),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                        ),
                        color: kPrimaryColor,
                        tooltip: isFavourite
                            ? 'Remove from favourites'
                            : 'Add to favourites',
                        onPressed: _toggleFavourite,
                      ),
              ),
            ),
            Positioned(
              left: 16,
              top: 32,
              child: Container(
                decoration: const BoxDecoration(
                    color: whiteColor, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.45, // 45% of screen width
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white, // Matches background
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  boxShadow: [
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
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Text(
              salonDetailsss?.name ?? "",
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(Icons.location_on, size: 14),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                  child: Text(
                '${salonDetailsss?.location?.address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              )),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          child: Row(
            children: [
              Icon(
                salonDetailsss?.gender == 'female'
                    ? Icons.female
                    : salonDetailsss?.gender == 'male'
                        ? Icons.male
                        : Icons.transgender,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'For ${salonDetailsss!.gender}',
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Ratings(rating: salonDetailsss!.star ?? 0),
              ReviewCount(reviews: salonDetailsss!.review_count ?? 0),
            ],
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        const Divider(thickness: 1, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Us",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.category, size: 14),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                    salonDetailsss!.about.toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCategoryBody() {
    log('===== _buildServiceCategoryBody CALLED =====');
    if (salonDetailsss == null) {
      log('salonDetailsss is null, returning empty adapter');
      return const SliverToBoxAdapter(); // Prevent crashes
    }

    log('Building service body with ${salonDetailsss!.sections?.length ?? 0} sections');
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
                    _buildCategoryTitle(context,
                        salonDetailsss!.sections![index].name.toString()),

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
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ReviewCard(
        review: review,
      ),
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
    //     ],tall girl short guy
    //   ),
    // );
  }

  List<Widget> _buildCategoryItems(BuildContext context, int index) {
    if (salonDetailsss!.sections![index].data!.isEmpty) return [Container()];

    log('Building category items for section $index, type: ${salonDetailsss!.sections![index].type}');
    log('Data length: ${salonDetailsss!.sections![index].data!.length}');

    List<Staff> staff = [];
    List<Widget> list = [];
    for (int i = 0; i < salonDetailsss!.sections![index].data!.length; i++) {
      if (salonDetailsss!.sections![index].type == '3') {
        // review Review
        list.add(_buildSalonReview(
            context, salonDetailsss!.sections![index].data?[i]));
        //_list.add(_buildSalonServiceItem(context));

        // if((i+1) == salonDetailsss?.sections![index].data!.length){
        //   _list.add(_buildSeeAll(context, '1'));
        // }
      } else if (salonDetailsss!.sections![index].type == '6') {
        //deals Offer
        //_list.add(_buildSalonServiceItem(context));

        //_list.add(_buildDealsItem(context, salonDetailsss!.sections![index].data?[i]));
        list.add(_buildDealsItem(
            context, salonDetailsss!.sections![index].data?[i]));

        // if((i+1) == salonDetailsss!.sections![index].data!.length){
        //   _list.add(_buildSeeAll(context, '1'));
        // }
      } else if (salonDetailsss!.sections![index].type == '2') {
        //deals Offer
        //_list.add(_buildSalonServiceItem(context));

        list.add(_buildServiceItem(
            context, salonDetailsss!.sections![index].data?[i]));

        // if((i+1) == salonDetailsss!.sections![index].data!.length){
        //   _list.add(_buildSeeAll(context, '1'));
        // }
      } else if (salonDetailsss!.sections![index].type == '5') {
        //About
        list.add(_buildAbout(context, salonDetailsss!.sections![index].data?[i],
            salonDetailsss!.about ?? ""));
      } else if (salonDetailsss!.sections![index].type == '4') {
        //staff
        log('Processing staff member $i');

        // Cast the data item to Staff type
        if (salonDetailsss!.sections![index].data?[i] != null) {
          Staff staffMember = salonDetailsss!.sections![index].data[i] as Staff;
          log('Staff member: ${staffMember.name}, Image: ${staffMember.image}');
          staff.add(staffMember);
        }

        // Add the widget when we've collected all staff members
        if ((i + 1) == salonDetailsss!.sections![index].data?.length) {
          log('Finished collecting staff. Total: ${staff.length}');
          if (staff.isNotEmpty) {
            list.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: staff
                      .map((item) => _buildSpecialistItem(context, item))
                      .toList(),
                ),
              ),
            ));
          } else {
            // Show a message if no staff available
            list.add(const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No staff members available',
                  style: TextStyle(
                    color: kSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ));
          }
        }
      } else {
        //services
        //_list.add(_buildSalonReview(context, salonDetails.sections[index].data[i]));
      }

      //   if(i == 1){
      //     _list.add(_buildSpecialistItem(serviceItems.data[index].services[i]));
      //   }else{
      //   }
      //
    }

    return list;
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
        deal: deal,
        services: deal.services != null
            ? deal.services!.map((s) => s.name).join(' • ')
            : '',
        price: deal.price ?? 0,
        discountValue: deal.discountValue ?? 0,
        discountType: deal.discountType ?? '-',
        press: () {
          //Navigator.pushNamed(context, ProductsScreen.routeName);
          Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName,
              arguments: deal);
          log('Tapped Deal: ${deal.name}');
          log('Tapped Deal:salon id   ${deal.services?[0].salon?.id}');
          log('Tapped Deal:name   ${deal.services?[0].salon?.name}');
          log('Tapped Deal:image   ${deal.services?[0].salon?.image}');
          log('Tapped Deal:address   ${deal.services?[0].salon?.address}');
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
        salon: service.salon!,
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
          Navigator.pushNamed(context, SalonCategoryAndServicesList.routeName,
              arguments: service);
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
          print("See All clicked $type");
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            width: double.infinity, // Makes the button full width
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(10.0), // 5px rounded corners
              border: Border.all(
                color: kPrimaryDarkColor, // Blue border color
                width: 1.5, // Border width
              ),
            ),
            child: const Center(
              child: Text(
                'See All',
                style: TextStyle(
                    color: kPrimaryDarkColor, // Blue border color
                    fontSize: 20.0, // Font size
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ));
  }

  Widget _buildSpecialistItem(BuildContext context, Staff staff) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryDarkColor
                    .withOpacity(0.1), // Background color of the box
                shape: BoxShape.rectangle, // Shape of the box
                borderRadius:
                    BorderRadius.circular(12.0), // Rounded corners for the box
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centers items vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centers items horizontally
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularNetworkImage(
                    imageUrl: staff.image.toString(),
                    height: 100,
                    width: 100,
                    border: 3,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    staff.name.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff.experience.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kSecondaryColor,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          SizedBox(
            width: double.infinity, // Makes the container full width
            //padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18, 118),
            child: Text(
              info.toString(),
              textAlign: TextAlign.left, // Center the text
              style: const TextStyle(
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
          ...about.openingTimings.map((timing) {
            // Check if the current day matches the opening timing day
            String currentDay = DateFormat('E').format(DateTime.now());
            bool isToday = currentDay == timing.day;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Ensures left-right alignment
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle_outlined, // Plus icon
                        color: isToday
                            ? kPrimaryColor
                            : Colors.black
                                .withOpacity(0.6), // Highlight icon if today
                        size: 10.0, // Icon size
                      ),
                      const SizedBox(width: 10),
                      Text(
                        timing.day.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isToday
                              ? FontWeight.w900
                              : FontWeight
                                  .w400, // Highlight font weight if today
                          color: isToday
                              ? kPrimaryColor
                              : Colors.black
                                  .withOpacity(0.8), // Highlight color if today
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${timing.openingTime} - ${timing.closingTime}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday
                          ? FontWeight.w900
                          : FontWeight.w400, // Highlight font weight if today
                      color: isToday
                          ? kPrimaryColor
                          : Colors.black
                              .withOpacity(0.8), // Highlight color if today
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
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ///service.name+"-",
                            "service.name",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "service.subTitle",
                            textAlign: TextAlign.start,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 4.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          child: const Row(
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
                const SizedBox(
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
                              offset:
                                  const Offset(0, 4), // Position of the shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite_border, // Plus icon
                            color: kPrimaryColor, // Icon color
                            size: 26.0, // Icon size
                          ),
                          onPressed: () {
                            // Add your onPressed code here for plus button
                          },
                        ),
                      ),
                      const SizedBox(
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
                              offset:
                                  const Offset(0, 4), // Position of the shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
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
          const Divider(
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      width: 200,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  // Tags placeholder
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Gender placeholder
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                              decoration: const BoxDecoration(
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

    // Log build method execution
    log('===== BUILD METHOD CALLED =====');
    log('salonDetailsss is null: ${salonDetailsss == null}');
    if (salonDetailsss != null) {
      log('Salon name: ${salonDetailsss!.name}');
      log('Sections count: ${salonDetailsss!.sections?.length ?? 0}');
      log('Images count: ${salonDetailsss!.images.length}');
      log('_autoScrollController hasClients: ${_autoScrollController.hasClients}');
    }
    log('================================');

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
