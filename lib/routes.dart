//import 'dart:js';
import 'package:app/screens/HomeFetchAPIData.dart';
import 'package:app/screens/SalonFetchAPIData.dart';
import 'package:app/screens/history_bookings/my_bookings.dart';
import 'package:app/screens/products/products_screen.dart';
import 'package:app/screens/profile/my_account_screen.dart';
import 'package:app/screens/search_final/search_service_screen_new.dart';
import 'package:app/screens/sign_in/sign_in_screen_b.dart';
import 'package:app/screens/test_scroll/SelectDateScreen.dart';
import 'package:app/screens/test_scroll/confirm_booking_screen.dart';
import 'package:app/screens/test_scroll/salon_category_and_services_list_by_service.dart';
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/screens/test_scroll/select_time_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:app/screens/products/products_screen.dart';
import 'package:app/screens/salon/salon_screen.dart';
import 'package:app/screens/service_details/service_details.dart';
import 'package:app/screens/services/services_screen.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:app/screens/test/scroll_sync_tabs.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect.dart';
import 'package:app/screens/test_scroll/salon_category_and_services_list.dart';

import 'screens/CategoryDetailsFetchAPIData.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/complete_profile/complete_profile_screen.dart';
import 'screens/details/details_screen.dart';
import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/init_screen.dart';
import 'screens/login_success/login_success_screen.dart';
import 'screens/otp/otp_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash/splash_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
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
  SalonDetailsScrollingTabsEffect.routeName: (context) => const SalonDetailsScrollingTabsEffect(),
  SalonCategoryAndServicesList.routeName: (context) => const SalonCategoryAndServicesList(),

  SalonDetailsScrollingTabsEffect.routeName: (context) =>  SalonDetailsScrollingTabsEffect(),
  SalonDetailsScrollingTabsEffectB.routeName: (context) =>  SalonDetailsScrollingTabsEffectB(),

  ServiceDetailsScreen.routeName: (context) =>  ServiceDetailsScreen(),

  HomeFetchAPIData.routeName: (context) =>  HomeFetchAPIData(),
  SalonFetchAPIData.routeName: (context) =>  SalonFetchAPIData(),

  CategoryDetailsFetchAPIData.routeName: (context) =>  CategoryDetailsFetchAPIData(),


  SignInScreenB.routeName: (context) =>  SignInScreenB(),

  SelectProfessionals.routeName: (context) =>  SelectProfessionals(),

  SelectDateScreen.routeName: (context) =>  SelectDateScreen(),

  SelectTimeScreen.routeName: (context) =>  SelectTimeScreen(),

  ConfirmBookingScreen.routeName: (context) =>  ConfirmBookingScreen(),

  MyBookings.routeName: (context) =>  MyBookings(),

  MyAccountScreen.routeName: (context) =>  MyAccountScreen(),

  SearchServiceScreenNew.routeName: (context) =>  SearchServiceScreenNew(),

  SalonCategoryAndServicesListByService.routeName: (context) =>  SalonCategoryAndServicesListByService(),

};
