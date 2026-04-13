import 'price_range_new.dart';
import 'sorting_new.dart';
import 'gender_filter_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import 'package:app/features/home/presentation/widgets/search_field.dart';
import '../../data/api/filter_categories_new.dart';
import '../providers/search_provider_new.dart';

class ServicesHeaderNew extends StatefulWidget {
  final TabController tabController;
  final bool? backButtonNav;
  final int? categoryId;
  final String? categoryName;

  const ServicesHeaderNew(
      {Key? key,
      required this.tabController,
      required this.backButtonNav,
      required this.categoryId,
      required this.categoryName})
      : super(key: key);

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
  String? selectedGender;

  void _tabListener() {
    if (!widget.tabController.indexIsChanging && mounted) {
      setState(() {
        // This will trigger a rebuild to update filter chips visibility
      });

      // Re-apply search with current filters when tab changes
      // Use post-frame callback to ensure tab change and setState complete before searching
      // This prevents race conditions and ensures filters are applied correctly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final searchProvider =
              Provider.of<SearchProviderNew>(context, listen: false);
          if (searchProvider.hasSearched) {
            _performSearch();
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Add tab controller listener to update UI when tab changes
    widget.tabController.addListener(_tabListener);

    // Only auto-search if navigated with a pre-selected category
    // Otherwise, data stays empty until user explicitly searches
    if (widget.categoryId != null) {
      selectedCategoryName = widget.categoryName;
      selectedCategoryId = widget.categoryId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
    // No automatic search - user must search to get results
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_tabListener);
    super.dispose();
  }

  void _showBottomSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
      } else if (child is GenderFilterNew && value != null) {
        setState(() {
          selectedGender = value['gender'];
          _performSearch();
        });
      }
    });
  }

  void _performBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Return to previous screen
    } else {
      // No previous route to pop
    }
  }

  /// Get filter_type based on current tab index
  String _getFilterTypeForCurrentTab() {
    switch (widget.tabController.index) {
      case 0:
        return 'service';
      case 1:
        return 'deal';
      case 2:
        return 'salon';
      default:
        return 'service';
    }
  }

  void _performSearch() {
    final searchProvider =
        Provider.of<SearchProviderNew>(context, listen: false);
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    // Get the search query - pass empty string if no search text
    // The API will use filters to return results
    final query = searchController.text.trim();
    final filterType = _getFilterTypeForCurrentTab();

    // Search based on current tab's filter type
    // Only pass filters that are applicable to the current tab
    switch (filterType) {
      case 'service':
        // Services support: category, price, gender, sort
        searchProvider.searchServices(
          query,
          categoryId: selectedCategoryId,
          minPrice: minPrice != 100 ? minPrice : null,
          maxPrice: maxPrice != 100000 ? maxPrice : null,
          gender: selectedGender, // Gender applies to services
          sortBy: _mapSortBy(sortBy, sortOrder),
        );
        break;
      case 'deal':
        // Deals support: category, price, sort (NO gender)
        searchProvider.searchDeals(
          query,
          categoryId: selectedCategoryId,
          minPrice: minPrice != 100 ? minPrice : null,
          maxPrice: maxPrice != 100000 ? maxPrice : null,
          sortBy: _mapSortBy(sortBy, sortOrder),
          // Note: Gender is NOT passed for deals as they don't have gender property
        );
        break;
      case 'salon':
        // Salons support: gender, sort (NO category, NO price)
        searchProvider.searchSalons(
          query,
          gender: selectedGender != null
              ? [selectedGender!]
              : null, // Gender applies to salons
          sortBy: _mapSortBy(sortBy, sortOrder),
          // Note: Category and price are NOT passed for salons
        );
        break;
    }
  }

  /// Maps sortBy and sortOrder to API sort_by values
  String _mapSortBy(String? sortBy, String? sortOrder) {
    if (sortBy == null) return 'relevance';

    switch (sortBy) {
      case 'price':
        return sortOrder == 'asc' ? 'price_low' : 'price_high';
      case 'rating':
        return 'rating';
      case 'name':
        return 'relevance';
      case 'total_price':
        return sortOrder == 'asc' ? 'price_low' : 'price_high';
      case 'created_at':
        return 'newest';
      default:
        return 'relevance';
    }
  }

  List<Widget> _getFilterChips() {
    final chips = <Widget>[];
    final currentTab = widget.tabController.index;

    // Show category filter for all tabs
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

    // Show gender filter for Services (0) and Salons (2) tabs
    if ((currentTab == 0 || currentTab == 2) && selectedGender != null) {
      String genderLabel;
      if (selectedGender == 'male') {
        genderLabel = '👨 Male';
      } else if (selectedGender == 'female') {
        genderLabel = '👩 Female';
      } else {
        genderLabel = '👥 Unisex';
      }

      chips.add(FilterItem(
        label: genderLabel,
        onTap: () =>
            _showBottomSheet(GenderFilterNew(selectedGender: selectedGender)),
        onClear: () => setState(() {
          selectedGender = null;
          _performSearch();
        }),
      ));
    }

    // Show price filter ONLY for Services (0) and Deals (1) tabs
    if ((currentTab == 0 || currentTab == 1) &&
        (minPrice != 100 || maxPrice != 100000)) {
      chips.add(FilterItem(
        label: 'Rs ${minPrice.toInt()} - Rs ${maxPrice.toInt()}',
        onTap: () => _showBottomSheet(const PriceRangeNew()),
        onClear: () => setState(() {
          minPrice = 100;
          maxPrice = 100000;
          _performSearch();
        }),
      ));
    }

    return chips;
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: kSecondaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kSecondaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: kPrimaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

                Expanded(
                    child: SearchField(
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

                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _performSearch,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(
                    icon: Icons.sort_rounded,
                    label: 'Sort',
                    onTap: () {
                      _showBottomSheet(SortingNew(
                        tabIndex: widget.tabController.index,
                        currentSortBy: sortBy,
                        currentSortOrder: sortOrder,
                      ));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    icon: Icons.filter_list_rounded,
                    label: 'Category',
                    onTap: () {
                      _showBottomSheet(FilterCategoriesNew(
                        selectedCategoryId: selectedCategoryId,
                      ));
                    },
                  ),
                  if (widget.tabController.index == 0 ||
                      widget.tabController.index == 1) ...[
                    const SizedBox(width: 8),
                    _buildFilterButton(
                      icon: Icons.monetization_on_rounded,
                      label: 'Price',
                      onTap: () {
                        _showBottomSheet(PriceRangeNew(
                          initialMinPrice: minPrice,
                          initialMaxPrice: maxPrice,
                        ));
                      },
                    ),
                  ],
                  if (widget.tabController.index == 0 ||
                      widget.tabController.index == 2) ...[
                    const SizedBox(width: 8),
                    _buildFilterButton(
                      icon: Icons.wc,
                      label: 'Gender',
                      onTap: () {
                        _showBottomSheet(GenderFilterNew(
                          selectedGender: selectedGender,
                        ));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Filter chips in a separate row
          if (_getFilterChips().isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _getFilterChips(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kSecondaryColor.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: widget.tabController,
                labelColor: Colors.white,
                unselectedLabelColor: kTextColor,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: kPrimaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
    );
  }
}

class FilterItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const FilterItem(
      {super.key, required this.label, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(width: 1.5, color: kPrimaryColor.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onSubmitted;

  const SearchField({Key? key, required this.controller, this.onSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSecondaryColor.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
