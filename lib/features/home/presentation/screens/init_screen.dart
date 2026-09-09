import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app/services/deep_link_service.dart';
import '../../../../constants.dart';
import '../../../../components/inactive_user_banner.dart';
import 'home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/screens/search_service_screen_new.dart';
import '../../../favourites/presentation/screens/favourites_screen.dart';
import '../../../bookings/presentation/screens/my_bookings.dart';
import '../../../../presentation/viewmodels/favourites/favourites_view_model.dart';
import '../../../../presentation/viewmodels/bookings/bookings_view_model.dart';
import '../../../profile/presentation/viewmodels/profile_view_model.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  static String routeName = "/";

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;
  final GlobalKey<_FavouritesScreenWrapperState> _favouritesKey = GlobalKey();
  final GlobalKey<_BookingsScreenWrapperState> _bookingsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load user profile data to check if user is inactive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
      // Handle any deep link that arrived before the UI was ready
      DeepLinkService.handlePendingLink();
    });
  }

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });

    // Clear state and trigger API refresh when switching to favourites or bookings tab
    if (index == 2) {
      // Switched to favourites tab - clear state and refresh
      final favouritesViewModel = context.read<FavouritesViewModel>();
      favouritesViewModel
          .refresh(); // This clears state internally with refresh=true
      _favouritesKey.currentState?.refreshData();
    } else if (index == 3) {
      // Switched to bookings tab - clear state and refresh
      final bookingsViewModel = context.read<BookingsViewModel>();
      bookingsViewModel
          .refresh(); // This clears state internally with refresh=true
      _bookingsKey.currentState?.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const InactiveUserBanner(),
          Expanded(
            child: IndexedStack(
              index: currentSelectedIndex,
              children: [
                HomeScreen(isActiveTab: currentSelectedIndex == 0),
                const SearchServiceScreenNew(),
                _FavouritesScreenWrapper(key: _favouritesKey),
                _BookingsScreenWrapper(key: _bookingsKey),
                const ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              onTap: updateCurrentIndex,
              currentIndex: currentSelectedIndex,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: inActiveIconColor,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/Shop Icon.svg",
                    // "assets/icons/home_icon_3.svg",
                    colorFilter: const ColorFilter.mode(
                      inActiveIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    // "assets/icons/icons8_home.svg",
                    "assets/icons/Shop Icon.svg",
                    colorFilter: const ColorFilter.mode(
                      kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/search_icon.svg",
                    // "assets/icons/home_icon_3.svg",
                    colorFilter: const ColorFilter.mode(
                      inActiveIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/icons/search_icon.svg",
                    colorFilter: const ColorFilter.mode(
                      kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/Heart Icon.svg",
                    colorFilter: const ColorFilter.mode(
                      inActiveIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/icons/Heart Icon.svg",
                    colorFilter: const ColorFilter.mode(
                      kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: "Favourites",
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    //calendar-svg
                    "assets/icons/calendar-svg.svg",
                    // "assets/icons/Chat bubble Icon.svg",
                    colorFilter: const ColorFilter.mode(
                      inActiveIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/icons/calendar-svg.svg",
                    colorFilter: const ColorFilter.mode(
                      kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: "Bookings",
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/User Icon.svg",
                    colorFilter: const ColorFilter.mode(
                      inActiveIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/icons/User Icon.svg",
                    colorFilter: const ColorFilter.mode(
                      kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Wrapper for FavouritesScreen to enable refresh on tab change
class _FavouritesScreenWrapper extends StatefulWidget {
  const _FavouritesScreenWrapper({super.key});

  @override
  State<_FavouritesScreenWrapper> createState() =>
      _FavouritesScreenWrapperState();
}

class _FavouritesScreenWrapperState extends State<_FavouritesScreenWrapper> {
  int _refreshKey = 0;

  void refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FavouritesScreen(key: ValueKey(_refreshKey));
  }
}

// Wrapper for MyBookings to enable refresh on tab change
class _BookingsScreenWrapper extends StatefulWidget {
  const _BookingsScreenWrapper({super.key});

  @override
  State<_BookingsScreenWrapper> createState() => _BookingsScreenWrapperState();
}

class _BookingsScreenWrapperState extends State<_BookingsScreenWrapper> {
  int _refreshKey = 0;

  void refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyBookings(key: ValueKey(_refreshKey));
  }
}
