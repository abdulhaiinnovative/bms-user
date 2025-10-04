import 'dart:developer';
import 'package:app/screens/search_final/price_range_new.dart';
import 'package:app/screens/search_final/sorting_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/filter_categories.dart';
import '../../components/price_range.dart';
import '../../components/sorting.dart';
import '../../constants.dart';
import '../cart/cart_screen.dart';
import '../home/components/icon_btn_with_counter.dart';
import '../home/components/search_field.dart';
import 'deal_card_new.dart';
import 'filter_categories_new.dart';
import 'salon_card_new.dart';
import 'search_provider_new.dart';
import 'services_card_new.dart';


import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/filter_categories.dart';
import '../../components/price_range.dart';
import '../../components/sorting.dart';
import '../../constants.dart';
import 'deal_card_new.dart';
import 'salon_card_new.dart';
import 'search_provider_new.dart';
import 'services_card_new.dart';

class ServicesHeaderNew extends StatefulWidget {
  final TabController tabController;
  final bool? backButtonNav;
  final int? categoryId;
  final String? categoryName;


  const ServicesHeaderNew({Key? key, required this.tabController, required this.backButtonNav, required this.categoryId, required this.categoryName} ) : super(key: key);

  @override
  _SerServicesHeaderNewState createState() => _SerServicesHeaderNewState();
}

class _SerServicesHeaderNewState extends State<ServicesHeaderNew> {
  TextEditingController searchController = TextEditingController();
  int? selectedCategoryId;
  String? selectedCategoryName;
  double minPrice = 100;
  double maxPrice = 100000;
  String? sortBy = 'name';
  String? sortOrder = 'asc';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.categoryId != null){
      selectedCategoryName = widget.categoryName;
      selectedCategoryId = widget.categoryId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }else{
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }

  }

  void _showBottomSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => child,
    ).then((value) {
      if (child is FilterCategoriesNew && value != null) {
        setState(() {
          selectedCategoryId = value['id'];
          selectedCategoryName = value['name'];
          _performSearch();
        });
      } else if (child is PriceRangeNew && value != null) {
        setState(() {
          minPrice = value['minPrice'];
          maxPrice = value['maxPrice'];
          _performSearch();
        });
      } else if (child is SortingNew && value != null) {
        setState(() {
          sortBy = value['sortBy'];
          sortOrder = value['sortOrder'];
          _performSearch();
        });
      }
    });
  }

  void _performBack(){


    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Return to previous screen
      log('Back button pressed: Navigating to previous screen');
    } else {
      log('Back button pressed: No previous route to pop');
    }

  }

  void _performSearch() {
    final searchProvider = Provider.of<SearchProviderNew>(context, listen: false);
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (widget.tabController.index == 0) {
      searchProvider.searchServices(
        searchController.text.isEmpty ? 'all' : searchController.text,
        categoryId: selectedCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } else if (widget.tabController.index == 1) {
      searchProvider.searchDeals(
        searchController.text.isEmpty ? 'all' : searchController.text,
        categoryId: selectedCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } else {
      searchProvider.searchSalons(
        searchController.text.isEmpty ? 'all' : searchController.text,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    }
  }

  List<Widget> _getFilterChips() {
    final chips = <Widget>[];
    if (widget.tabController.index == 0 || widget.tabController.index == 1) {
      // Services or Deals
      if (selectedCategoryId != null) {
        chips.add(FilterItem(
          label: selectedCategoryName ?? 'Category $selectedCategoryId',
          onTap: () => _showBottomSheet(const FilterCategoriesNew()),
          onClear: () => setState(() {
            selectedCategoryId = null;
            selectedCategoryName = null;
            _performSearch();
          }),
        ));
      }
      if (minPrice != 100 || maxPrice != 100000) {
        chips.add(FilterItem(
          label: 'Rs $minPrice - Rs $maxPrice',
          onTap: () => _showBottomSheet(const PriceRangeNew()),
          onClear: () => setState(() {
            minPrice = 100;
            maxPrice = 100000;
            _performSearch();
          }),
        ));
      }
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  //Expanded(child: SearchField(controller: searchController,)),

                  widget.backButtonNav ?? false
                      ? Row(
                    children: [
                      CircleIconButton(
                        onPressed: _performBack,
                        icon: Icons.arrow_back,
                        iconColor: Colors.black.withOpacity(0.55),
                        backgroundColor: Colors.black.withOpacity(0.10),
                        borderColor: Colors.black.withOpacity(0.01),
                        borderWidth: 2.0,
                        iconSize: 25,
                        circleSize: 37,
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                      : const SizedBox(width: 2),





                  Expanded(child: SearchField(
                    controller: searchController,
                    onSubmitted: (value) {
                      _performSearch();
                    },
                  )),


                  // Expanded(
                  //   child: SearchField(
                  //     controller: searchController,
                  //     onSubmitted: (value) {
                  //       _performSearch();
                  //     },
                  //   ),
                  // ),

                  const SizedBox(width: 8),
                  CircleIconButton(
                    onPressed: _performSearch,
                    icon: Icons.search,
                    iconColor: Colors.black.withOpacity(0.55),
                    backgroundColor: Colors.black.withOpacity(0.10),
                    borderColor: Colors.black.withOpacity(0.01),
                    borderWidth: 2.0,
                    iconSize: 25,
                    circleSize: 37,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.sort),
                        SizedBox(width: 4),
                        Text('Sort'),
                      ],
                    ),
                  ),
                  onTap: () {
                    log("Click event on Sort");
                    _showBottomSheet(SortingNew(tabIndex: widget.tabController.index));
                  },
                ),
                const SizedBox(width: 4),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.filter_alt),
                        SizedBox(width: 4),
                        Text('Category'),
                      ],
                    ),
                  ),
                  onTap: () {
                    log("Click event on Category");
                    _showBottomSheet(const FilterCategoriesNew());
                  },
                ),
                const SizedBox(width: 4),
                if (widget.tabController.index == 0 || widget.tabController.index == 1) // Only for Services and Deals
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const Row(
                        children: <Widget>[
                          Icon(Icons.attach_money),
                          SizedBox(width: 4),
                          Text('Price'),
                        ],
                      ),
                    ),
                    onTap: () {
                      log("Click event on Price");
                      _showBottomSheet(const PriceRangeNew());
                    },
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getFilterChips(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: kSecondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: widget.tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.pink,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Services'),
                    Tab(text: 'Deals'),
                    Tab(text: 'Salon'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const FilterItem({required this.label, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(width: 1.5, color: kPrimaryDarkColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  color: kPrimaryDarkColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 2),
              if (onClear != null)
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.cancel, color: kPrimaryDarkColor, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onSubmitted;

  const SearchField({Key? key, required this.controller, this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSecondaryColor.withOpacity(0.1),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: searchOutlineInputBorder,
        focusedBorder: searchOutlineInputBorder,
        enabledBorder: searchOutlineInputBorder,
        hintText: "Search",

      ),
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.done,
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double iconSize;
  final double circleSize;

  const CircleIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.iconSize,
    required this.circleSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}