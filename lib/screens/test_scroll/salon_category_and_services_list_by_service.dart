import 'dart:developer';

import 'package:app/models/HomePageResponse.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/presentation/viewmodels/salon_services/salon_services_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import 'CartSummarySection.dart';

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
  int _totalItems = 0;

  void _handleAddToCart(Service service) {
    setState(() {
      if (_cartItems.containsKey(service)) {
        _cartItems.remove(service);
      } else {
        _cartItems[service] = 1;
      }

      _totalItems = _cartItems.length;
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

  Deal? mDeal;
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
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Deal) {
        setState(() {
          mDeal = arguments; // Store the Deal object
          log('mDeal:: ${mDeal?.name}');
          mSalonName = mDeal?.services?[0].salon?.name;
          mSalonImage = mDeal?.services?[0].salon?.image;
          mSalonAddess = mDeal?.services?[0].salon?.address;

          log('Deal:id   ${mDeal?.services?[0].salon?.id}');
          log('Deal:name   ${mDeal?.services?[0].salon?.name}');
          log('Deal:image   ${mDeal?.services?[0].salon?.image}');
          log('Deal:address   ${mDeal?.services?[0].salon?.address}');
        });
      } else {
        log('No Deal data passed');
      }

      loadData();
    });

    super.initState();
  }

  Future<void> loadData() async {
    final viewModel = context.read<SalonServicesViewModel>();

    setState(() {
      scrollController = ScrollController();
      scrollController.addListener(animateToTab);
    });

    log("mDeal?.services?[0]?.salon?.id  ${mDeal?.services?[0].salon?.id}");

    int salonId = mDeal?.services?[0].salon?.id ?? 0;

    // Load data using ViewModel
    await viewModel.loadCategorizedServices(salonId);

    // Process the loaded data
    if (viewModel.categories != null && viewModel.categories!.isNotEmpty) {
      setState(() {
        tabNames.clear();
        serviceItem.clear();
        salonCategories.clear();

        viewModel.categories!.forEach((category) {
          log('Category: ${category.name}');
          // Add category name to tabNames
          tabNames.add(category.name ?? "NA");
          // Create a new list for this category's services
          List<Service> categoryServices = [];
          // Add services to the category's list (if they are Service type)
          category.items?.forEach((item) {
            if (item is Service) {
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

      log("First category name: ${viewModel.categories!.first.name}");
    } else {
      log("No data received from ViewModel");
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
  Widget _buildItemList(List<Service> categories) {
    return Column(
      children: categories.map((m3) => _buildSingleItem(m3)).toList(),
    );
  }

  /// Single Product item widget
  Widget _buildSingleItem(Service item) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          item.description ?? "-=-",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${item.price}",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${item.price} RS",
                                    style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 13,
                                        color: Colors.grey),
                                  ),
                                ],
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
                                        offset: const Offset(
                                            0, 4), // Position of the shadow
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _cartItems.containsKey(item)
                                          ? Icons.check
                                          : Icons.add,
                                      color: _cartItems.containsKey(item)
                                          ? Colors.green
                                          : Colors.black,
                                      size: 26.0,
                                    ),
                                    onPressed: () => _handleAddToCart(item),
                                  )),
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
          const Divider(),
        ],
      ),
    );
  }
}
