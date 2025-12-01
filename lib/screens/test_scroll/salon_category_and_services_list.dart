import 'package:app/models/SalonServicesCategorizedResponse.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/models/SalonDetailApiResponse.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:flutter/material.dart';
import '../../api_services/salon_services_categorized_api.dart';
import '../../constants.dart';
import 'CartSummarySection.dart';

// TODO: [FEATURE] Add service search functionality within categories
// TODO: [FEATURE] Implement service comparison feature
// TODO: [FEATURE] Add "Recently Added Services" section
// TODO: [FEATURE] Add service bundling suggestions
// TODO: [ENHANCEMENT] Show estimated service duration for each service
// TODO: [ENHANCEMENT] Add service preview with before/after images
// TODO: [UX] Implement cart persistence across sessions
// TODO: [UX] Add "Save for Later" functionality
// TODO: [UX] Show "Popular Services" badge
// TODO: [OPTIMIZATION] Lazy load service images
// TODO: [ACCESSIBILITY] Add haptic feedback for cart actions

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

  void _handleAddToCart(dynamic item) {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      if (_cartItems.containsKey(item)) {
        _cartItems.remove(item);
      } else {
        _cartItems[item] = 1;
      }

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
              // Convert SalonData to Salon object for navigation
              Salon? salonObject;
              if (mSalonData != null) {
                // Convert SalonActiveDay to ActiveDay
                List<ActiveDay>? activeDays;
                if (mSalonData!.activeDays != null) {
                  activeDays = mSalonData!.activeDays!.map((sad) {
                    return ActiveDay(
                      id: sad.id,
                      salonId: sad.salonId,
                      day: sad.day,
                      openingTime: sad.openingTime,
                      closingTime: sad.closingTime,
                      status: sad.status,
                    );
                  }).toList();
                }

                // Create a Salon object from SalonData
                salonObject = Salon(
                  id: mSalonData!.id,
                  name: mSalonData!.name,
                  logo: mSalonData!.logo,
                  image: (mSalonData!.images.isNotEmpty)
                      ? mSalonData!.images.first
                      : null,
                  address: mSalonData!.location?.address,
                  latitude: mSalonData!.location?.lat,
                  longitude: mSalonData!.location?.long,
                  minBookingTime: mSalonData!.minBookingTime,
                  maxBookingTime: mSalonData!.maxBookingTime,
                  type: mSalonData!.type,
                  facebook: mSalonData!.fackebook,
                  instagram: mSalonData!.instagram,
                  twitter: mSalonData!.twitter,
                  linkedin: mSalonData!.linkedin,
                  salonFor: mSalonData!.gender,
                  salonPolicy: mSalonData!.policy,
                  about: mSalonData!.about,
                  averageRating: mSalonData!.star,
                  reviewCount: mSalonData!.review_count,
                  isFavourite: mSalonData!.isFavourite,
                  activeDays: activeDays,
                );
              } else {
                salonObject = mDeal?.salon ?? mSericve?.salon;
              }

              Navigator.pushNamed(
                context,
                SelectProfessionals.routeName,
                arguments: {
                  'cartItems': _cartItems,
                  'salonName': mSalonName,
                  'salonImage': mSalonImage,
                  'salonAddress': mSalonAddess,
                  'salon': salonObject,
                  'salonId':
                      mSalonData?.id ?? mDeal?.salon?.id ?? mSericve?.salon?.id,
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
  SalonData? mSalonData;

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
      if (!mounted) return; // Check if widget is still mounted

      final arguments = ModalRoute.of(context)?.settings.arguments;

      // New format: {item: service/deal, salonDetailsss: SalonData}
      if (arguments != null && arguments is Map<String, dynamic>) {
        final item = arguments['item'];
        mSalonData = arguments['salonDetailsss'] as SalonData?;

        if (item is Service) {
          setState(() {
            mSericve = item;
            mSalonName = mSalonData?.name ?? mSericve?.salon?.name;
            mSalonImage = mSalonData?.logo ?? mSericve?.salon?.image;
            mSalonAddess =
                mSalonData?.location?.address ?? mSericve?.salon?.address;

            _handleAddToCart(mSericve);
          });
        } else if (item is Deal) {
          setState(() {
            mDeal = item;
            mSalonName = mSalonData?.name ?? mDeal?.salon?.name;
            mSalonImage = mSalonData?.logo ?? mDeal?.salon?.image;
            mSalonAddess =
                mSalonData?.location?.address ?? mDeal?.salon?.address;

            _handleAddToCart(mDeal);
          });
        }
      }
      // Old format for backward compatibility
      else if (arguments != null && arguments is Service) {
        setState(() {
          mSericve = arguments;
          mSalonName = mSericve?.salon?.name;
          mSalonImage = mSericve?.salon?.image;
          mSalonAddess = mSericve?.salon?.address;

          _handleAddToCart(mSericve);
        });
      } else if (arguments != null && arguments is Deal) {
        mDeal = arguments;
        mSalonName = mDeal?.salon?.name;
        mSalonImage = mDeal?.salon?.image;
        mSalonAddess = mDeal?.salon?.address;
        _handleAddToCart(mDeal);
      }

      loadData();
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the scroll controller to prevent memory leaks
    scrollController.removeListener(animateToTab);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      scrollController = ScrollController();
      scrollController.addListener(animateToTab);
    });

    SalonServicesCategorizedAPI api = SalonServicesCategorizedAPI();

    // Use mSalonData if available, otherwise fall back to service/deal salon
    int salonId =
        mSalonData?.id ?? mDeal?.salon?.id ?? mSericve?.salon?.id ?? 0;

    responseData = await api.fetchAllServicesAndDealsCategorizedData(salonId);

    if (responseData != null && mounted) {
      setState(() {
        responseData?.response?.data?.forEach((category) {
          // Add category name to tabNames
          tabNames.add(category.name ?? "NA");
          // Create a new list for this category's services
          List<dynamic> categoryServices = [];
          // Add services to the category's list
          category.items?.forEach((item) {
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
      });
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

  /// AppBar - Modern redesigned from scratch
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            // Modern back button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: kPrimaryColor,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Salon info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mSalonName ?? 'Browse Services',
                    style: const TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 4),
                  // Row(
                  //   children: [
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 8,
                  //         vertical: 3,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: kPrimaryColor.withOpacity(0.15),
                  //         borderRadius: BorderRadius.circular(6),
                  //       ),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           const Icon(
                  //             Icons.shopping_bag_outlined,
                  //             size: 13,
                  //             color: kPrimaryColor,
                  //           ),
                  //           const SizedBox(width: 4),
                  //           Text(
                  //             '${_cartItems.length} items',
                  //             style: const TextStyle(
                  //               color: kPrimaryColor,
                  //               fontSize: 12,
                  //               fontWeight: FontWeight.w700,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     if (_totalAmount > 0)
                  //       Container(
                  //         padding: const EdgeInsets.symmetric(
                  //           horizontal: 8,
                  //           vertical: 3,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           color: const Color(0xFF4CAF50).withOpacity(0.15),
                  //           borderRadius: BorderRadius.circular(6),
                  //         ),
                  //         child: Text(
                  //           'PKR ${_totalAmount.toStringAsFixed(0)}',
                  //           style: const TextStyle(
                  //             color: Color(0xFF4CAF50),
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w700,
                  //           ),
                  //         ),
                  //       ),
                  //   ],
                  // ),
                ],
              ),
            ),
            // Salon image
            if (mSalonImage != null && mSalonImage!.isNotEmpty)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    mSalonImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: kPrimaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: kPrimaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottom: tabNames.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  indicatorColor: kPrimaryColor,
                  indicatorWeight: 3.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: -0.2,
                    color: Colors.grey[500],
                  ),
                  tabs: tabNames
                      .map((name) => Tab(
                            height: 44,
                            child: Text(name),
                          ))
                      .toList(),
                  onTap: (int index) => scrollToIndex(index),
                ),
              ),
            )
          : null,
    );
  }

  /// Item Lists
  Widget _buildItemList(List<dynamic> categories) {
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

  /// Single Product item widget - Redesigned with enhanced spacing and typography
  Widget _buildSingleItem(Service item) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name and description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price and button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              'PKR ${item.price}',
                              style: const TextStyle(
                                color: kPrice,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.discountType != null &&
                              item.oldPrice != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 2),
                              child: Text(
                                'PKR ${item.oldPrice}',
                                style: const TextStyle(
                                  color: kBeforeDiscount,
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => _handleAddToCart(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _cartItems.containsKey(item)
                                ? kPrimaryDarkColor
                                : kScreenBg,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            _cartItems.containsKey(item) ? 'Added' : 'Book Now',
                            style: TextStyle(
                              color: _cartItems.containsKey(item)
                                  ? Colors.white
                                  : kPrimaryDarkColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  /// Deal Card - Redesigned with price below image
  Widget _buildSingleDealItem(Deal item) {
    // Calculate discount percentage if available
    int? discountPercent;
    if (item.price != null && item.totalPrice != null && item.price! > 0) {
      discountPercent =
          (((item.price! - item.totalPrice!) / item.price!) * 100).round();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Section: Image and Price
                Column(
                  children: [
                    // Deal Image with Badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.image != null
                              ? Image.network(
                                  item.image!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.local_offer_rounded,
                                      size: 35,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.local_offer_rounded,
                                    size: 35,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                        // Discount Badge
                        if (discountPercent != null && discountPercent > 0)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF8E53),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '$discountPercent% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price Section
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PKR ${item.totalPrice ?? ''}",
                            style: const TextStyle(
                              color: kPrice,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.price != null)
                            Text(
                              "PKR ${item.price}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Right Section: Deal Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deal Name
                      Text(
                        item.name ?? "---",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Services Count Badge
                      if (item.services != null && item.services!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.services!.length} Services',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Services List
                      if (item.services != null && item.services!.isNotEmpty)
                        Text(
                          item.services!.map((s) => s.name).join(' • '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Add Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _handleAddToCart(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: _cartItems.containsKey(item)
                                    ? const Color(0xFF4CAF50)
                                    : kPrimaryColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_cartItems.containsKey(item)
                                            ? const Color(0xFF4CAF50)
                                            : kPrimaryColor)
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _cartItems.containsKey(item)
                                        ? Icons.check_circle_outline
                                        : Icons.add_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _cartItems.containsKey(item)
                                        ? 'Added'
                                        : 'Add',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
        const SizedBox(height: 4),
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
            ],
          ),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}
