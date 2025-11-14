# 📋 MVVM Architecture Migration Guide for BMS Flutter App

**Project:** BookMySpot (BMS) - Beauty & Salon Booking App
**Current Architecture:** Mixed (StatefulWidget with direct API calls, some Provider usage)
**Target Architecture:** MVVM (Model-View-ViewModel) with Provider
**Generated:** November 13, 2025

---

## 📊 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current Architecture Analysis](#current-architecture-analysis)
3. [MVVM Architecture Overview](#mvvm-architecture-overview)
4. [Migration Strategy](#migration-strategy)
5. [Folder Structure](#folder-structure)
6. [Implementation Guide](#implementation-guide)
7. [Screen-by-Screen Migration Plan](#screen-by-screen-migration-plan)
8. [Code Examples](#code-examples)
9. [Testing Strategy](#testing-strategy)
10. [Timeline & Milestones](#timeline-milestones)

---

## 🎯 Executive Summary

### Current State

Your BMS Flutter app currently uses a **mixed architecture**:

- ✅ **Good**: Already using Provider for some features (Auth, Search, Notifications)
- ⚠️ **Mixed**: Direct API calls in StatefulWidgets (Home, Salons, Bookings, Favourites)
- ⚠️ **Tight Coupling**: Business logic mixed with UI code
- ⚠️ **State Management**: Over 140+ `setState()` calls across the app
- ⚠️ **Code Duplication**: Similar API call patterns repeated in multiple screens

### Target State (MVVM)

- **Model**: Data classes and repository pattern for API calls
- **View**: Pure UI widgets (StatelessWidget where possible)
- **ViewModel**: Business logic, state management using ChangeNotifier
- **Benefits**: Testable, maintainable, scalable, separation of concerns

---

## 🔍 Current Architecture Analysis

### File Statistics

- **Total Dart Files**: 462+ files
- **Screens**: 50+ screens
- **API Services**: 19 services
- **Models**: 60+ model classes
- **Providers**: 4 (Auth, Search, SearchNew, Notification)
- **setState() Usage**: 140+ occurrences

### Current Folder Structure

```
lib/
├── api_services/           # 19 API service files
│   ├── auth_service_api.dart
│   ├── home_screen_api.dart
│   ├── salon_detail_api.dart
│   ├── MyBookingsAPI.dart
│   └── ... (15+ more)
├── models/                 # 60+ model classes
│   ├── HomePageResponse.dart
│   ├── booking_model.dart
│   ├── auth/
│   ├── home/
│   ├── salon/
│   └── search/
├── screens/                # 50+ screens
│   ├── home/
│   ├── auth/
│   ├── search_final/
│   ├── test_scroll/
│   ├── history_bookings/
│   └── ... (10+ more folders)
├── providers/              # Current: 4 providers
│   ├── auth/
│   │   └── auth_provider.dart (✅ Well-structured)
│   ├── notification/
│   │   └── notification_provider.dart
│   └── SearchProvider.dart
├── components/             # Reusable UI components
├── services/               # Utility services (FCM, Google Sign-in)
├── utlis/                  # Helper utilities
├── constants.dart
├── routes.dart
└── main.dart
```

### Identified Patterns

#### ✅ Already Following MVVM (Good Examples)

1. **AuthProvider** (`lib/providers/auth/auth_provider.dart`) - 675 lines

   - Proper ViewModel implementation
   - State management with enums
   - Clean API separation
   - Error handling

2. **SearchProviderNew** (`lib/screens/search_final/search_provider_new.dart`)
   - ChangeNotifier implementation
   - Pagination support
   - Loading states

#### ⚠️ Needs Migration (Current Approach)

1. **HomeScreen** (`lib/screens/home/home_screen.dart`) - 308 lines

   - Direct API calls in StatefulWidget
   - setState for loading states
   - Business logic in UI layer

2. **MyBookings** (`lib/screens/history_bookings/my_bookings.dart`) - 743 lines

   - Multiple setState calls
   - API calls in initState
   - Pagination logic in UI

3. **SalonCategoryAndServicesList** (`lib/screens/test_scroll/salon_category_and_services_list.dart`) - 727 lines

   - Complex state management
   - Cart logic in UI layer
   - Multiple scroll controllers

4. **FavouritesScreen** (`lib/screens/favourites/favourites_screen.dart`)
   - Direct API calls
   - Mounted checks needed
   - setState after async

---

## 🏗️ MVVM Architecture Overview

### The Three Layers

```
┌─────────────────────────────────────────┐
│              VIEW LAYER                  │
│  (Screens/Widgets - Pure UI)            │
│  - StatelessWidget (preferred)          │
│  - Minimal StatefulWidget               │
│  - Consumer/Selector widgets            │
└─────────────────┬───────────────────────┘
                  │ Uses
                  ▼
┌─────────────────────────────────────────┐
│          VIEWMODEL LAYER                 │
│  (ChangeNotifier - Business Logic)      │
│  - State management                      │
│  - UI logic                              │
│  - Calls repositories                    │
│  - Exposes data to View                  │
└─────────────────┬───────────────────────┘
                  │ Uses
                  ▼
┌─────────────────────────────────────────┐
│           MODEL LAYER                    │
│  (Data & Repository)                     │
│  - Data models (existing)                │
│  - Repository classes (NEW)              │
│  - API service abstraction               │
└─────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**

   - View: Only rendering and user input
   - ViewModel: Business logic and state
   - Model: Data and data sources

2. **Unidirectional Data Flow**

   ```
   User Action → View → ViewModel → Repository → API
   API Response → Repository → ViewModel → View Update
   ```

3. **Testability**
   - ViewModels can be unit tested
   - Repositories can be mocked
   - Views can be widget tested

---

## 🚀 Migration Strategy

### Phase-Based Approach (Recommended)

#### Phase 1: Foundation (Week 1-2)

**Objective**: Set up infrastructure without breaking existing code

**Tasks**:

1. Create `viewmodels/` directory structure
2. Create `repositories/` directory structure
3. Create base classes (BaseViewModel, BaseRepository)
4. Migrate existing Providers to new structure (if needed)
5. Update dependency injection in `main.dart`

**Deliverables**:

- Folder structure ready
- Base classes created
- Documentation updated

#### Phase 2: Core Features (Week 3-4)

**Objective**: Migrate critical user flows

**Priority Order**:

1. ✅ **Authentication** (Already done, review only)
2. 🔄 **Home Screen** (High traffic)
3. 🔄 **Search & Filters** (Already partial, complete it)
4. 🔄 **Salon Details & Services**
5. 🔄 **Booking Flow** (Critical business flow)

#### Phase 3: Secondary Features (Week 5-6)

**Objective**: Migrate remaining screens

**Screens**:

- Favourites
- My Bookings
- Profile & Account
- Notifications
- Cart

#### Phase 4: Polish & Optimization (Week 7)

**Objective**: Clean up, test, optimize

**Tasks**:

- Remove old code patterns
- Add unit tests for ViewModels
- Performance optimization
- Code review and refactoring

---

## 📁 Folder Structure

### New Structure (Target)

```
lib/
├── core/                           # NEW - Core functionality
│   ├── base/
│   │   ├── base_view_model.dart
│   │   └── base_repository.dart
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
│
├── data/                           # NEW - Data layer
│   ├── models/                     # EXISTING (keep as is)
│   │   ├── auth/
│   │   ├── home/
│   │   ├── salon/
│   │   ├── booking/
│   │   └── search/
│   │
│   ├── repositories/               # NEW - Repository pattern
│   │   ├── auth_repository.dart
│   │   ├── home_repository.dart
│   │   ├── salon_repository.dart
│   │   ├── booking_repository.dart
│   │   ├── search_repository.dart
│   │   └── favourite_repository.dart
│   │
│   └── data_sources/               # NEW - API abstraction
│       ├── remote/
│       │   ├── auth_api.dart      # Wrapper for existing API services
│       │   ├── home_api.dart
│       │   └── ...
│       └── local/                  # For caching (future)
│           └── shared_prefs_helper.dart
│
├── presentation/                   # NEW - UI layer
│   ├── viewmodels/                # NEW - All ViewModels
│   │   ├── auth/
│   │   │   ├── login_viewmodel.dart
│   │   │   └── signup_viewmodel.dart
│   │   ├── home/
│   │   │   └── home_viewmodel.dart
│   │   ├── search/
│   │   │   └── search_viewmodel.dart
│   │   ├── salon/
│   │   │   ├── salon_list_viewmodel.dart
│   │   │   └── salon_detail_viewmodel.dart
│   │   ├── booking/
│   │   │   ├── my_bookings_viewmodel.dart
│   │   │   ├── booking_flow_viewmodel.dart
│   │   │   └── confirm_booking_viewmodel.dart
│   │   └── profile/
│   │       ├── profile_viewmodel.dart
│   │       └── favourites_viewmodel.dart
│   │
│   ├── screens/                   # EXISTING - Refactored screens
│   │   ├── auth/
│   │   ├── home/
│   │   ├── search/
│   │   ├── salon/
│   │   ├── booking/
│   │   └── profile/
│   │
│   └── widgets/                   # EXISTING - Reusable widgets
│       ├── common/
│       ├── cards/
│       └── buttons/
│
├── services/                      # EXISTING - Keep utility services
│   ├── protected_http_client.dart
│   ├── google_sign_in_service.dart
│   ├── fcm_token_service.dart
│   └── notifications/
│
├── routes/                        # REFACTOR - Better route management
│   ├── app_routes.dart
│   └── route_generator.dart
│
├── theme/                         # REFACTOR - Better theming
│   ├── app_theme.dart
│   ├── app_colors.dart
│   └── app_text_styles.dart
│
└── main.dart                      # UPDATE - Provider setup
```

### Migration Mapping

| Old Location         | New Location                    | Action                           |
| -------------------- | ------------------------------- | -------------------------------- |
| `lib/api_services/`  | `lib/data/data_sources/remote/` | Refactor into repository pattern |
| `lib/models/`        | `lib/data/models/`              | Move (no change needed)          |
| `lib/providers/`     | `lib/presentation/viewmodels/`  | Rename & restructure             |
| `lib/screens/`       | `lib/presentation/screens/`     | Refactor (remove business logic) |
| `lib/components/`    | `lib/presentation/widgets/`     | Move                             |
| `lib/constants.dart` | `lib/core/constants/`           | Split into multiple files        |

---

## 💻 Implementation Guide

### Step 1: Create Base Classes

#### 1.1 BaseViewModel

**File**: `lib/core/base/base_view_model.dart`

```dart
import 'package:flutter/foundation.dart';

enum ViewState {
  idle,
  loading,
  success,
  error,
}

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isIdle => _state == ViewState.idle;

  void setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  void setLoading() {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void setSuccess() {
    _state = ViewState.success;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void setIdle() {
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // Helper for async operations
  Future<T?> runAsync<T>(Future<T> Function() action, {
    String? errorMessage,
    void Function(T result)? onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      setLoading();
      final result = await action();
      setSuccess();
      onSuccess?.call(result);
      return result;
    } catch (e) {
      final error = errorMessage ?? e.toString();
      setError(error);
      onError?.call(error);
      return null;
    }
  }
}
```

#### 1.2 BaseRepository

**File**: `lib/core/base/base_repository.dart`

```dart
import 'package:app/services/protected_http_client.dart';
import 'dart:developer';

abstract class BaseRepository {
  // Common error handling
  Future<T> handleApiCall<T>(
    Future<T> Function() apiCall, {
    String? errorPrefix,
  }) async {
    try {
      return await apiCall();
    } on UnauthorizedException catch (e) {
      log('❌ Unauthorized: $e');
      throw Exception('Session expired. Please login again.');
    } on ApiException catch (e) {
      log('❌ API Error: $e');
      throw Exception('${errorPrefix ?? "API Error"}: $e');
    } catch (e) {
      log('❌ Unexpected error: $e');
      throw Exception('${errorPrefix ?? "Error"}: $e');
    }
  }

  // Pagination helper
  Map<String, dynamic> buildPaginationParams({
    int? page,
    int? limit,
    Map<String, dynamic>? additionalParams,
  }) {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (additionalParams != null) params.addAll(additionalParams);
    return params;
  }
}
```

### Step 2: Create Repository Pattern

#### Example: HomeRepository

**File**: `lib/data/repositories/home_repository.dart`

```dart
import 'dart:convert';
import 'dart:developer';
import 'package:app/core/base/base_repository.dart';
import 'package:app/models/HomePageResponse.dart';
import 'package:app/services/protected_http_client.dart';

class HomeRepository extends BaseRepository {

  Future<HomePageResponse> fetchHomeData() async {
    return handleApiCall(
      () async {
        final response = await ProtectedHttpClient.get('/home-page');

        if (response.statusCode == 200) {
          log('✅ Home data fetched successfully');
          return HomePageResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Failed to load home data: ${response.statusCode}');
        }
      },
      errorPrefix: 'Home Data Error',
    );
  }

  // Additional methods as needed
  Future<void> refreshHomeData() async {
    // Implement refresh logic
    return fetchHomeData();
  }
}
```

#### Example: BookingRepository

**File**: `lib/data/repositories/booking_repository.dart`

```dart
import 'dart:convert';
import 'package:app/core/base/base_repository.dart';
import 'package:app/models/MyBookingResponse.dart';
import 'package:app/services/protected_http_client.dart';

class BookingRepository extends BaseRepository {

  Future<MyBookingResponse> fetchBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return handleApiCall(
      () async {
        final params = buildPaginationParams(
          page: page,
          limit: limit,
          additionalParams: status != null ? {'status': status} : null,
        );

        final queryString = params.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');

        final response = await ProtectedHttpClient.get(
          '/mybookings?$queryString',
        );

        if (response.statusCode == 200) {
          return MyBookingResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Failed to fetch bookings: ${response.statusCode}');
        }
      },
      errorPrefix: 'Booking Fetch Error',
    );
  }

  Future<void> cancelBooking(int bookingId) async {
    return handleApiCall(
      () async {
        final response = await ProtectedHttpClient.post(
          '/bookings/$bookingId/cancel',
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to cancel booking');
        }
      },
      errorPrefix: 'Cancel Booking Error',
    );
  }
}
```

### Step 3: Create ViewModels

#### Example: HomeViewModel

**File**: `lib/presentation/viewmodels/home/home_viewmodel.dart`

```dart
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/home_repository.dart';
import 'package:app/models/HomePageResponse.dart';

class HomeViewModel extends BaseViewModel {
  final HomeRepository _repository;

  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  // State variables
  List<Type1>? _sliders;
  List<CategorySection>? _categories;
  List<TopSalonSection>? _topSalons;
  List<DealSection>? _deals;
  List<ServiceSection>? _services;

  // Getters
  List<Type1>? get sliders => _sliders;
  List<CategorySection>? get categories => _categories;
  List<TopSalonSection>? get topSalons => _topSalons;
  List<DealSection>? get deals => _deals;
  List<ServiceSection>? get services => _services;

  bool get hasData => _sliders != null || _categories != null;

  // Methods
  Future<void> loadHomeData() async {
    await runAsync(
      () async {
        final response = await _repository.fetchHomeData();
        _sliders = response.response.data.type1;
        _categories = response.response.data.type2;
        _topSalons = response.response.data.type3;
        _deals = response.response.data.type4;
        _services = response.response.data.type5;
      },
      errorMessage: 'Failed to load home data',
    );
  }

  Future<void> refreshData() async {
    _clearData();
    await loadHomeData();
  }

  void _clearData() {
    _sliders = null;
    _categories = null;
    _topSalons = null;
    _deals = null;
    _services = null;
    notifyListeners();
  }
}
```

#### Example: MyBookingsViewModel

**File**: `lib/presentation/viewmodels/booking/my_bookings_viewmodel.dart`

```dart
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/booking_repository.dart';
import 'package:app/models/booking_model.dart';
import 'package:intl/intl.dart';

class MyBookingsViewModel extends BaseViewModel {
  final BookingRepository _repository;

  MyBookingsViewModel({BookingRepository? repository})
      : _repository = repository ?? BookingRepository();

  // State
  List<Booking> _allBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];

  int _currentPage = 1;
  bool _hasMoreData = true;
  String? _nextPageUrl;

  // Getters
  List<Booking> get allBookings => _allBookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  List<Booking> get pastBookings => _pastBookings;
  bool get hasMoreData => _hasMoreData;

  // Load initial data
  Future<void> loadBookings({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _allBookings.clear();
    }

    await runAsync(
      () async {
        final response = await _repository.fetchBookings(
          page: _currentPage,
          limit: 10,
        );

        if (refresh) {
          _allBookings = response.data?.bookings ?? [];
        } else {
          _allBookings.addAll(response.data?.bookings ?? []);
        }

        _nextPageUrl = response.data?.nextPageUrl;
        _hasMoreData = _nextPageUrl != null;

        _filterAndSortBookings();
      },
      errorMessage: 'Failed to load bookings',
    );
  }

  // Load more (pagination)
  Future<void> loadMore() async {
    if (!_hasMoreData || isLoading) return;

    _currentPage++;
    await loadBookings();
  }

  // Filter bookings
  void _filterAndSortBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _upcomingBookings = _allBookings.where((booking) {
      final bookingDate = _parseDate(booking.date);
      return bookingDate != null &&
             (bookingDate.isAfter(today) ||
              bookingDate.isAtSameMomentAs(today));
    }).toList();

    _pastBookings = _allBookings.where((booking) {
      final bookingDate = _parseDate(booking.date);
      return bookingDate != null && bookingDate.isBefore(today);
    }).toList();

    // Sort
    _upcomingBookings.sort((a, b) {
      final dateA = _parseDate(a.date);
      final dateB = _parseDate(b.date);
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    _pastBookings.sort((a, b) {
      final dateA = _parseDate(a.date);
      final dateB = _parseDate(b.date);
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA); // Descending
    });

    notifyListeners();
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    try {
      setLoading();
      await _repository.cancelBooking(bookingId);
      await loadBookings(refresh: true);
      setSuccess();
      return true;
    } catch (e) {
      setError('Failed to cancel booking: $e');
      return false;
    }
  }
}
```

### Step 4: Refactor Screens to Use ViewModels

#### Example: HomeScreen (Refactored)

**File**: `lib/presentation/screens/home/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:app/core/base/base_view_model.dart';
import 'components/categories_dashboard.dart';
import 'components/home_header.dart';
import 'components/salon_dashboard.dart';
import 'components/deals_dashboard.dart';
import 'components/services_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..loadHomeData(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading && !viewModel.hasData) {
            return _buildShimmer();
          }

          // Error state
          if (viewModel.isError) {
            return _buildErrorState(context, viewModel);
          }

          // Success state
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshData(),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 10),

                    // Categories
                    if (viewModel.categories != null &&
                        viewModel.categories!.isNotEmpty)
                      CategoriesDashboard(
                        categories: viewModel.categories!,
                      ),

                    // Top Salons
                    if (viewModel.topSalons != null &&
                        viewModel.topSalons!.isNotEmpty)
                      SalonDashboard(
                        salons: viewModel.topSalons!,
                      ),

                    // Deals
                    if (viewModel.deals != null && viewModel.deals!.isNotEmpty)
                      DealsDashboard(
                        deals: viewModel.deals!,
                      ),

                    // Services
                    if (viewModel.services != null &&
                        viewModel.services!.isNotEmpty)
                      ServicesDashboard(
                        services: viewModel.services!,
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? 'Something went wrong',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadHomeData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer loading UI
                  Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 24,
                    color: Colors.white,
                  ),
                  // ... more shimmer widgets
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Example: MyBookings (Refactored)

**File**: `lib/presentation/screens/history_bookings/my_bookings.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/presentation/viewmodels/booking/my_bookings_viewmodel.dart';

class MyBookings extends StatelessWidget {
  const MyBookings({super.key});
  static String routeName = "/my-bookings";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyBookingsViewModel()..loadBookings(),
      child: const _MyBookingsContent(),
    );
  }
}

class _MyBookingsContent extends StatefulWidget {
  const _MyBookingsContent();

  @override
  State<_MyBookingsContent> createState() => _MyBookingsContentState();
}

class _MyBookingsContentState extends State<_MyBookingsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ScrollController _allScrollController = ScrollController();
  final ScrollController _upcomingScrollController = ScrollController();
  final ScrollController _pastScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add pagination listeners
    _allScrollController.addListener(_onAllScroll);
    _upcomingScrollController.addListener(_onUpcomingScroll);
    _pastScrollController.addListener(_onPastScroll);
  }

  void _onAllScroll() {
    if (_allScrollController.position.pixels >=
        _allScrollController.position.maxScrollExtent * 0.8) {
      context.read<MyBookingsViewModel>().loadMore();
    }
  }

  void _onUpcomingScroll() {
    if (_upcomingScrollController.position.pixels >=
        _upcomingScrollController.position.maxScrollExtent * 0.8) {
      context.read<MyBookingsViewModel>().loadMore();
    }
  }

  void _onPastScroll() {
    if (_pastScrollController.position.pixels >=
        _pastScrollController.position.maxScrollExtent * 0.8) {
      context.read<MyBookingsViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _allScrollController.dispose();
    _upcomingScrollController.dispose();
    _pastScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: Consumer<MyBookingsViewModel>(
        builder: (context, viewModel, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(viewModel.allBookings, _allScrollController, viewModel),
              _buildBookingList(viewModel.upcomingBookings, _upcomingScrollController, viewModel),
              _buildBookingList(viewModel.pastBookings, _pastScrollController, viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    List<dynamic> bookings,
    ScrollController controller,
    MyBookingsViewModel viewModel,
  ) {
    if (viewModel.isLoading && bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.isError && bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.errorMessage ?? 'Error loading bookings'),
            ElevatedButton(
              onPressed: () => viewModel.loadBookings(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadBookings(refresh: true),
      child: ListView.builder(
        controller: controller,
        itemCount: bookings.length + (viewModel.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == bookings.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final booking = bookings[index];
          // Return your modern booking card widget here
          return BookingCard(booking: booking);
        },
      ),
    );
  }
}
```

### Step 5: Update main.dart

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ViewModels
import 'package:app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:app/presentation/viewmodels/search/search_viewmodel.dart';
import 'package:app/presentation/viewmodels/notification/notification_viewmodel.dart';
import 'package:app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:app/presentation/viewmodels/booking/my_bookings_viewmodel.dart';
import 'package:app/presentation/viewmodels/profile/favourites_viewmodel.dart';

// Other imports
import 'firebase_options.dart';
import 'routes.dart';
import 'theme.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GoogleSignIn.instance.initialize(
    serverClientId: '55638853518-g0g84a7rsoolhi6ugo76se0o0seovf9b.apps.googleusercontent.com',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global ViewModels (persist across app)
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),

        // Screen-specific ViewModels can be provided at screen level
        // or here if they need to be global
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BookMySpot',
        theme: AppTheme.lightTheme(context),
        initialRoute: SplashScreen.routeName,
        routes: routes,
      ),
    );
  }
}
```

---

## 📝 Screen-by-Screen Migration Plan

### Priority 1: Critical User Flows

#### 1. Authentication Flow ✅

**Status**: Already implemented well
**Files**:

- `lib/providers/auth/auth_provider.dart` (675 lines)
  **Action**: Review and rename to `auth_viewmodel.dart`

#### 2. Home Screen 🔄

**Current**: `lib/screens/home/home_screen.dart` (308 lines)
**Target**:

- ViewModel: `lib/presentation/viewmodels/home/home_viewmodel.dart`
- Repository: `lib/data/repositories/home_repository.dart`
- Screen: Refactor to StatelessWidget

**Migration Steps**:

1. Create HomeRepository
2. Create HomeViewModel
3. Refactor HomeScreen to use ViewModel
4. Remove setState calls
5. Test thoroughly

**Estimated Time**: 4-6 hours

#### 3. Search & Filters 🔄

**Current**:

- `lib/screens/search_final/search_service_screen_new.dart`
- `lib/screens/search_final/search_provider_new.dart` (Partial MVVM)

**Target**: Complete the MVVM implementation
**Estimated Time**: 3-4 hours

#### 4. Salon Details & Services 🔄

**Current**:

- `lib/screens/test_scroll/salon_category_and_services_list.dart` (727 lines)
- Complex cart management in UI

**Target**:

- ViewModel: `lib/presentation/viewmodels/salon/salon_detail_viewmodel.dart`
- ViewModel: `lib/presentation/viewmodels/cart/cart_viewmodel.dart`
- Repository: `lib/data/repositories/salon_repository.dart`

**Migration Steps**:

1. Extract cart logic to CartViewModel
2. Create SalonDetailViewModel
3. Create SalonRepository
4. Refactor screen
5. Test cart functionality

**Estimated Time**: 8-10 hours

#### 5. Booking Flow 🔄

**Current**:

- `lib/screens/history_bookings/my_bookings.dart` (743 lines)
- `lib/screens/test_scroll/select_professionals.dart`
- `lib/screens/test_scroll/confirm_booking_screen.dart`

**Target**:

- ViewModel: `lib/presentation/viewmodels/booking/my_bookings_viewmodel.dart`
- ViewModel: `lib/presentation/viewmodels/booking/booking_flow_viewmodel.dart`
- Repository: `lib/data/repositories/booking_repository.dart`

**Estimated Time**: 10-12 hours

### Priority 2: Secondary Features

#### 6. Favourites Screen 🔄

**Current**: `lib/screens/favourites/favourites_screen.dart`
**Estimated Time**: 3-4 hours

#### 7. Profile & Account 🔄

**Current**: `lib/screens/profile/my_account_screen.dart`
**Estimated Time**: 3-4 hours

#### 8. Notifications 🔄

**Current**: Already has provider
**Estimated Time**: 2-3 hours (review & refactor)

#### 9. Cart Screen 🔄

**Current**: `lib/screens/cart/cart_screen.dart`
**Estimated Time**: 3-4 hours

---

## 🧪 Testing Strategy

### Unit Testing ViewModels

```dart
// test/viewmodels/home_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:app/data/repositories/home_repository.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late HomeViewModel viewModel;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    viewModel = HomeViewModel(repository: mockRepository);
  });

  group('HomeViewModel Tests', () {
    test('Initial state should be idle', () {
      expect(viewModel.isIdle, true);
      expect(viewModel.hasData, false);
    });

    test('loadHomeData should update state correctly', () async {
      // Arrange
      final mockResponse = _createMockHomeResponse();
      when(mockRepository.fetchHomeData())
          .thenAnswer((_) async => mockResponse);

      // Act
      await viewModel.loadHomeData();

      // Assert
      expect(viewModel.isSuccess, true);
      expect(viewModel.hasData, true);
      expect(viewModel.sliders, isNotNull);
      verify(mockRepository.fetchHomeData()).called(1);
    });

    test('loadHomeData should set error on failure', () async {
      // Arrange
      when(mockRepository.fetchHomeData())
          .thenThrow(Exception('Network error'));

      // Act
      await viewModel.loadHomeData();

      // Assert
      expect(viewModel.isError, true);
      expect(viewModel.errorMessage, contains('Network error'));
    });
  });
}
```

### Widget Testing

```dart
// test/screens/home_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/presentation/screens/home/home_screen.dart';
import 'package:app/presentation/viewmodels/home/home_viewmodel.dart';

void main() {
  testWidgets('HomeScreen shows loading indicator initially',
    (WidgetTester tester) async {
    // Arrange
    final viewModel = HomeViewModel();

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const HomeScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## ⏱️ Timeline & Milestones

### Week 1-2: Foundation

- [ ] Create folder structure
- [ ] Create base classes (BaseViewModel, BaseRepository)
- [ ] Set up dependency injection
- [ ] Create documentation
- [ ] Team training on MVVM

### Week 3-4: Core Features

- [ ] Migrate Home Screen
- [ ] Complete Search implementation
- [ ] Migrate Salon Details
- [ ] Migrate Booking Flow
- [ ] Unit tests for ViewModels

### Week 5-6: Secondary Features

- [ ] Migrate Favourites
- [ ] Migrate Profile
- [ ] Migrate Cart
- [ ] Migrate remaining screens
- [ ] Integration tests

### Week 7: Polish

- [ ] Code cleanup
- [ ] Performance optimization
- [ ] Documentation update
- [ ] Final testing
- [ ] Code review

---

## 📚 Best Practices

### 1. ViewModel Guidelines

- **Single Responsibility**: One ViewModel per screen/feature
- **No BuildContext**: ViewModels should never have access to BuildContext
- **Immutable Getters**: Expose data through getters, not direct fields
- **Clear State**: Use enums for state management
- **Error Handling**: Always handle errors gracefully

### 2. View Guidelines

- **Stateless Preferred**: Use StatelessWidget unless absolutely necessary
- **Consumer/Selector**: Use appropriate Provider widgets
- **No Business Logic**: Views should only handle UI
- **Separation**: Split large screens into smaller widgets

### 3. Repository Guidelines

- **Single Data Source**: One repository per entity
- **Error Handling**: Consistent error handling
- **Caching Strategy**: Implement caching where appropriate
- **Type Safety**: Use strongly typed responses

### 4. Testing Guidelines

- **Unit Tests**: Test all ViewModels
- **Widget Tests**: Test critical UI flows
- **Integration Tests**: Test end-to-end user journeys
- **Mock Dependencies**: Use mockito for mocking repositories

---

## 🎓 Learning Resources

### MVVM in Flutter

1. [Flutter MVVM Architecture Guide](https://medium.com/flutter-community/flutter-mvvm-architecture-f8bed2521958)
2. [Provider Documentation](https://pub.dev/packages/provider)
3. [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

### Repository Pattern

1. [Repository Pattern in Flutter](https://medium.com/flutter-community/repository-design-pattern-in-flutter-89da6c5d1106)
2. [Data Layer Best Practices](https://docs.flutter.dev/cookbook/architecture/data-layer)

---

## ⚠️ Common Pitfalls to Avoid

1. **Don't** mix business logic in Views
2. **Don't** call APIs directly from Views
3. **Don't** forget to dispose controllers in StatefulWidgets
4. **Don't** overuse global Providers (use screen-level when possible)
5. **Don't** ignore error states
6. **Don't** skip testing ViewModels

---

## 📞 Support & Questions

For questions during migration:

1. Review this document
2. Check existing well-implemented examples (AuthProvider)
3. Refer to code examples in this guide
4. Follow best practices section

---

## 📊 Progress Tracking

Use this checklist to track migration progress:

### Foundation

- [ ] Folder structure created
- [ ] BaseViewModel implemented
- [ ] BaseRepository implemented
- [ ] main.dart updated

### Repositories

- [ ] HomeRepository
- [ ] SalonRepository
- [ ] BookingRepository
- [ ] SearchRepository
- [ ] FavouriteRepository
- [ ] ProfileRepository

### ViewModels

- [ ] HomeViewModel
- [ ] SalonDetailViewModel
- [ ] MyBookingsViewModel
- [ ] BookingFlowViewModel
- [ ] SearchViewModel (refactor)
- [ ] FavouritesViewModel
- [ ] ProfileViewModel
- [ ] CartViewModel

### Screens Migrated

- [ ] Home Screen
- [ ] Search Screen
- [ ] Salon Detail Screen
- [ ] My Bookings Screen
- [ ] Booking Flow Screens
- [ ] Favourites Screen
- [ ] Profile Screen
- [ ] Cart Screen

### Testing

- [ ] ViewModel unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual QA complete

---

**End of Migration Guide**

_Generated for BookMySpot Flutter App - November 13, 2025_
