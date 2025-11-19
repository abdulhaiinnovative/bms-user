# API Authentication Status

## ✅ Converted to Unauthorized (Public APIs - No Auth Required)

These APIs have been converted to use regular `http` package without authentication:

### Feature APIs
1. **social_auth_api.dart** - `/features/auth/data/datasources/`
   - `checkUserIsAlreadyRegistered` - Check if user exists (social auth)
   - `completeProfile` - Complete user profile after social login
   
2. **home_screen_api.dart** - `/features/home/data/services/`
   - `fetchHomePageData` - Get home page data (public content)

### General APIs
3. **salon_detail_api.dart** - `/api_services/`
   - `fetchSalonDetailData` - Get salon details (public data)

4. **salon_services_categorized_api.dart** - `/api_services/`
   - `fetchAllServicesAndDealsCategorizedData` - Get categorized services

5. **CategoryDetailsAPI.dart** - `/api_services/`
   - `fetchCategoryData` - Get services by category

6. **search_salon_api.dart** - `/screens/search_final/`
   - `search` - Search for salons, services, deals (public search)

7. **filter_categories_new.dart** - `/screens/search_final/`
   - `fetchCategories` - Get categories for filtering

## 🔒 Kept Protected (Require Authentication)

These APIs still use `ProtectedHttpClient` and require user authentication:

1. **favourite_api.dart** - `/api_services/`
   - `toggleFavourite` - Add/remove items from user's favorites
   - **Requires Auth**: User-specific favorites

2. **my_account_api.dart** - `/api_services/`
   - User account operations
   - **Requires Auth**: Personal account data

3. **MyBookingsAPI.dart** - `/api_services/`
   - `fetchBookings` - Get user's bookings
   - **Requires Auth**: User-specific booking history

4. **BookingService.dart** - `/api_services/`
   - `createBooking` - Create new booking
   - **Requires Auth**: User must be authenticated to book

5. **ProfileUpdateAPI.dart** - `/api_services/`
   - `updateProfile` - Update user profile
   - **Requires Auth**: User profile modifications

6. **auth_service_api.dart** - `/features/auth/data/datasources/`
   - Uses Dio with `AuthInterceptor` and `requiresAuth` flag
   - Already properly configured for both auth and non-auth endpoints

## 📋 Summary

- **Unauthorized APIs**: 7 APIs converted to use regular HTTP
- **Protected APIs**: 5 APIs kept with authentication
- **Auth Service**: 1 API using Dio with flexible auth control

## 🎯 Benefits

1. **Performance**: Public APIs no longer add authentication overhead
2. **Security**: User-specific operations still protected
3. **Flexibility**: Easy to identify which endpoints need auth
4. **Simplicity**: Reduced complexity for public data fetching

---

## �� Splash & Onboarding Migration

### ✅ Moved to Auth Feature (November 19, 2025)

All splash and onboarding screens have been moved to the auth feature folder:

#### New Structure:
```
lib/features/auth/
├── presentation/
│   ├── screens/
│   │   └── splash/
│   │       ├── splash_screen.dart          (moved from lib/screens/splash/)
│   │       └── onboarding_screen.dart      (moved from lib/screens/splash/)
│   └── widgets/
│       └── splash_content.dart             (moved from lib/screens/splash/components/)
└── utils/
    └── onboarding_preferences.dart         (moved from lib/utlis/)
```

#### Files Moved:
1. **splash_screen.dart** - Initial app splash screen with animations
2. **onboarding_screen.dart** - User onboarding flow (3 pages)
3. **splash_content.dart** - Reusable widget for onboarding content
4. **onboarding_preferences.dart** - Utility for managing onboarding state

#### Updated Imports:
- ✅ `lib/main.dart` - Updated splash screen import
- ✅ `lib/routes.dart` - Updated both splash and onboarding imports
- ✅ All internal imports within splash/onboarding files

#### Deleted:
- ❌ `lib/screens/splash/` directory (removed)
- ❌ `lib/utlis/onboarding_preferences.dart` (moved)

### 🎯 Benefits:
1. **Organization**: Splash/onboarding logically grouped with auth
2. **Clarity**: Auth flow now includes all pre-authentication screens
3. **Maintainability**: Easier to find and update related functionality
4. **Consistency**: Follows clean architecture pattern

