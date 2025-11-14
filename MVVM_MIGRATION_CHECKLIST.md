# ✅ MVVM Migration Checklist

**Project:** BookMySpot Flutter App
**Last Updated:** November 13, 2025

---

## 🎯 Quick Start Guide

### Before You Begin
- [ ] Read `MVVM_MIGRATION_GUIDE.md`
- [ ] Read `ARCHITECTURE_ANALYSIS.md`
- [ ] Create feature branch: `git checkout -b feature/mvvm-migration`
- [ ] Backup current codebase
- [ ] Set up testing environment

---

## 📁 Phase 1: Foundation Setup (Week 1-2)

### Directory Structure
- [ ] Create `lib/core/` directory
- [ ] Create `lib/core/base/` directory
- [ ] Create `lib/core/constants/` directory
- [ ] Create `lib/core/errors/` directory
- [ ] Create `lib/core/utils/` directory
- [ ] Create `lib/data/` directory
- [ ] Create `lib/data/repositories/` directory
- [ ] Create `lib/data/data_sources/remote/` directory
- [ ] Create `lib/data/data_sources/local/` directory
- [ ] Create `lib/presentation/` directory
- [ ] Create `lib/presentation/viewmodels/` directory
- [ ] Organize `lib/presentation/viewmodels/` by feature:
  - [ ] `auth/`
  - [ ] `home/`
  - [ ] `search/`
  - [ ] `salon/`
  - [ ] `booking/`
  - [ ] `profile/`
  - [ ] `cart/`
  - [ ] `notification/`

### Base Classes
- [ ] Create `lib/core/base/base_view_model.dart`
  - [ ] ViewState enum
  - [ ] Base state management
  - [ ] Loading, success, error states
  - [ ] runAsync helper method
- [ ] Create `lib/core/base/base_repository.dart`
  - [ ] handleApiCall method
  - [ ] Common error handling
  - [ ] Pagination helper
- [ ] Create `lib/core/errors/app_exception.dart`
  - [ ] Custom exception classes
  - [ ] Error types
- [ ] Create `lib/core/errors/failure.dart`
  - [ ] Failure classes for better error handling

### Constants Organization
- [ ] Split `constants.dart` into:
  - [ ] `lib/core/constants/api_constants.dart`
  - [ ] `lib/core/constants/app_constants.dart`
  - [ ] Keep original for backward compatibility (temporary)

---

## 📦 Phase 2: Repositories (Week 2-3)

### Create Repository Classes

#### Core Repositories
- [ ] `lib/data/repositories/auth_repository.dart`
  - [ ] login()
  - [ ] signup()
  - [ ] googleSignIn()
  - [ ] resetPassword()
  - [ ] updateProfile()
  
- [ ] `lib/data/repositories/home_repository.dart`
  - [ ] fetchHomeData()
  - [ ] refreshHomeData()
  
- [ ] `lib/data/repositories/search_repository.dart`
  - [ ] searchServices()
  - [ ] searchDeals()
  - [ ] searchSalons()
  - [ ] Pagination support
  
- [ ] `lib/data/repositories/salon_repository.dart`
  - [ ] fetchSalonDetails()
  - [ ] fetchSalonServices()
  - [ ] fetchSalonDeals()
  
- [ ] `lib/data/repositories/booking_repository.dart`
  - [ ] fetchBookings()
  - [ ] createBooking()
  - [ ] cancelBooking()
  - [ ] Pagination support
  
- [ ] `lib/data/repositories/favourite_repository.dart`
  - [ ] fetchFavourites()
  - [ ] addFavourite()
  - [ ] removeFavourite()
  
- [ ] `lib/data/repositories/profile_repository.dart`
  - [ ] fetchUserProfile()
  - [ ] updateProfile()
  - [ ] uploadProfileImage()
  
- [ ] `lib/data/repositories/cart_repository.dart` (if needed)
  - [ ] Local cart management
  - [ ] Persistence

### Repository Testing
- [ ] Unit test AuthRepository
- [ ] Unit test HomeRepository
- [ ] Unit test SearchRepository
- [ ] Unit test BookingRepository

---

## 🎨 Phase 3: ViewModels (Week 3-4)

### Authentication ViewModels
- [ ] Move `lib/providers/auth/auth_provider.dart` to:
  - [ ] `lib/presentation/viewmodels/auth/auth_viewmodel.dart`
  - [ ] Rename class: `AuthProvider` → `AuthViewModel`
  - [ ] Extend `BaseViewModel`
  - [ ] Update imports across app
  
- [ ] Create `lib/presentation/viewmodels/auth/login_viewmodel.dart` (optional)
- [ ] Create `lib/presentation/viewmodels/auth/signup_viewmodel.dart` (optional)

### Home ViewModels
- [ ] `lib/presentation/viewmodels/home/home_viewmodel.dart`
  - [ ] Extend BaseViewModel
  - [ ] Use HomeRepository
  - [ ] State: sliders, categories, salons, deals, services
  - [ ] Methods: loadHomeData(), refreshData()
  
### Search ViewModels
- [ ] Move `lib/screens/search_final/search_provider_new.dart` to:
  - [ ] `lib/presentation/viewmodels/search/search_viewmodel.dart`
  - [ ] Rename class: `SearchProviderNew` → `SearchViewModel`
  - [ ] Extend BaseViewModel
  - [ ] Use SearchRepository
  - [ ] Update all imports

### Salon ViewModels
- [ ] `lib/presentation/viewmodels/salon/salon_detail_viewmodel.dart`
  - [ ] Salon info state
  - [ ] Services/deals state
  - [ ] Reviews state
  - [ ] Methods: loadSalonDetails(), loadServices()

### Booking ViewModels
- [ ] `lib/presentation/viewmodels/booking/my_bookings_viewmodel.dart`
  - [ ] All bookings state
  - [ ] Upcoming bookings state
  - [ ] Past bookings state
  - [ ] Pagination support
  - [ ] Methods: loadBookings(), loadMore(), cancelBooking()
  
- [ ] `lib/presentation/viewmodels/booking/booking_flow_viewmodel.dart`
  - [ ] Selected services state
  - [ ] Selected professional state
  - [ ] Selected date/time state
  - [ ] Payment info state
  - [ ] Methods: Step-by-step booking flow

### Cart ViewModel
- [ ] `lib/presentation/viewmodels/cart/cart_viewmodel.dart`
  - [ ] Cart items state
  - [ ] Total amount calculation
  - [ ] Methods: addToCart(), removeFromCart(), clearCart()

### Profile ViewModels
- [ ] `lib/presentation/viewmodels/profile/profile_viewmodel.dart`
  - [ ] User data state
  - [ ] Methods: loadProfile(), updateProfile()
  
- [ ] `lib/presentation/viewmodels/profile/favourites_viewmodel.dart`
  - [ ] Favourites list state
  - [ ] Methods: loadFavourites(), toggleFavourite()

### Notification ViewModel
- [ ] Move `lib/providers/notification/notification_provider.dart` to:
  - [ ] `lib/presentation/viewmodels/notification/notification_viewmodel.dart`
  - [ ] Rename class
  - [ ] Extend BaseViewModel

### ViewModel Testing
- [ ] Unit test HomeViewModel
- [ ] Unit test SearchViewModel
- [ ] Unit test MyBookingsViewModel
- [ ] Unit test CartViewModel
- [ ] Unit test FavouritesViewModel

---

## 🖥️ Phase 4: Screen Refactoring (Week 4-6)

### Simple Screens (Priority 3)

#### Profile Screen
- [ ] Refactor `lib/screens/profile/profile_screen.dart`
  - [ ] Convert to StatelessWidget (if possible)
  - [ ] Add ChangeNotifierProvider for ProfileViewModel
  - [ ] Use Consumer/Selector
  - [ ] Remove setState calls
  - [ ] Remove direct API calls
- [ ] Test profile screen

#### Favourites Screen
- [ ] Refactor `lib/screens/favourites/favourites_screen.dart`
  - [ ] Convert to StatelessWidget
  - [ ] Add FavouritesViewModel
  - [ ] Use Consumer
  - [ ] Remove setState calls
  - [ ] Remove direct API calls
  - [ ] Keep mounted checks as safety
- [ ] Test favourites screen

#### Cart Screen
- [ ] Refactor `lib/screens/cart/cart_screen.dart`
  - [ ] Use CartViewModel
  - [ ] Remove setState calls
- [ ] Test cart screen

### Medium Screens (Priority 2)

#### Home Screen
- [ ] Refactor `lib/screens/home/home_screen.dart`
  - [ ] Convert to StatelessWidget
  - [ ] Add ChangeNotifierProvider(create: HomeViewModel()..loadHomeData())
  - [ ] Replace initState logic with ViewModel
  - [ ] Use Consumer<HomeViewModel>
  - [ ] Update loading state rendering
  - [ ] Update error state rendering
  - [ ] Update success state rendering
  - [ ] Add RefreshIndicator with viewModel.refreshData()
  - [ ] Remove all setState calls
  - [ ] Test shimmer loading
  - [ ] Test error state
  - [ ] Test success state
  - [ ] Test pull-to-refresh

#### Search Screen
- [ ] Refactor `lib/screens/search_final/search_service_screen_new.dart`
  - [ ] Update Provider references (SearchProviderNew → SearchViewModel)
  - [ ] Update all imports
  - [ ] Verify pagination works
  - [ ] Verify filters work
  - [ ] Test all three tabs (Services, Deals, Salons)

#### My Account Screen
- [ ] Refactor `lib/screens/profile/my_account_screen.dart`
  - [ ] Use ProfileViewModel
  - [ ] Remove setState calls
  - [ ] Remove direct API calls
- [ ] Test profile updates

### Complex Screens (Priority 1 - Most Important)

#### Salon Services & Category List
- [ ] Refactor `lib/screens/test_scroll/salon_category_and_services_list.dart`
  - [ ] Create SalonDetailViewModel
  - [ ] Create CartViewModel (if not done)
  - [ ] Extract cart logic to CartViewModel
  - [ ] Extract service loading to SalonDetailViewModel
  - [ ] Convert to StatelessWidget where possible
  - [ ] Use Consumer for ViewModel
  - [ ] Remove all setState calls (currently 4)
  - [ ] Test cart functionality
  - [ ] Test service selection
  - [ ] Test professional selection flow

#### My Bookings Screen
- [ ] Refactor `lib/screens/history_bookings/my_bookings.dart`
  - [ ] Add MyBookingsViewModel
  - [ ] Convert main screen to use ViewModel
  - [ ] Keep TabController in StatefulWidget wrapper
  - [ ] Remove API call from initState
  - [ ] Remove setState calls (currently 5)
  - [ ] Update pagination logic to ViewModel
  - [ ] Update filter logic to ViewModel
  - [ ] Test All tab
  - [ ] Test Upcoming tab
  - [ ] Test Past tab
  - [ ] Test pagination
  - [ ] Test pull-to-refresh

#### Booking Flow
- [ ] Refactor `lib/screens/test_scroll/select_professionals.dart`
  - [ ] Use BookingFlowViewModel
  - [ ] Remove setState calls
  
- [ ] Refactor `lib/screens/test_scroll/select_time_screen.dart`
  - [ ] Use BookingFlowViewModel
  - [ ] Remove setState calls
  
- [ ] Refactor `lib/screens/test_scroll/SelectDateScreen.dart`
  - [ ] Use BookingFlowViewModel
  - [ ] Remove setState calls
  
- [ ] Refactor `lib/screens/test_scroll/confirm_booking_screen.dart`
  - [ ] Use BookingFlowViewModel
  - [ ] Remove setState calls
  - [ ] Test complete booking flow

#### Auth Screen
- [ ] Consider refactoring `lib/screens/auth/auth_screen.dart`
  - [ ] Already uses AuthProvider well
  - [ ] Just rename AuthProvider → AuthViewModel
  - [ ] Update imports
  - [ ] Optional: Split into separate login/signup screens

---

## 🔧 Phase 5: Main App Updates (Week 5)

### Update main.dart
- [ ] Update `lib/main.dart`
  - [ ] Update all Provider imports
  - [ ] Change `AuthProvider` → `AuthViewModel`
  - [ ] Change `SearchProviderNew` → `SearchViewModel`
  - [ ] Change `NotificationProvider` → `NotificationViewModel`
  - [ ] Remove old `SearchProvider` (unused)
  - [ ] Verify MultiProvider setup

### Update Routes
- [ ] Review `lib/routes.dart`
  - [ ] Ensure all routes work
  - [ ] Consider route guards with AuthViewModel
  - [ ] Test navigation flows

### Update Theme
- [ ] Optionally refactor `lib/theme.dart`
  - [ ] Move to `lib/theme/app_theme.dart`
  - [ ] Split colors into `app_colors.dart`
  - [ ] Split text styles into `app_text_styles.dart`

---

## 🧪 Phase 6: Testing (Week 6)

### Unit Tests
- [ ] Test all ViewModels
  - [ ] AuthViewModel
  - [ ] HomeViewModel
  - [ ] SearchViewModel
  - [ ] MyBookingsViewModel
  - [ ] CartViewModel
  - [ ] FavouritesViewModel
  - [ ] SalonDetailViewModel
  - [ ] BookingFlowViewModel

### Widget Tests
- [ ] Test critical user flows
  - [ ] Login flow
  - [ ] Home screen rendering
  - [ ] Search flow
  - [ ] Add to cart
  - [ ] Booking flow
  - [ ] Favourites toggle

### Integration Tests
- [ ] End-to-end user journeys
  - [ ] Complete booking flow
  - [ ] Search → View salon → Add service → Book
  - [ ] Profile update flow

### Manual QA
- [ ] Home screen
  - [ ] All categories load
  - [ ] All salons load
  - [ ] All deals load
  - [ ] All services load
  - [ ] Pull-to-refresh works
  - [ ] Navigation works
  
- [ ] Search
  - [ ] Service search works
  - [ ] Deal search works
  - [ ] Salon search works
  - [ ] Filters work
  - [ ] Sorting works
  - [ ] Pagination works
  
- [ ] Booking
  - [ ] View salon works
  - [ ] Add services to cart
  - [ ] Select professional
  - [ ] Select date
  - [ ] Select time
  - [ ] Confirm booking
  - [ ] View bookings
  - [ ] Cancel booking
  
- [ ] Profile
  - [ ] View profile
  - [ ] Update profile
  - [ ] View favourites
  - [ ] Add/remove favourites
  
- [ ] Authentication
  - [ ] Login works
  - [ ] Signup works
  - [ ] Google sign in works
  - [ ] Forgot password works
  - [ ] Logout works

---

## 🚀 Phase 7: Cleanup & Polish (Week 7)

### Code Cleanup
- [ ] Remove old unused files
  - [ ] Old providers (if duplicates exist)
  - [ ] Unused API services
  - [ ] Test files in main code
  
- [ ] Remove commented code
- [ ] Remove debug print statements
- [ ] Remove unused imports
- [ ] Run `flutter analyze`
- [ ] Fix all analyzer warnings

### Documentation
- [ ] Update README.md
- [ ] Add architecture diagram
- [ ] Document folder structure
- [ ] Add code examples
- [ ] Update API documentation
- [ ] Create developer onboarding guide

### Performance
- [ ] Profile app performance
- [ ] Optimize ViewModel rebuilds
- [ ] Check for memory leaks
- [ ] Optimize image loading
- [ ] Review lazy loading

### Code Review
- [ ] Self code review
- [ ] Peer code review
- [ ] Address feedback
- [ ] Final testing

---

## 📊 Progress Tracking

### Overall Progress
- [ ] Foundation: 0% complete
- [ ] Repositories: 0% complete
- [ ] ViewModels: 0% complete
- [ ] Screen Refactoring: 0% complete
- [ ] Testing: 0% complete
- [ ] Cleanup: 0% complete

### By Feature
- [ ] Authentication: Already good (just rename)
- [ ] Home: 0% complete
- [ ] Search: 50% complete (Provider exists)
- [ ] Salon Details: 0% complete
- [ ] Booking: 0% complete
- [ ] Favourites: 0% complete
- [ ] Profile: 0% complete
- [ ] Cart: 0% complete
- [ ] Notifications: Already good (just rename)

---

## 🎯 Success Criteria

### Code Quality
- [ ] No setState in Views (except minimal StatefulWidget wrappers)
- [ ] All business logic in ViewModels
- [ ] All API calls in Repositories
- [ ] Consistent error handling
- [ ] Proper loading states
- [ ] Clean separation of concerns

### Testing
- [ ] 80%+ code coverage on ViewModels
- [ ] All critical flows have widget tests
- [ ] Manual QA passed

### Performance
- [ ] No performance regressions
- [ ] Smooth scrolling
- [ ] Fast screen transitions
- [ ] Responsive UI

### Documentation
- [ ] Architecture documented
- [ ] Code examples provided
- [ ] Developer guide created

---

## 🆘 Common Issues & Solutions

### Issue: "Provider not found"
**Solution**: Make sure ChangeNotifierProvider is added at correct level in widget tree

### Issue: "setState after dispose"
**Solution**: ViewModels should handle this - check mounted status if needed

### Issue: "Too many rebuilds"
**Solution**: Use Selector instead of Consumer for granular rebuilds

### Issue: "Tests failing"
**Solution**: Mock repositories properly using mockito

### Issue: "Navigation not working after refactor"
**Solution**: Check that context has access to Provider

---

## 📞 Need Help?

1. Check MVVM_MIGRATION_GUIDE.md for detailed examples
2. Check ARCHITECTURE_ANALYSIS.md for current state analysis
3. Look at AuthProvider - it's already MVVM style
4. Review code examples in migration guide

---

**End of Checklist**

*Keep this document updated as you progress through migration!*

---

## 📈 Update Log

| Date | Update | By |
|------|--------|-----|
| 2025-11-13 | Initial checklist created | System |
| | | |
| | | |

