import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/models/SalonDetailApiResponse.dart'
    as ApiResponse; // Use alias to avoid conflicts
import 'package:app/models/HomePageResponse.dart' as HomePage;
import 'package:visibility_detector/visibility_detector.dart';
import '../../api_services/salon_detail_api.dart';
import '../../api_services/favourite_api.dart';
import '../../components/ratings.dart';
import '../../constants.dart';
import '../../helper/ReviewCount.dart';
import 'package:app/models/salon_detail_models.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../providers/cart_provider.dart';
import '../test_scroll/select_professionals.dart';
import '../../features/home/presentation/widgets/deals_dashboard.dart';
import '../../features/home/presentation/widgets/services_dashboard.dart';
import '../../components/cart_bottom_bar.dart';
import '../../utils/cart_modal_helper.dart';
import '../../features/auth/utils/auth_manager.dart';

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
  // State fields (restored minimal set)
  TabController? _tabController;
  final AutoScrollController _autoScrollController = AutoScrollController();
  TabController? _serviceCategoryTabController;
  int? _selectedCategoryId; // Selected category for chip-based filtering

  // Dynamic top-level sections (order matters)
  List<String> _topSections = []; // values: 'services','deals','staff','about'

  Map<int, List<HomePage.Service>> categorizedServices =
      {}; // API returns HomePage.Service
  Map<int, bool> isCategoryLoading = {};
  Map<int, String?> categoryErrors = {};

  bool isLoadingServices = false;
  bool isLoadingDeals = false;
  bool isLoadingStaff = false;

  List<HomePage.Deal> salonDeals = []; // API returns HomePage.Deal
  List<ApiResponse.Staff> salonStaff = []; // API returns ApiResponse.Staff

  ApiResponse.SalonData? salonDetailsss;

  // Track visibility fraction (0..1) for each top-level section.
  // This lets us reliably pick the most-visible section while scrolling.
  final Map<int, double> _visibleItems = {};

  bool isFavourite = false;
  bool isTogglingFavourite = false;

  // Error and loading state for initial load
  bool hasError = false;
  String? errorMessage;
  int? errorStatusCode;

  final SalonDetailAPI _salonApi = SalonDetailAPI();

  String _resolveAboutText() {
    final direct = salonDetailsss?.about?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final sections = salonDetailsss?.sections;
    if (sections == null || sections.isEmpty) return '';

    ApiResponse.Section? aboutSection;
    for (final s in sections) {
      if (s.type == '5') {
        aboutSection = s;
        break;
      }
    }

    final data = aboutSection?.data;
    if (data is List<ApiResponse.About> && data.isNotEmpty) {
      final desc = data.first.desc?.toString().trim();
      if (desc != null && desc.isNotEmpty) return desc;
    }

    return '';
  }

  bool _hasReviewsInSections() {
    final sections = salonDetailsss?.sections;
    if (sections == null || sections.isEmpty) return false;
    try {
      return sections.any((s) =>
          s.type == '3' && (s.data is List) && (s.data as List).isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  // Simple loading state widget used across this screen
  Widget _buildLoadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Small helper to build the tab used in the SliverAppBar bottom
  Widget _buildEnhancedTab(String label, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  // Map API SalonData -> local Salon model used by DealsCard
  Salon _salonDataToSalon(ApiResponse.SalonData data) {
    return Salon(
      id: data.id,
      name: data.name,
      logo: data.logo,
      location:
          null, // Location types don't match - ApiResponse.Location vs salon_detail_models.Location
      about: data.about,
      isFavourite: data.isFavourite,
    );
  }

  Future<void> _toggleFavourite() async {
    if (salonDetailsss == null) return;
    setState(() => isTogglingFavourite = true);
    try {
      final favApi = FavouriteAPI();
      final res = await favApi.toggleFavourite(
          shareId: salonDetailsss!.id.toString(), shareType: 'salon');
      if (res['success'] == true) {
        setState(() {
          isFavourite = res['isFavourite'] == true;
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => isTogglingFavourite = false);
    }
  }

  // Load salon details + deals + staff and initialize category controllers
  Future<void> loadJson(String salonId) async {
    setState(() {
      hasError = false;
      errorMessage = null;
      errorStatusCode = null;
      isLoadingServices = true;
      isLoadingDeals = true;
      isLoadingStaff = true;
    });

    try {
      final data = await _salonApi.fetchSalonDetailData(salonId);
      if (data == null) {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to load salon details';
        });
        return;
      }

      // Populate basic data
      setState(() {
        salonDetailsss = data;
        isFavourite = data.isFavourite ?? false;
      });

      // Log detailed salon data
      log('');
      log('═══════════════════════════════════════════════════════════════');
      log('✅ SALON DATA LOADED SUCCESSFULLY');
      log('═══════════════════════════════════════════════════════════════');
      log('📊 Salon Details:');
      log('   ├─ ID: ${data.id}');
      log('   ├─ Name: ${data.name}');
      log('   ├─ Gender: ${data.gender}');
      log('   ├─ Type: ${data.type}');
      log('   ├─ Kind: ${data.kind}');
      log('   ├─ Star Rating: ${data.star}');
      log('   ├─ Review Count: ${data.review_count}');
      log('   ├─ Is Favourite: ${data.isFavourite}');
      log('   ├─ Images Count: ${data.images.length}');
      if (data.images.isNotEmpty) {
        log('   │  └─ First Image: ${data.images.first}');
      }
      log('   ├─ Logo: ${data.logo}');
      log('   ├─ Location: ${data.location?.address}');
      log('   ├─ Active Days: ${data.activeDays?.length ?? 0}');
      log('   ├─ Categories: ${data.categories?.length ?? 0}');
      if (data.categories != null) {
        for (var cat in data.categories!) {
          log('   │  ├─ ${cat.name} (ID: ${cat.id})');
        }
      }
      log('   ├─ Sections: ${data.sections?.length ?? 0}');
      final aboutText = data.about;
      if (aboutText != null && aboutText.isNotEmpty) {
        final preview = aboutText.length > 100
            ? '${aboutText.substring(0, 100)}...'
            : aboutText;
        log('   ├─ About: $preview');
      }
      log('   ├─ Min Booking Time: ${data.minBookingTime}');
      log('   ├─ Max Booking Time: ${data.maxBookingTime}');
      log('   ├─ Policy: ${data.policy != null ? "Present" : "Not set"}');
      log('   ├─ Created At: ${data.createdAt}');
      log('   ├─ Facebook: ${data.fackebook}');
      log('   ├─ Instagram: ${data.instagram}');
      log('   ├─ Twitter: ${data.twitter}');
      log('   └─ LinkedIn: ${data.linkedin}');
      log('═══════════════════════════════════════════════════════════════');
      log('');

      // Update visible sections after initial salon data load
      _updateTopSections();

      // Initialize category tab controller
      final categories = salonDetailsss?.categories ?? [];
      if (categories.isNotEmpty) {
        _serviceCategoryTabController =
            TabController(length: categories.length, vsync: this);
        // Set first category as selected
        _selectedCategoryId = categories.first.id;
        // Kick off fetching services for each category
        for (final cat in categories) {
          _fetchServicesForCategory(salonId, cat.id);
        }
      }

      // Fetch deals and staff
      try {
        final deals = await _salonApi.fetchSalonDeals(salonId);
        final staff = await _salonApi.fetchSalonStaff(salonId);
        setState(() {
          salonDeals = deals;
          salonStaff = staff;
          isLoadingDeals = false;
          isLoadingStaff = false;
        });
        // Update top sections after deals/staff loaded
        _updateTopSections();
      } catch (e) {
        setState(() {
          isLoadingDeals = false;
          isLoadingStaff = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => isLoadingServices = false);
    }
  }

  /// Fetch services for a specific category (on-demand) and cache results
  Future<void> _fetchServicesForCategory(String salonId, int categoryId,
      {bool force = false}) async {
    if (!mounted) return;

    // Avoid duplicate fetches unless forced
    if (isCategoryLoading[categoryId] == true && !force) return;

    setState(() {
      isCategoryLoading[categoryId] = true;
      categoryErrors[categoryId] = null;
    });

    final SalonDetailAPI api = SalonDetailAPI();
    try {
      final dynamic response =
          await api.fetchSalonServices(salonId, categoryId: categoryId);

      List<HomePage.Service> services = []; // API returns HomePage.Service
      if (response == null) {
        services = [];
      } else if (response is ServiceCategoryResponse) {
        // No prefix needed - defined in salon_detail_api.dart
        services = response.services;
      } else if (response is List<HomePage.Service>) {
        services = response;
      } else if (response is Map && response['services'] != null) {
        services = List<HomePage.Service>.from(response['services']);
      } else {
        try {
          services = List<HomePage.Service>.from(response as List);
        } catch (_) {
          services = [];
        }
      }

      if (!mounted) return;
      setState(() {
        categorizedServices[categoryId] = services;
        isCategoryLoading[categoryId] = false;
        categoryErrors[categoryId] = null;
      });
      // Update visible top sections since services data changed
      _updateTopSections();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isCategoryLoading[categoryId] = false;
        categoryErrors[categoryId] = e.toString();
      });
    }
  }

  List<String> _computeTopSections() {
    final List<String> sections = [];

    // Services: show if any category has services or still loading or categories exist
    final bool hasServiceContent =
        categorizedServices.values.any((list) => list.isNotEmpty);
    if (hasServiceContent ||
        isLoadingServices ||
        (salonDetailsss?.categories?.isNotEmpty ?? false)) {
      sections.add('services');
    }

    // Deals
    if (salonDeals.isNotEmpty || isLoadingDeals) sections.add('deals');

    // Staff
    if (salonStaff.isNotEmpty || isLoadingStaff) sections.add('staff');

    // About & Reviews
    final bool hasAbout = _resolveAboutText().isNotEmpty;
    final bool hasReviews = _hasReviewsInSections();
    if (hasAbout || hasReviews) sections.add('about');

    return sections;
  }

  void _updateTopSections() {
    final newSections = _computeTopSections();
    if (listEquals(newSections, _topSections)) return;

    final previousIndex = _tabController?.index ?? 0;
    _topSections = newSections;

    // Dispose existing controller and create a new one if needed
    _tabController?.dispose();
    if (_topSections.isNotEmpty) {
      _tabController = TabController(length: _topSections.length, vsync: this);
      // preserve previous index when possible
      final newIndex = previousIndex.clamp(0, _topSections.length - 1);
      _tabController!.index = newIndex;
    } else {
      _tabController = null;
    }

    if (mounted) setState(() {});
  }

  void _showCartModal(BuildContext context, CartProvider cart) {
    CartModalHelper.showCartModal(
      context,
      onProceed: _proceedToBooking,
      proceedButtonText: 'Proceed to Booking',
    );
  }

  void _proceedToBooking() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add services or deals to cart first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      SelectProfessionals.routeName,
      arguments: {
        'cartItems': cartProvider.items,
        'salonName': salonDetailsss?.name,
        'salonImage': salonDetailsss?.logo,
        'salonAddress': salonDetailsss?.location?.address,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      log('');
      log('═══════════════════════════════════════════════════════════════');
      log('🏪 ENTERING SALON DETAILS SCREEN');
      log('═══════════════════════════════════════════════════════════════');
      log('📦 Route Arguments: $args');
      log('📦 Arguments Type: ${args.runtimeType}');

      String? salonId;
      if (args is String) {
        salonId = args;
        log('✅ Parsed as String: $salonId');
      } else if (args is Map && args['id'] != null) {
        salonId = args['id'].toString();
        log('✅ Parsed from Map[\'id\']: $salonId');
      } else if (args != null) {
        salonId = args.toString();
        log('✅ Parsed via toString(): $salonId');
      }

      if (salonId != null && salonId.isNotEmpty) {
        log('🔄 Loading salon data for ID: $salonId');
        log('═══════════════════════════════════════════════════════════════');
        log('');
        loadJson(salonId);
      } else {
        log('❌ No valid salon ID found in arguments');
        log('═══════════════════════════════════════════════════════════════');
        log('');
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _autoScrollController.dispose();
    _serviceCategoryTabController?.dispose();
    super.dispose();
  }

  bool _isAppBarExpanded() {
    if (!_autoScrollController.hasClients) return false;
    return _autoScrollController.offset >
        (MediaQuery.of(context).size.height / 1.6 - kToolbarHeight);
  }

  Future _scrollToIndex(int index) async {
    log('🎯 Scrolling to section $index: ${_getSectionTitle(index)}');
    try {
      await _autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
        duration: const Duration(milliseconds: 600),
      );
      // Update tab selection with smooth animation
      if ((_tabController?.index ?? -1) != index) {
        _tabController?.animateTo(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    } catch (e) {
      log('❌ Error scrolling to index $index: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (salonDetailsss?.id == null) return;

    // Check if user is authenticated
    final token = await AuthManager.getToken();

    if (token == null) {
      // Show sign-in dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Required'),
            content: const Text(
              'Please sign in to add salons to your favorites.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to sign in screen
                  Navigator.pushNamed(context, '/signin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign In'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Toggle favorite status
    final previousStatus = isFavourite;

    // Optimistically update UI
    setState(() {
      isFavourite = !previousStatus;
    });

    // Call API
    final newStatus =
        await _salonApi.toggleFavorite(salonDetailsss!.id!, token);

    if (newStatus != null) {
      // Update with actual status from server
      setState(() {
        isFavourite = newStatus;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                newStatus ? 'Added to favorites' : 'Removed from favorites',
              ),
            ],
          ),
          backgroundColor: newStatus ? Colors.green : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Revert on error
      setState(() {
        isFavourite = previousStatus;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to update favorite status'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
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

  // <CHANGE> Enhanced SliverAppBar with glassmorphism and premium typography
  Widget _buildSliverAppbar(BuildContext context) {
    // TODOs:
    // - Accessibility: add `Semantics` labels to the back button, cart button and favorite button.
    // - Analytics: emit events for tab taps and hero image impressions.
    // - Performance: replace `Image.network` with a cached image widget and placeholder/error UI.
    // - Behavior: ensure cart modal state is cleared on Navigator.pop and avoid memory leaks.

    if (salonDetailsss == null) return const SliverToBoxAdapter();
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      snap: false,
      expandedHeight: size.height * 0.38,
      elevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        titlePadding: EdgeInsets.zero,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image with shader mask for fade effect
            if (salonDetailsss?.images != null &&
                salonDetailsss!.images.isNotEmpty)
              Image.network(
                salonDetailsss!.images.first,
                fit: BoxFit.fill,
              )
            else
              Container(color: Colors.grey[200]),

            // Multi-stop gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Glassmorphism back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Favorite button (top right)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleFavorite,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavourite ? Colors.red : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Enhanced chip-based navigation (matching services section style)
      bottom: _topSections.isEmpty || _tabController == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _tabController!,
                  builder: (context, _) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: List.generate(_topSections.length, (index) {
                          final section = _topSections[index];
                          final label = (section == 'services')
                              ? 'Services'
                              : (section == 'deals')
                                  ? 'Deals'
                                  : (section == 'staff')
                                      ? 'Staff'
                                      : 'About';
                          final isSelected = _tabController?.index == index;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(label),
                              onSelected: (selected) async {
                                if (selected) {
                                  await _scrollToIndex(index);
                                }
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor: kPrimaryColor,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 0 : 1,
                                ),
                              ),
                              elevation: isSelected ? 2 : 0,
                              shadowColor: kPrimaryColor.withOpacity(0.3),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
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
                  if (imageList == null || index >= imageList.length) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  }
                  return Center(
                    child: Image.network(
                      imageList[index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  );
                },
              ),
            ),
            if (imageList != null && imageList.isNotEmpty)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16.0),
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: imageList.length,
                    effect: WormEffect(
                      dotWidth: 12.0,
                      dotHeight: 12.0,
                      spacing: 8.0,
                      dotColor: Colors.white.withOpacity(0.4),
                      activeDotColor: kPrimaryColor,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 72,
              top: 32,
              child: Consumer<CartProvider>(
                builder: (context, cart, child) => Container(
                  decoration: const BoxDecoration(
                      color: whiteColor, shape: BoxShape.circle),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        color: kPrimaryColor,
                        tooltip: 'View Cart',
                        onPressed: () => _showCartModal(context, cart),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
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
                width: MediaQuery.of(context).size.width * 0.45,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -6),
                      blurRadius: 6,
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
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
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
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
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
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
                'For ${salonDetailsss?.gender ?? "All"}',
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Ratings(rating: salonDetailsss?.star ?? 0),
              ReviewCount(reviews: salonDetailsss?.review_count ?? 0),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Divider(thickness: 1, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
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
              const SizedBox(height: 2),
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
                    (_resolveAboutText().isNotEmpty
                            ? _resolveAboutText()
                            : "No description available")
                        .toString(),
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final items = _buildSectionItems(context, index);
          // If there are no items for this section, hide the whole section
          if (items.isEmpty) return const SizedBox.shrink();

          return VisibilityDetector(
            key: Key('section_$index'),
            onVisibilityChanged: (info) {
              // Keep lightweight state: store fractional visibility and choose
              // the most-visible section as the active top tab.
              final fraction = info.visibleFraction;
              if (!mounted) return;
              setState(() {
                if (fraction <= 0.01) {
                  _visibleItems.remove(index);
                } else {
                  _visibleItems[index] = fraction;
                }
              });
              _calculateIndexAndJumpToTab();
            },
            child: _wrapScrollTag(
              index: index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  bottom: index < (_topSections.length - 1) ? 20 : 0,
                ),
                decoration: BoxDecoration(
                  color: kScreenBg,
                  borderRadius: index < (_topSections.length - 1)
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )
                      : null,
                  boxShadow: index < (_topSections.length - 1)
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCategoryTitle(context, _getSectionTitle(index)),
                    ...items,
                    if (index < (_topSections.length - 1))
                      Container(
                        height: 24,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kScreenBg,
                              kScreenBg.withOpacity(0.7),
                              kScreenBg.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: _topSections.isEmpty ? 0 : _topSections.length,
      ),
    );
  }

  String _getSectionTitle(int index) {
    if (index < 0 || index >= _topSections.length) return '';
    switch (_topSections[index]) {
      case 'services':
        return 'Services';
      case 'deals':
        return 'Deals';
      case 'staff':
        return 'Staff';
      case 'about':
        return 'About & Reviews';
      default:
        return '';
    }
  }

  List<Widget> _buildSectionItems(BuildContext context, int index) {
    if (index < 0 || index >= _topSections.length) return const [];

    switch (_topSections[index]) {
      case 'services': // Services - Show in tab view
        // Show initial loading
        if (isLoadingServices && categorizedServices.isEmpty) {
          return [_buildLoadingState('Loading services...')];
        }

        // Hide section entirely if no categories
        if (categorizedServices.isEmpty && !isLoadingServices) {
          return [];
        }

        // Build tab view for service categories
        return [_buildServiceCategoryTabs()];

      case 'deals': // Deals
        if (isLoadingDeals) {
          return [_buildLoadingState('Loading deals...')];
        }
        if (salonDeals.isEmpty) {
          return [];
        }
        // Use horizontal scrollable list like home screen
        return [
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              itemCount: salonDeals.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildDealsItem(context, salonDeals[index]);
              },
            ),
          ),
        ];

      case 'staff': // Staff
        if (isLoadingStaff) {
          return [_buildLoadingState('Loading team members...')];
        }
        if (salonStaff.isEmpty) {
          return [
            _buildEmptyState(
              icon: Icons.people_outline,
              title: 'No Staff Information',
              message:
                  'Team member details are not available.\nPlease contact the salon directly.',
            )
          ];
        }
        return [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: salonStaff.length,
              itemBuilder: (context, index) {
                return _buildSpecialistItem(context, salonStaff[index]);
              },
            ),
          )
        ];

      case 'about': // About & Reviews
        List<Widget> aboutWidgets = [];

        // Add spacing before about section
        aboutWidgets.add(const SizedBox(height: 12));

        // Add about section if available (root `about` or section type '5')
        if (_resolveAboutText().isNotEmpty || _hasReviewsInSections()) {
          aboutWidgets.add(_buildAboutInfo(context));
        }

        // Note: Reviews are now shown within _buildAboutInfo using the new API structure
        // The API returns reviews directly in salonDetailsss?.sections with type '3'

        if (aboutWidgets.isEmpty) {
          return [
            _buildEmptyState(
              icon: Icons.info_outline,
              title: 'No Information Available',
              message: 'Details about this salon are not available yet.',
            )
          ];
        }

        return aboutWidgets;

      default:
        return [Container()];
    }
  }

  Widget _buildAboutInfo(BuildContext context) {
    final aboutText = _resolveAboutText();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Us Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: kPrimaryColor.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  aboutText,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Policy Section
          if (salonDetailsss?.policy != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.policy_outlined,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Policy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    salonDetailsss!.policy!,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Opening Hours Section
          if (salonDetailsss?.activeDays != null &&
              salonDetailsss!.activeDays!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.green[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Opening Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...salonDetailsss!.activeDays!
                      .map((day) => Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  day.day ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                Text(
                                  '${day.openingTime ?? ''} - ${day.closingTime ?? ''}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ],

          // Reviews Section (using new API structure)
          if (salonDetailsss?.sections != null) ..._buildReviewsSection(),
        ],
      ),
    );
  }

  List<Widget> _buildReviewsSection() {
    final reviewSection = salonDetailsss?.sections?.firstWhere(
      (section) => section.type == '3',
      orElse: () => ApiResponse.Section(type: '3', data: [], name: ''),
    );

    if (reviewSection?.data == null || reviewSection!.data!.isEmpty) {
      return [];
    }

    return [
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.purple.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.1),
                        Colors.purple.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reviewSection.data!.length} ${reviewSection.data!.length == 1 ? 'review' : 'reviews'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...reviewSection.data!.map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSalonReview(context, review),
                )),
          ],
        ),
      ),
    ];
  }

  Widget _buildServiceCategoryTabs() {
    final categories = salonDetailsss?.categories ?? [];
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Category chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat.name),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryId = cat.id;
                          });
                        }
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: kPrimaryColor,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? kPrimaryColor : Colors.grey[300]!,
                          width: isSelected ? 0 : 1,
                        ),
                      ),
                      elevation: isSelected ? 2 : 0,
                      shadowColor: kPrimaryColor.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Horizontal scrollable services based on selected category
          Builder(
            builder: (context) {
              if (_selectedCategoryId == null) {
                return const SizedBox.shrink();
              }

              final services = categorizedServices[_selectedCategoryId] ?? [];
              final loading = isCategoryLoading[_selectedCategoryId] == true;
              final error = categoryErrors[_selectedCategoryId];
              final salonIdStr = salonDetailsss?.id?.toString() ?? '';

              if (loading) {
                return Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: kPrimaryColor),
                      SizedBox(height: 12),
                      Text('Loading services...'),
                    ],
                  ),
                );
              }

              if (error != null) {
                return Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error loading services:\n$error',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _fetchServicesForCategory(
                              salonIdStr, _selectedCategoryId!,
                              force: true),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (services.isEmpty) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(
                    'No services available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return _buildHorizontalServiceCard(
                        context, services[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTitle(BuildContext context, String name) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          left: const BorderSide(
            color: kPrimaryColor,
            width: 4,
          ),
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.15),
                  kPrimaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getSectionIcon(name),
              color: kPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'services':
        return Icons.content_cut_rounded;
      case 'deals':
        return Icons.local_offer_rounded;
      case 'staff':
        return Icons.people_rounded;
      case 'about & reviews':
        return Icons.info_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildSalonReview(BuildContext context, ApiResponse.Review review) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ReviewCard(
        review: review,
      ),
    );
  }

  Widget _buildDealsItem(BuildContext context, HomePage.Deal deal) {
    if (salonDetailsss == null) return const SizedBox.shrink();

    return DealsCard(
      title: deal.name ?? "",
      price: deal.totalPrice ?? deal.price ?? 0,
      deal: deal,
      services: deal.services != null
          ? deal.services!.map((s) => s.name).join(' • ')
          : '',
      discountValue: deal.discountValue ?? 0,
      discountType: deal.discountType ?? "",
      salon: _salonDataToSalon(salonDetailsss!),
      image: deal.image ?? "",
      width: 320,
    );
  }

  Widget _buildHorizontalServiceCard(
      BuildContext context, HomePage.Service service) {
    if (salonDetailsss == null) return const SizedBox.shrink();

    // Convert ApiResponse.SalonData to HomePage.Salon for ServicesCard
    final salonForCard = HomePage.Salon(
      id: salonDetailsss!.id,
      name: salonDetailsss!.name,
      image: salonDetailsss!.logo,
      address: salonDetailsss!.location?.address,
    );

    return ServicesCard(
      service: service,
      title: service.name ?? 'No Title',
      image: "",
      salon: salonForCard,
      desc: service.shortDescription ?? service.name ?? '',
      width: 320,
    );
  }

  Widget _buildSpecialistItem(BuildContext context, ApiResponse.Staff staff) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(staff.image ?? 'https://i.pravatar.cc/300'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staff.name.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              staff.experience ?? 'Specialist',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _calculateIndexAndJumpToTab() {
    if (_visibleItems.isEmpty) return;
    final controller = _tabController;
    if (controller == null) return;

    // Pick the most-visible section (highest visibleFraction).
    int bestIndex = -1;
    double bestFraction = -1;
    _visibleItems.forEach((index, fraction) {
      if (index < 0 || index >= controller.length) return;
      if (fraction > bestFraction) {
        bestFraction = fraction;
        bestIndex = index;
      }
    });

    if (bestIndex != -1 && controller.index != bestIndex) {
      controller.animateTo(bestIndex);
    }
  }

  Widget _buildShimmer() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          snap: false,
          expandedHeight: MediaQuery.of(context).size.height / 2.2,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      width: 200,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 150,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (index == 0)
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
                    else if (index == 1)
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
                    else
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
            childCount: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    String displayMessage = 'Unable to load salon details';
    IconData errorIcon = Icons.error_outline;
    Color iconColor = Colors.orange;

    if (errorStatusCode == 401) {
      displayMessage = 'Authentication Required';
      errorIcon = Icons.lock_outline;
      iconColor = Colors.blue;
    } else if (errorStatusCode == 403) {
      displayMessage = 'Access Denied';
      errorIcon = Icons.block;
      iconColor = Colors.red;
    } else if (errorStatusCode == 404) {
      displayMessage = 'Salon Not Found';
      errorIcon = Icons.search_off;
      iconColor = Colors.grey;
    } else if (errorStatusCode == 500) {
      displayMessage = 'Server Error';
      errorIcon = Icons.cloud_off_outlined;
      iconColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Salon Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorIcon,
                  size: 80,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                displayMessage,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorStatusCode == 401
                    ? 'Please sign in to view this salon\'s details'
                    : 'We\'re having trouble loading this salon.\nPlease try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        hasError = false;
                        errorMessage = null;
                        errorStatusCode = null;
                        salonDetailsss = null;
                      });
                      final args = ModalRoute.of(context)?.settings.arguments;
                      if (args != null) {
                        loadJson(args.toString());
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 24),
                ExpansionTile(
                  title: Text(
                    'Error Details',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (hasError) {
      return _buildErrorState();
    }

    return Scaffold(
      body: Stack(
        children: [
          salonDetailsss == null
              ? _buildShimmer()
              : CustomScrollView(
                  controller: _autoScrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: <Widget>[
                    _buildSliverAppbar(context),
                    // Salon info section on white background
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Salon name
                            Text(
                              (salonDetailsss?.name ?? '').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            // Rating and location
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                if (salonDetailsss?.star != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${salonDetailsss!.star}.0',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (salonDetailsss?.review_count !=
                                                null &&
                                            salonDetailsss!.review_count! >
                                                0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${salonDetailsss!.review_count})',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                if (salonDetailsss?.location?.address != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 12,
                                          color: Colors.grey[700],
                                        ),
                                        const SizedBox(width: 4),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                          ),
                                          child: Text(
                                            salonDetailsss!.location?.address ??
                                                '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                    _buildServiceCategoryBody(),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CartBottomBar(
              onProceed: _proceedToBooking,
              buttonText: 'View Cart',
              proceedButtonText: 'Proceed to Booking',
              buttonColor: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Empty State Widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: kPrimaryColor),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReviewCard extends StatelessWidget {
  final ApiResponse.Review review;
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
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
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
