import 'dart:developer';

import 'package:app/models/SalonServicesCategorizedResponse.dart';
import 'package:app/models/salon_detail_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../api_services/salon_services_categorized_api.dart';
import '../../constants.dart';
import '../../components/cart_bottom_bar.dart';

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
  // Removed local _cartItems and _totalAmount. Use CartProvider directly.
  // Modal state is handled by `CartModal` via `CartProvider` now.

  void _handleAddToCart(dynamic item) {
    if (!mounted) return; // Check if widget is still mounted

    // Use Consumer<CartProvider> for all provider access

    // Get salon ID from the item being added
    int? itemSalonId;
    if (item is Service) {
      itemSalonId = mSalonData?.id ?? item.salonId;
      // TODO: booking.flow - Adding service to cart (log removed)
    } else if (item is Deal) {
      itemSalonId = mSalonData?.id ?? item.salonId;
      // TODO: booking.flow - Adding deal to cart (log removed)
    }

    // Get cart's current salon ID
    // Use Consumer for all provider access
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            int? cartSalonId = cartProvider.salonId;
            if (cartSalonId != null &&
                itemSalonId != null &&
                cartSalonId != itemSalonId &&
                cartProvider.items.isNotEmpty) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Replace Cart Items?'),
                  ],
                ),
                content: Text(
                  'Your cart contains items from ${cartProvider.salonName}. Do you want to clear the cart and add items from this salon?',
                  style: const TextStyle(fontSize: 15),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      cartProvider.clearCart();
                      cartProvider.setSalonInfo(itemSalonId, mSalonName);
                      cartProvider.addItem(item, quantity: 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Replace'),
                  ),
                ],
              );
            } else {
              // If not replacing, just add/toggle item
              cartProvider.toggleItem(item);
              Navigator.pop(context);
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
    // No direct provider access
  }

  // Removed unused _increaseQuantity

  // Removed unused _decreaseQuantity

  // Removed unused _removeItem

  void _loadExistingCartItems() {
    if (!mounted) return;
    // Use Consumer for provider access
    // ...existing code...
    // No local snapshot needed; UI will update from provider.
  }

  // Sync cart items with newly loaded data from API
  // This replaces old cart item instances with new ones from the API that have matching IDs
  void _syncCartWithLoadedData() {
    // No local cart to sync; rely on provider.
  }

  // Helper method to check if an item is in cart by ID
  bool _isItemInCart(dynamic item) {
    final items = context.watch<CartProvider>().items;
    if (item is Service && item.id != null) {
      return items.keys
          .any((cartItem) => cartItem is Service && cartItem.id == item.id);
    } else if (item is Deal && item.id != null) {
      return items.keys
          .any((cartItem) => cartItem is Deal && cartItem.id == item.id);
    }
    return items.containsKey(item);
  }

  // Helper method to get the actual cart item by ID
  // Removed unused _getCartItem

  // Removed unused _getItemPrice

  void _proceedToCheckout() {
    // TODO: booking.flow - Proceed to checkout clicked (log removed)

    // Use Consumer for provider access
    // ...existing code...
  }

  Widget _buildCartWidget() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CartBottomBar(
        onProceed: _proceedToCheckout,
        proceedButtonText: 'Proceed',
        buttonColor: kPrimaryDarkColor,
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

    // TODO: booking.flow - initState called (log removed)

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still mounted

      // Load existing cart items from CartProvider
      _loadExistingCartItems();
      log("Salon detail view");
      log("Salon detail view1");
      log("Salon detail view2");
      log("Salon detail view3");
      log("Salon detail view4");
      log("Salon detail view5");
      log("Salon detail view6");

      final arguments = ModalRoute.of(context)?.settings.arguments;

      // TODO: booking.flow - Arguments received (log removed)

      // New format: {item: service/deal, salonDetailsss: SalonData}
      if (arguments != null && arguments is Map<String, dynamic>) {
        final item = arguments['item'];
        mSalonData = arguments['salonDetailsss'] as SalonData?;

        if (item is Service) {
          setState(() {
            mSericve = item;
            mSalonName = mSalonData?.name;
            mSalonImage = mSalonData?.logo;
            mSalonAddess = mSalonData?.location?.address;

            // Sync salon info to CartProvider
            context.read<CartProvider>().setSalonInfo(
                  mSalonData?.id,
                  mSalonName,
                );

            _handleAddToCart(mSericve);
          });
        } else if (item is Deal) {
          setState(() {
            mDeal = item;
            mSalonName = mSalonData?.name;
            mSalonImage = mSalonData?.logo;
            mSalonAddess = mSalonData?.location?.address;

            // Sync salon info to CartProvider
            context.read<CartProvider>().setSalonInfo(
                  mSalonData?.id,
                  mSalonName,
                );

            _handleAddToCart(mDeal);
          });
        }
      }
      // Old format removed - only use new format with salonDetailsss parameter

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

    try {
      setState(() {
        scrollController = ScrollController();
        scrollController.addListener(animateToTab);
      });

      SalonServicesCategorizedAPI api = SalonServicesCategorizedAPI();

      // Use mSalonData if available, otherwise fall back to service/deal salonId
      int salonId = mSalonData?.id ?? mDeal?.salonId ?? mSericve?.salonId ?? 0;

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

          // Sync cart items with newly loaded data
          _syncCartWithLoadedData();
        });
        // TODO: booking.flow - services loaded (log removed)
      }
    } catch (error) {
      // Handle errors gracefully - show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unable to load services. ${error.toString().contains('401') ? 'Please login to continue.' : 'Please try again later.'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      // TODO: booking.flow - error loading salon data (log removed)
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
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
                    ),
                    // Info button
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: kPrimaryColor,
                        size: 24,
                      ),
                      onPressed: () => _showServiceDetailBottomSheet(item),
                      tooltip: 'View Details',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
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
                            color: _isItemInCart(item)
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
                            _isItemInCart(item) ? 'Added' : 'Book Now',
                            style: TextStyle(
                              color: _isItemInCart(item)
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

  /// Show Service Detail Bottom Sheet
  void _showServiceDetailBottomSheet(Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Service details content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name
                      Text(
                        service.name ?? 'Service',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Price and Duration Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.attach_money,
                              label: 'Price',
                              value: 'PKR ${service.price}',
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time,
                              label: 'Duration',
                              value: service.duration != null ? '${service.duration} min' : 'N/A',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      if (service.oldPrice != null && service.oldPrice! > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Original Price: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'PKR ${service.oldPrice}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(((service.oldPrice! - service.price!) / service.oldPrice!) * 100).round()}% OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Description
                      if (service.description != null && service.description!.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: kSecondaryColor,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom Action Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isItemInCart(service) ? kPrimaryDarkColor : kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _handleAddToCart(service);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isItemInCart(service) ? Icons.check_circle : Icons.add_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isItemInCart(service) ? 'Added to Cart' : 'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Info card widget for bottom sheet
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
                                color: _isItemInCart(item)
                                    ? Colors.grey.shade400
                                    : kPrimaryColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: (kPrimaryColor).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isItemInCart(item)
                                        ? Icons.check_circle_outline
                                        : Icons.add_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isItemInCart(item) ? 'Added' : 'Add',
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
