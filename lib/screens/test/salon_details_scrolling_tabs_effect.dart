//import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/screens/test/restaurant_detail_model.dart';
import 'package:app/screens/test/restaurant_detail_with_food_group.dart';
//import 'package:app/screens/test/salon_detail_model.dart';
//import 'package:app/screens/test/salon_detail_with_food_group.dart';
//import 'package:app/screens/test/salon_detail_with_service_group.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants.dart';
import '../home/components/discount_banner.dart';
import 'data_source.dart';


class SalonDetailsScrollingTabsEffect extends StatefulWidget {
  const SalonDetailsScrollingTabsEffect({super.key});



  static String routeName = "/scrolling_tabs_effect";


  @override
  _SalonDetailsScrollingTabsEffectState createState() =>
      _SalonDetailsScrollingTabsEffectState();
}

class _SalonDetailsScrollingTabsEffectState
    extends State<SalonDetailsScrollingTabsEffect>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  /// Controller to scroll or jump to a particular item.
  ///
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late AutoScrollController _autoScrollController;
  final scrollDirection = Axis.vertical;
  late SalonDetailModel salonDetail;
  late SalonDetailServiceWithGroupModel serviceItems;

  bool isExpanded = true;

  late TabController _tabController;

  //here we want to add or remove items to the map based on the visibility of the items
  //so that we can calculate the current index of tab bar on the visibility of the current item
  final Map<int, bool> _visibleItems = {0: true};

  bool _isAppBarExpanded(BuildContext context) {
    if (!_autoScrollController.hasClients) return false;
    log(
        "The offset scrolled now is ${_autoScrollController.offset} and the height is now ${(MediaQuery.of(context).size.height / 1.6 - kToolbarHeight)}");

    return _autoScrollController.offset >
        (MediaQuery.of(context).size.height / 1.6 - kToolbarHeight);
  }

  @override
  void initState() {




    salonDetail =
        SalonDetailModel.fromJson(salonDetailData["data"]!);
    serviceItems =
        SalonDetailServiceWithGroupModel.fromJson(salonDetailWithService);

    _tabController = TabController(
      length: serviceItems!.data!.length,
      vsync: this,
    );
    _autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection,
    )..addListener(() {
        if (_isAppBarExpanded(context)) {
          if (isExpanded) {
            setState(
              () {
                isExpanded = false;
                log('setState is called');
              },
            );
          }
        } else if (!isExpanded) {
          setState(() {
            log('setState is called');
            isExpanded = true;

          });
        }
      });

    super.initState();

  }

  Future _scrollToIndex(int index) async {
    log(
        "The offset scrolled now is before updating ${_autoScrollController.offset} and the height is now ${(MediaQuery.of(context).size.height / 1.6 - kToolbarHeight)}");

    log("The index to scroll to item is this $index");
    await _autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
    await _autoScrollController.highlight(index,
        animated: true, highlightDuration: Duration(seconds: 2));
    // itemScrollController.jumpTo(index: index, alignment: 1.00);
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

  Widget _buildSliverAppbarBackground(BuildContext context) {
    var imageList = salonDetail.image;
    final PageController _pageController = PageController();
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Image.network(
                      imageList[index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      //height: MediaQuery.of(context).size.height / 4,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0, // Positioned at the bottom
              left: 0,
              right: 0, // Stretch to full width
              child: Container(
                alignment: Alignment.center,
                // Center the content of the container
                padding: EdgeInsets.all(16.0),

                child: SmoothPageIndicator(
                  controller: _pageController, // PageController
                  count: imageList.length,
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
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              salonDetail.name ?? "",
              textAlign: TextAlign.start,
              // style: Theme.of(context)
              //     .textTheme
              //     .headline5
              //     ?.copyWith(fontWeight: FontWeight.bold),
            )),
        Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              _getServiceSpeciality(),
              textAlign: TextAlign.start,
            )),
        Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _getApproximateTime(),
                SizedBox(width: 4),
                // Text("4.5"),
                // SizedBox(width: 4),
                Icon(Icons.star, color: amberColor, size: 16),
                SizedBox(width: 4),
                Text("4.5"),
                SizedBox(width: 4),
                Text("(126) "),
                SizedBox(width: 4),
                _getApproximateFee(),
              ],
            )),

        //DiscountBanner(),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xFF4A3298),
              border: Border.all(width: 1),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListTile(
            leading: Icon(
              Icons.emoji_events,
              color: kPrimaryColor,
            ),
            title: Text(
              "Earn 500 reward points ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "on 5 bookings",
              style: TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: () {}),
          ),
        ),
        Divider(thickness: 2),
        ListTile(
          title: Text(
            "Salon Info",
            // style: Theme.of(context)
            //     .textTheme
            //     .subtitle1
            //     ?.copyWith(fontWeight: FontWeight.bold),
          ),
          trailing: InkWell(
            child: Text(
              "More Info",
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
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
                  "${salonDetail.address.formatted}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
        ),
        Divider(thickness: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Top Picks",
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .subtitle1
                  //     ?.copyWith(fontWeight: FontWeight.bold)
                ),
              IconButton(
                icon: Icon(Icons.star),
                onPressed: () {},
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSliverAppbar(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      snap: false,
      expandedHeight: size.height / 1.33,
      leading: !isExpanded
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: blackColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Container(),
      actions: [
        !isExpanded
            ? IconButton(
                icon: Icon(
                  Icons.circle_outlined,
                  size: 32,
                  color: blackColor,
                ),
                onPressed: () {
                  _showSearchSection(context);
                },
              )
            : Container(),
      ],
      title: !isExpanded
          ? Text(
        salonDetail?.name ?? "",
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
            tabs: serviceItems!.data!.map((e) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: _autoScrollController,
        // shrinkWrap: true,
        slivers: <Widget>[
          _buildSliverAppbar(context),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              _buildServiceCategoryBody(),
            ],
          )),
        ],
      ),
    );
  }

  ListView _buildServiceCategoryBody() {
    return ListView.builder(
      // itemScrollController: itemScrollController,
      // itemPositionsListener: itemPositionsListener,
      shrinkWrap: true,
      addAutomaticKeepAlives: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: serviceItems?.data?.length,
      itemBuilder: (context, index) => VisibilityDetector(
        key: Key(serviceItems!.data[index].sId),
        onVisibilityChanged: (info) {
          // if (!_autoScrollController.isAutoScrolling) return;
          var visiblePercentage = info.visibleFraction * 100;
          if (visiblePercentage > 90) {
            _visibleItems.putIfAbsent(index, () => true);
          } else {
            _visibleItems.remove(index);
          }

          _calculateIndexAndJumpToTab(_visibleItems);
        },
        child: _wrapScrollTag(
          index: index,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildServiceItemCategoryTitle(context, serviceItems!.data[index].name),
              SizedBox(
                height: 16,
              ),
              ..._buildCategoryItems(context, index),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryItems(BuildContext context, int index) {
    if (serviceItems.data[index].services.isEmpty) return [Container()];
    List<Widget> _list = [];
    for (int i = 0; i < serviceItems.data[index].services.length; i++) {
      _list.add(_buildSalonServiceItem(
          context, serviceItems.data[index].services[i]));
    }
    return _list;
  }

  InkWell _buildSalonServiceItem(BuildContext context, Services service) {
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
                            service.name+"-",
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
                            service.subTitle,
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
                                "Rs: ${service.price}",
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

  Container buildServiceItemCategoryTitle(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(8),
      child: Text(name ?? "Picked for you",
          // style: Theme.of(context)
          //     .textTheme
          //     .headline6
          //     ?.copyWith(fontWeight: FontWeight.bold)
      ),
    );
  }

  void _calculateIndexAndJumpToTab(Map<int, bool> visibleItems) async {
    List<int> indexes = List.from(_visibleItems.keys.toList());
    indexes.sort();
    int topMostVisibleItem = indexes.first;
    _tabController.animateTo(topMostVisibleItem);
  }

  @override
  bool get wantKeepAlive => true;

  void _showSearchSection(BuildContext context) async {
    // var result = await showSearch(
    //     context: context,
    //     delegate: AppBarSearchWidget(
    //         ["Pizza", "Coke", "Pumpkin", "Carrot", "Mango"]));
    // print("The searched result is now this $result");
  }

  String _getServiceSpeciality() {
    List<String> result = [];
    for (var a in serviceItems.data) {
      for (var b in a.services) {
        for (var c in b.serviceSpeciality) {
          if (c.name != null && c.name.isNotEmpty && !result.contains(c.name)) {
            result.add(c.name);
          }
        }
      }
    }
    result.insert(0, "\$");
    return result.join("•");
  }

  Text _getApproximateTime() {
    return Text("30 mins");
  }

  Text _getApproximateFee() {
    return Text("14.33");
  }

  String getImageUrlFromApi(String rawUrl) {
    return "https://i.pinimg.com/564x/00/e7/62/00e76210732e10be1a82ea509a3bbb4d.jpg";
  }
}

Widget _indicator(bool isActive) {
  return Container(
    height: 10,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 10 : 8.0,
      width: isActive ? 12 : 8.0,
      decoration: BoxDecoration(
        boxShadow: [
          isActive
              ? BoxShadow(
                  color: Color(0XFF2FB7B2).withOpacity(0.72),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: Offset(
                    0.0,
                    0.0,
                  ),
                )
              : BoxShadow(
                  color: Colors.transparent,
                )
        ],
        shape: BoxShape.circle,
        color: isActive ? Color(0XFF6BC4C9) : Color(0XFFEAEAEA),
      ),
    ),
  );
}
