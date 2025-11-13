import 'dart:developer';

import 'package:app/components/book_now.dart';
import 'package:app/models/SalonServicesCategorizedResponse.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/utlis/authutils/auth_manager.dart';
import 'package:flutter/material.dart';
// import 'package:app/screens/test_scroll/jewellery_repository.dart';
import '../../api_services/salon_services_categorized_api.dart';
import '../../constants.dart';
import 'CartSummarySection.dart';

class SalonCategoryAndServicesList extends StatefulWidget {
  static String routeName = "/scrolling_tab_list";
  const SalonCategoryAndServicesList({Key? key}) : super(key: key);

  @override
  _SalonCategoryAndServicesListState createState() =>
      _SalonCategoryAndServicesListState();
}

class _SalonCategoryAndServicesListState
    extends State<SalonCategoryAndServicesList> {
  final Map<dynamic, int> _cartItems = {};

  double _totalAmount = 0.0;
  int _totalItems = 0;

  void _handleAddToCart(dynamic item) {
    setState(() {
      if (_cartItems.containsKey(item)) {
        _cartItems.remove(item);
      } else {
        _cartItems[item] = 1;
      }

      _totalItems = _cartItems.length;
      _totalAmount = _cartItems.entries.fold(
          0.0, (sum, entry) => sum + (_getItemPrice(entry.key) * entry.value));
    });
  }

  double _getItemPrice(dynamic item) {
    if (item is Service) return (item.price ?? 0).toDouble();
    if (item is Deal) return (item.totalPrice ?? 0).toDouble();
    return 0.0;
  }

  Widget _buildCartWidget() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CartSummarySection(
          totalItems: _cartItems.length,
          totalAmount: _totalAmount,
          buttonColor: kPrimaryDarkColor,
          onContinue: () {
            if (_cartItems.isNotEmpty) {
              Navigator.pushNamed(
                context,
                SelectProfessionals.routeName,
                arguments: {
                  'cartItems': _cartItems,
                  'salonName': mSalonName,
                  'salonImage': mSalonImage,
                  'salonAddress': mSalonAddess,
                },
              );
            }
          },
        ),
      ),
    );
  }

  Service? mSericve;
  Deal? mDeal;

  SalonServicesCategorizedResponse? responseData;
  var mSalonName;
  var mSalonImage;
  var mSalonAddess;

  List<GlobalKey> salonCategories = [];
  late ScrollController scrollController;
  BuildContext? tabContext;

  List<String> tabNames = [];
  List<List<dynamic>> serviceItem = [];

  @override
  void initState() {
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Service) {
        setState(() {
          mSericve = arguments; // Store the Deal object
          log('mSericve:: ${mSericve?.name}');
          mSalonName = mSericve?.salon?.name;
          mSalonImage = mSericve?.salon?.image;
          mSalonAddess = mSericve?.salon?.address;

          log('mSericve:::id   ${mSericve?.salon?.id}');
          log('mSericve:::name   ${mSericve?.salon?.name}');
          log('mSericve:::image   ${mSericve?.salon?.image}');
          log('mSericve:::address   ${mSericve?.salon?.address}');

          _handleAddToCart(mSericve);
        });
      } else if (arguments != null && arguments is Deal) {
        mDeal = arguments; // Store the Deal object
        log('mDeal:: ${mDeal?.name}');
        mSalonName = mDeal?.salon?.name;
        mSalonImage = mDeal?.salon?.image;
        mSalonAddess = mDeal?.salon?.address;

        log('mDeal:::id   ${mDeal?.salon?.id}');
        log('mDeal:::name   ${mDeal?.salon?.name}');
        log('mDeal:::image   ${mDeal?.salon?.image}');
        log('mDeal:::address   ${mDeal?.salon?.address}');
        _handleAddToCart(mDeal);

        log('No Deal data passed');
      }

      loadData();
    });

    super.initState();
  }

  Future<void> loadData() async {
    setState(() {
      scrollController = ScrollController();
      scrollController.addListener(animateToTab);
    });

    SalonServicesCategorizedAPI api = SalonServicesCategorizedAPI();

    log("Fetching categorized services...");

    if (mDeal != null) {
      responseData = await api
          .fetchAllServicesAndDealsCategorizedData(mDeal?.salon?.id ?? 0);
      log("::::mDeal?.services?[0]?.salon?.id  ${mDeal?.salon?.id}");
    } else {
      responseData = await api
          .fetchAllServicesAndDealsCategorizedData(mSericve?.salon?.id ?? 0);
      log("::::mSericve?.services?[0]?.salon?.id  ${mDeal?.salon?.id}");
    }

    print(
        'responseData?.response?.data?.length:0: ${responseData?.response?.data?.length}');

    if (responseData != null) {
      setState(() {
        responseData?.response?.data?.forEach((category) {
          log('Category: ${category.name}');
          // Add category name to tabNames
          tabNames.add(category.name ?? "NA");
          // Create a new list for this category's services
          List<dynamic> categoryServices = [];
          // Add services to the category's list
          category.items?.forEach((item) {
            log('Item: ${item.name}, Price: ${item.price}');

            if (item is Service) {
              categoryServices.add(item);
            } else {
              categoryServices.add(item);
            }
          });
          // Add the category's service list to serviceItem
          serviceItem.add(categoryServices);
          salonCategories.add(GlobalKey());
        });

        // int i = 0;
        // responseData?.response?.data?.forEach((category) {
        //   log('Category: ${category.name}');
        //   tabNames.add(category.name ?? "NA");
        //   i++;
        //   category.services?.forEach((item) {
        //     log('Item: ${item.name}, Price: ${item.price}');
        //     serviceItem.add(item, "i");
        //   });
        // });
      });

      log("tabNames:::: ${tabNames.length}");
      log("serviceItem:::: ${serviceItem.length}");

      log("responseData:::--: ${responseData?.response?.data?.first.name}");
    } else {
      log("responseData::::No data received");
    }
  }

  /// Animate To Tab
  void animateToTab() {
    late RenderBox box;

    for (var i = 0; i < salonCategories.length; i++) {
      box = salonCategories[i].currentContext?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(Offset.zero);

      if (scrollController.offset >= position.dy) {
        DefaultTabController.of(tabContext!).animateTo(
          i,
          duration: const Duration(milliseconds: 100),
        );
      }
    }
  }

  /// Scroll to Index
  void scrollToIndex(int index) async {
    scrollController.removeListener(animateToTab);
    final categories = salonCategories[index].currentContext!;
    await Scrollable.ensureVisible(
      categories,
      duration: const Duration(milliseconds: 600),
    );
    scrollController.addListener(animateToTab);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabNames.length,
      child: Builder(
        builder: (BuildContext context) {
          tabContext = context;
          return Scaffold(
            appBar: _buildAppBar(),
            body: Container(
              color: kScreenBg,
              child: Stack(children: [
                Container(
                  //color: kPrimaryColor,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        for (int i = 0; i < tabNames.length; i++) ...[
                          _buildCategoryTitle(tabNames[i], i),
                          _buildItemList(serviceItem[i]),
                        ],
                        const SizedBox(
                          height: 90,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildCartWidget(),
              ]),
            ),
          );
        },
      ),
    );
  }

  /// AppBar
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Ensures circular shape
              border: Border.all(
                color: kPrimaryDarkColor, // Border color (customize as needed)
                width: 3.0, // Border width
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  25.0), // Half of 50 for a perfect circle
              child: mSalonImage != null && mSalonImage!.isNotEmpty
                  ? Image.network(
                      mSalonImage!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 50,
                          width: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 50,
                        width: 50,
                        color: Colors.grey[300],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mSalonName ?? 'No Salon Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  mSalonAddess ?? 'No Address',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: tabNames.isNotEmpty
          ? TabBar(
              isScrollable: true,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodyMedium?.color,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w400),
              tabs: tabNames.map((name) => Tab(child: Text(name))).toList(),
              onTap: (int index) => scrollToIndex(index),
            )
          : null,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 4,
    );
  }

  /// Item Lists
  Widget _buildItemList(List<dynamic> categories) {
    print("============1");

    try {
      return Column(
        children: categories.map((m3) => _buildSingleItem(m3)).toList(),
      );
    } catch (e) {
      return Column(
        children: categories.map((m3) => _buildSingleDealItem(m3)).toList(),
      );
    }
  }

  /// Single Product item widget
  Widget _buildSingleItem(Service item) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 12, left: 12),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item.name}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${item.description}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    //TODO: Add Booking Button Here
                                    Flexible(
                                      child: Text(
                                        'Rs: ${item.price}',
                                        style: const TextStyle(
                                            color: kPrice,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    if (item.discountType != null)
                                      Flexible(
                                        child: Text(
                                          'Rs: ${item.oldPrice}',
                                          style: const TextStyle(
                                            color: kBeforeDiscount,
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              //
                              // Spacer(),
                              //
                              const SizedBox(
                                width: 6,
                              ),
                              if (item.discountType == 'price')
                                const BookNow()

                              ///SaleAmount(sale: item.discountAmount ?? 0)
                              else if (item.discountType == 'percentage')
                                const BookNow(),

                              ///SalePercentage(off: item.percentageDiscount ?? 0, type:  '',),

                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => _handleAddToCart(item),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _cartItems.containsKey(item)
                                          ? kPrimaryDarkColor
                                          : kScreenBg,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _cartItems.containsKey(item)
                                          ? 'Added'
                                          : 'Add',
                                      style: TextStyle(
                                        color: _cartItems.containsKey(item)
                                            ? Colors.white
                                            : kPrimaryDarkColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _buildSingleDealItem(Deal item) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 12, left: 12),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (item.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kRadius),
                    child: Image.network(
                      item.image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey),
                    ),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? "---",
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.services != null
                              ? item.services!.map((s) => s.name).join(' • ')
                              : '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${item.totalPrice ?? ''} RS",
                                        style: const TextStyle(
                                            color: kPrice,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "${item.price ?? ''} RS",
                                        style: const TextStyle(
                                          color: kBeforeDiscount,
                                          fontSize: 14,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () => _handleAddToCart(item),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _cartItems.containsKey(item)
                                          ? kPrimaryDarkColor
                                          : kScreenBg,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _cartItems.containsKey(item)
                                          ? 'Added'
                                          : 'Add',
                                      style: TextStyle(
                                        color: _cartItems.containsKey(item)
                                            ? Colors.white
                                            : kPrimaryDarkColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Category Title
  Widget _buildCategoryTitle(String title, int index) {
    return Padding(
      key: salonCategories[index],
      padding: const EdgeInsets.only(top: 14, right: 12, left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   child: const Text(
              //     'View more',
              //     style: TextStyle(
              //         fontSize: 13,
              //         fontWeight: FontWeight.w300,
              //         color: Colors.indigo),
              //   ),
              // ),
            ],
          ),
          //const Divider(),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}
