//import 'dart:js';
import 'package:app/screens/SalonFetchAPIData.dart';
import 'package:app/features/bookings/presentation/screens/my_bookings.dart';
import 'package:app/screens/products/products_screen.dart';
import 'package:app/screens/profile/my_account_screen.dart';
import 'package:app/features/search/presentation/screens/search_service_screen_new.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:app/screens/test_scroll/SelectDateScreen.dart';
import 'package:app/screens/test_scroll/confirm_booking_screen.dart';
import 'package:app/screens/test_scroll/salon_category_and_services_list_by_service.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/screens/test_scroll/select_time_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:app/screens/salon/salon_screen.dart';
import 'package:app/screens/service_details/service_details.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:app/screens/test/scroll_sync_tabs.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect.dart';
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';
import 'package:app/features/home/presentation/screens/top_salons_screen.dart';
import 'package:app/features/home/presentation/screens/deals_list_screen.dart';
import 'package:app/features/home/presentation/screens/services_list_screen.dart';
import 'package:app/features/home/presentation/viewmodels/services_view_model.dart';

import 'screens/CategoryDetailsFetchAPIData.dart';
import 'screens/cart/cart_screen.dart';
import 'features/auth/presentation/screens/complete_profile/complete_profile_screen.dart';
import 'screens/details/details_screen.dart';
import 'features/auth/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'features/auth/presentation/screens/verification/verification_screen.dart';
import 'features/auth/presentation/screens/reset_password/reset_password_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/home/presentation/screens/init_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_success/login_success_screen.dart';
import 'features/auth/presentation/screens/otp/otp_screen.dart';
import 'features/auth/presentation/screens/splash/splash_screen.dart';
import 'features/auth/presentation/screens/splash/onboarding_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  OnboardingScreen.routeName: (context) => const OnboardingScreen(),
  AuthScreen.routeName: (context) => const AuthScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  VerificationScreen.routeName: (context) => const VerificationScreen(),
  ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
  NotificationsScreen.routeName: (context) => const NotificationsScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  OtpScreen.routeName: (context) => const OtpScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  ProductsScreen.routeName: (context) => const ProductsScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),

  /// ServicesScreen.routeName: (context) => const ServicesScreen(),
  SalonScreen.routeName: (context) => const SalonScreen(),
  ScrollSyncTabs.routeName: (context) => const ScrollSyncTabs(),
  SalonDetailsScrollingTabsEffect.routeName: (context) =>
      const SalonDetailsScrollingTabsEffect(),
  SalonCategoryAndServicesList.routeName: (context) =>
      const SalonCategoryAndServicesList(),

  SalonDetailsScrollingTabsEffect.routeName: (context) =>
      const SalonDetailsScrollingTabsEffect(),
  SalonDetailsScrollingTabsEffectB.routeName: (context) =>
      const SalonDetailsScrollingTabsEffectB(),

  ServiceDetailsScreen.routeName: (context) => ServiceDetailsScreen(),

  SalonFetchAPIData.routeName: (context) => const SalonFetchAPIData(),

  CategoryDetailsFetchAPIData.routeName: (context) =>
      const CategoryDetailsFetchAPIData(),

  SelectProfessionals.routeName: (context) => const SelectProfessionals(),

  SelectDateScreen.routeName: (context) => const SelectDateScreen(),

  SelectTimeScreen.routeName: (context) => const SelectTimeScreen(),

  ConfirmBookingScreen.routeName: (context) => const ConfirmBookingScreen(),

  MyBookings.routeName: (context) => const MyBookings(),

  MyAccountScreen.routeName: (context) => const MyAccountScreen(),

  SearchServiceScreenNew.routeName: (context) => const SearchServiceScreenNew(),

  SalonCategoryAndServicesListByService.routeName: (context) =>
      const SalonCategoryAndServicesListByService(),

  TopSalonsScreen.routeName: (context) => const TopSalonsScreen(),

  DealsListScreen.routeName: (context) => const DealsListScreen(),

  '/services-list-men': (context) =>
      const ServicesListScreen(gender: ServiceGender.men),
  '/services-list-women': (context) =>
      const ServicesListScreen(gender: ServiceGender.women),
};
