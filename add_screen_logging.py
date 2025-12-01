#!/usr/bin/env python3
"""
Script to add screen initialization logging to all Flutter screens
"""

screens = [
    ("SplashScreen", "lib/features/auth/presentation/screens/splash/splash_screen.dart", "StatefulWidget"),
    ("OnboardingScreen", "lib/features/auth/presentation/screens/splash/onboarding_screen.dart", "StatefulWidget"),
    ("AuthScreen", "lib/features/auth/presentation/screens/auth/auth_screen.dart", "StatefulWidget"),
    ("OtpScreen", "lib/features/auth/presentation/screens/otp/otp_screen.dart", "StatelessWidget"),
    ("VerificationScreen", "lib/features/auth/presentation/screens/verification/verification_screen.dart", "StatefulWidget"),
    ("ForgotPasswordScreen", "lib/features/auth/presentation/screens/forgot_password/forgot_password_screen.dart", "StatelessWidget"),
    ("ResetPasswordScreen", "lib/features/auth/presentation/screens/reset_password/reset_password_screen.dart", "StatefulWidget"),
    ("CompleteProfileScreen", "lib/features/auth/presentation/screens/complete_profile/complete_profile_screen.dart", "StatelessWidget"),
    ("LoginSuccessScreen", "lib/features/auth/presentation/screens/login_success/login_success_screen.dart", "StatelessWidget"),
    ("InitScreen", "lib/features/home/presentation/screens/init_screen.dart", "StatefulWidget"),
    ("HomeScreen", "lib/features/home/presentation/screens/home_screen.dart", "StatefulWidget"),
    ("SearchServiceScreenNew", "lib/features/search/presentation/screens/search_service_screen_new.dart", "StatefulWidget"),
    ("ServicesListScreen", "lib/features/home/presentation/screens/services_list_screen.dart", "StatefulWidget"),
    ("DealsListScreen", "lib/features/home/presentation/screens/deals_list_screen.dart", "StatefulWidget"),
    ("TopSalonsScreen", "lib/features/home/presentation/screens/top_salons_screen.dart", "StatefulWidget"),
    ("SalonDetailsScrollingTabsEffectB", "lib/screens/test/salon_details_scrolling_tabs_effect_b.dart", "StatefulWidget"),
    ("SalonCategoryAndServicesListByService", "lib/screens/test_scroll/salon_category_and_services_list_by_service.dart", "StatefulWidget"),
    ("SelectDateScreen", "lib/screens/test_scroll/SelectDateScreen.dart", "StatefulWidget"),
    ("SelectTimeScreen", "lib/screens/test_scroll/select_time_screen.dart", "StatefulWidget"),
    ("SelectProfessionals", "lib/screens/test_scroll/select_professionals.dart", "StatefulWidget"),
    ("ConfirmBookingScreen", "lib/screens/test_scroll/confirm_booking_screen.dart", "StatefulWidget"),
    ("MyBookings", "lib/features/bookings/presentation/screens/my_bookings.dart", "StatefulWidget"),
    ("BookingDetailsScreen", "lib/features/bookings/presentation/screens/booking_details_screen.dart", "StatelessWidget"),
    ("CartScreen", "lib/screens/cart/cart_screen.dart", "StatefulWidget"),
    ("ProfileScreen", "lib/features/profile/presentation/screens/profile_screen.dart", "StatefulWidget"),
    ("MyAccountScreen", "lib/features/profile/presentation/screens/my_account_screen.dart", "StatefulWidget"),
    ("FavouritesScreen", "lib/features/favourites/presentation/screens/favourites_screen.dart", "StatefulWidget"),
    ("NotificationsScreen", "lib/features/notifications/presentation/screens/notifications_screen.dart", "StatefulWidget"),
    ("ProductsScreen", "lib/screens/products/products_screen.dart", "StatelessWidget"),
    ("DetailsScreen", "lib/screens/details/details_screen.dart", "StatelessWidget"),
    ("ServiceDetailsScreen", "lib/screens/service_details/service_details.dart", "StatelessWidget"),
    ("CategoryDetailsFetchAPIData", "lib/screens/CategoryDetailsFetchAPIData.dart", "StatefulWidget"),
    ("SalonFetchAPIData", "lib/screens/SalonFetchAPIData.dart", "StatefulWidget"),
]

print("=" * 80)
print("SCREEN LOGGING INSTRUCTIONS")
print("=" * 80)
print(f"\nTotal Screens Found: {len(screens)}\n")

print("\n" + "=" * 80)
print("FOR EACH SCREEN, ADD THIS LOGGING:")
print("=" * 80)

for i, (name, path, widget_type) in enumerate(screens, 1):
    print(f"\n{i}. {name} ({widget_type})")
    print(f"   File: {path}")
    
    if widget_type == "StatefulWidget":
        print(f"   Add to initState():")
        print(f"   log('📱 Screen Initialized: {name} - Path: {path}');")
    else:
        print(f"   Add to build() method (first line):")
        print(f"   log('📱 Screen Rendered: {name} - Path: {path}');")
    print()

print("\n" + "=" * 80)
print("IMPORT STATEMENT (add at top of each file if not present):")
print("=" * 80)
print("import 'dart:developer';")

print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"StatefulWidget screens: {sum(1 for _, _, t in screens if t == 'StatefulWidget')}")
print(f"StatelessWidget screens: {sum(1 for _, _, t in screens if t == 'StatelessWidget')}")
print(f"Total screens: {len(screens)}")
