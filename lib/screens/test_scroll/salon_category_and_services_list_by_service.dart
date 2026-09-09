import 'dart:developer';

import 'package:app/models/SalonServicesCategorizedResponse.dart';
import 'package:app/models/salon_detail_models.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
// Debug logging imports removed
import 'package:flutter/material.dart';
// import 'package:app/screens/test_scroll/jewellery_repository.dart';
import '../../api_services/salon_services_categorized_api.dart';
import '../../constants.dart';
import '../../components/cart_bottom_bar.dart';

class SalonCategoryAndServicesListByService extends StatefulWidget {
  static String routeName = "/scrolling_tab_list_by_service";
  const SalonCategoryAndServicesListByService({Key? key}) : super(key: key);

  @override
  _SalonCategoryAndServicesListByServiceState createState() =>
      _SalonCategoryAndServicesListByServiceState();
}

class _SalonCategoryAndServicesListByServiceState
    extends State<SalonCategoryAndServicesListByService> {
  final Map<Service, int> _cartItems = {};
  double _totalAmount = 0.0;

  void _handleAddToCart(Service service) {
    setState(() {
      if (_cartItems.containsKey(service)) {
        _cartItems.remove(service);
      } else {
        _cartItems[service] = 1;
      }

      _totalAmount = _cartItems.entries
          .fold(0.0, (sum, entry) => sum + (entry.key.price! * entry.value));
    });
  }

  // Add this widget at the bottom of your Scaffold
  Widget _buildCartWidget() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CartBottomBar(
        totalItemsOverride: _cartItems.length,
        totalAmountOverride: _totalAmount,
        buttonColor: kPrimaryDarkColor,
        buttonText: 'Continue',
        onTap: () {
          if (_cartItems.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectProfessionals(),
                settings: RouteSettings(
                  arguments: {
                    'cartItems': _cartItems,
                    'salonName': mSalonName,
                    'salonImage': mSalonImage,
                    'salonAddress': mSalonAddess,
                    'salonId':
                        mDeal?.salonId ?? mService?.salonId, // Use salonId
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Deal? mDeal;
  Service? mService;
  SalonServicesCategorizedResponse? responseData;
  var mSalonName;
  var mSalonImage;
  var mSalonAddess;

  List<GlobalKey> salonCategories = [];
  late ScrollController scrollController;
  BuildContext? tabContext;

  List<String> tabNames = [];
  List<List<Service>> serviceItem = [];

  @override
  void initState() {
    log("initState called in SalonCategoryAndServicesListByService");
    log("Initial mDeal: $mDeal, mService: $mService, mSalonName: $mSalonName, mSalonImage: $mSalonImage, mSalonAddess: $mSalonAddess");
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Deal) {
        setState(() {
          mDeal = arguments; // Store the Deal object
          mSalonName = null; // Salon name not available in Deal object
          mSalonImage = null; // Salon image not available in Deal object
          mSalonAddess = null; // Salon address not available in Deal object
        });
      } else if (arguments != null && arguments is Service) {
        setState(() {
          mService = arguments; // Store the Service object
          mSalonName = null; // Salon name not available in Service object
          mSalonImage = null; // Salon image not available in Service object
          mSalonAddess = null; // Salon address not available in Service object

          // Add service to cart automatically
          if (mService != null) {
            _handleAddToCart(mService!);
          }
        });
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

    // Get salon ID from either Deal or Service
    int? salonId = mDeal?.salonId ?? mService?.salonId;

    if (salonId == null || salonId == 0) {
      return;
    }

    responseData = await api.fetchAllServicesAndDealsCategorizedData(salonId);

    if (responseData != null) {
      setState(() {
        responseData?.response?.data?.forEach((category) {
          // Add category name to tabNames
          tabNames.add(category.name ?? "NA");
          // Create a new list for this category's services
          List<Service> categoryServices = [];
          // Add the category's service list to serviceItem
          serviceItem.add(categoryServices);
          salonCategories.add(GlobalKey());
        });
      });

      // Debug logging removed
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
            body: Stack(children: [
              SingleChildScrollView(
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
              _buildCartWidget(),
            ]),
          );
        },
      ),
    );
  }

  /// AppBar - Brand new design from scratch with horizontal scrollable tabs
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColor,
      elevation: 8,
      shadowColor: kPrimaryColor.withOpacity(0.4),
      toolbarHeight: 140,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryColor,
              Color(0xFF551E66),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Top Row: Back button and Info icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    // Info or Share Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Salon Info Row - Centered Layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Salon Image
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: mSalonImage != null && mSalonImage!.isNotEmpty
                            ? Image.network(
                                mSalonImage!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.white,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  kPrimaryColor),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: kPrimaryColor,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: kPrimaryColor,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Salon Name and Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mSalonName ?? 'Select Services',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB800),
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '4.8',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: tabNames.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tabNames.length,
                    itemBuilder: (context, index) {
                      final isSelected =
                          DefaultTabController.of(context).index == index;
                      return GestureDetector(
                        onTap: () {
                          DefaultTabController.of(context).animateTo(index);
                          scrollToIndex(index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            tabNames[index],
                            style: TextStyle(
                              color: isSelected ? kPrimaryColor : Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : null,
    );
  }

  /// Item Lists
  Widget _buildItemList(List<Service> categories) {
    return Column(
      children: categories.map((m3) => _buildSingleItem(m3)).toList(),
    );
  }

  /// Single Product item widget
  Widget _buildSingleItem(Service item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Name
          Text(
            item.name ?? "---",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          // Service Description
          Text(
            item.description ?? "No description available",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Price and Add Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "PKR ${item.price}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.oldPrice != null && item.oldPrice != item.price)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        "PKR ${item.oldPrice}",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              // Add Button
              Container(
                decoration: BoxDecoration(
                  color: _cartItems.containsKey(item)
                      ? const Color(0xFF4CAF50)
                      : kPrimaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_cartItems.containsKey(item)
                              ? const Color(0xFF4CAF50)
                              : kPrimaryColor)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleAddToCart(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _cartItems.containsKey(item)
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          const Divider(),
        ],
      ),
    );
  }
}
