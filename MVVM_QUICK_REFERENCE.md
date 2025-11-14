# 🚀 MVVM Quick Reference Guide

**Project:** BookMySpot Flutter App
**Purpose:** Quick code snippets for MVVM migration

---

## 📚 Table of Contents

1. [Base Classes](#base-classes)
2. [Repository Examples](#repository-examples)
3. [ViewModel Examples](#viewmodel-examples)
4. [Screen Refactoring Examples](#screen-refactoring-examples)
5. [Common Patterns](#common-patterns)
6. [Testing Examples](#testing-examples)

---

## 🏗️ Base Classes

### BaseViewModel

**Location**: `lib/core/base/base_view_model.dart`

```dart
import 'package:flutter/foundation.dart';

enum ViewState { idle, loading, success, error }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isIdle => _state == ViewState.idle;

  // State setters
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
  Future<T?> runAsync<T>(
    Future<T> Function() action, {
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

### BaseRepository

**Location**: `lib/core/base/base_repository.dart`

```dart
import 'package:app/services/protected_http_client.dart';
import 'dart:developer';

abstract class BaseRepository {
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
}
```

---

## 📦 Repository Examples

### Template Repository

```dart
import 'dart:convert';
import 'package:app/core/base/base_repository.dart';
import 'package:app/models/YOUR_MODEL.dart';
import 'package:app/services/protected_http_client.dart';

class YourRepository extends BaseRepository {

  Future<YourModel> fetchData({Map<String, dynamic>? params}) async {
    return handleApiCall(
      () async {
        final response = await ProtectedHttpClient.get(
          '/your-endpoint',
          // Add query params if needed
        );

        if (response.statusCode == 200) {
          return YourModel.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      },
      errorPrefix: 'Fetch Data Error',
    );
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    return handleApiCall(
      () async {
        final response = await ProtectedHttpClient.post(
          '/your-endpoint',
          body: jsonEncode(data),
        );

        if (response.statusCode != 201) {
          throw Exception('Failed to create item');
        }
      },
      errorPrefix: 'Create Item Error',
    );
  }
}
```

### HomeRepository (Real Example)

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
          throw Exception('Failed to load: ${response.statusCode}');
        }
      },
      errorPrefix: 'Home Data Error',
    );
  }
}
```

### BookingRepository (With Pagination)

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
        final params = <String, dynamic>{
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        };

        final queryString = params.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');

        final response = await ProtectedHttpClient.get(
          '/mybookings?$queryString',
        );

        if (response.statusCode == 200) {
          return MyBookingResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception('Failed: ${response.statusCode}');
        }
      },
      errorPrefix: 'Booking Fetch Error',
    );
  }
}
```

---

## 🎨 ViewModel Examples

### Template ViewModel

```dart
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/your_repository.dart';
import 'package:app/models/your_model.dart';

class YourViewModel extends BaseViewModel {
  final YourRepository _repository;

  YourViewModel({YourRepository? repository})
      : _repository = repository ?? YourRepository();

  // State variables (private)
  List<YourItem>? _items;
  YourItem? _selectedItem;

  // Getters (public)
  List<YourItem>? get items => _items;
  YourItem? get selectedItem => _selectedItem;
  bool get hasData => _items != null && _items!.isNotEmpty;

  // Methods
  Future<void> loadData() async {
    await runAsync(
      () async {
        final response = await _repository.fetchData();
        _items = response.data;
      },
      errorMessage: 'Failed to load data',
    );
  }

  void selectItem(YourItem item) {
    _selectedItem = item;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _items = null;
    await loadData();
  }
}
```

### HomeViewModel (Real Example)

```dart
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/home_repository.dart';
import 'package:app/models/HomePageResponse.dart';

class HomeViewModel extends BaseViewModel {
  final HomeRepository _repository;

  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  // State
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

### ViewModel with Pagination

```dart
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/booking_repository.dart';
import 'package:app/models/booking_model.dart';

class MyBookingsViewModel extends BaseViewModel {
  final BookingRepository _repository;

  MyBookingsViewModel({BookingRepository? repository})
      : _repository = repository ?? BookingRepository();

  // State
  List<Booking> _allBookings = [];
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<Booking> get allBookings => _allBookings;
  bool get hasMoreData => _hasMoreData;

  // Load initial or refresh
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

        _hasMoreData = response.data?.nextPageUrl != null;
      },
      errorMessage: 'Failed to load bookings',
    );
  }

  // Load more for pagination
  Future<void> loadMore() async {
    if (!_hasMoreData || isLoading) return;

    _currentPage++;
    await loadBookings();
  }
}
```

### ViewModel with Cart Logic

```dart
import 'package:app/core/base/base_view_model.dart';
import 'package:app/models/HomePageResponse.dart';

class CartViewModel extends ChangeNotifier {
  final Map<dynamic, int> _cartItems = {};

  // Getters
  Map<dynamic, int> get cartItems => _cartItems;
  int get totalItems => _cartItems.length;

  double get totalAmount {
    return _cartItems.entries.fold(
      0.0,
      (sum, entry) => sum + (_getItemPrice(entry.key) * entry.value),
    );
  }

  bool isInCart(dynamic item) => _cartItems.containsKey(item);

  // Methods
  void addToCart(dynamic item) {
    if (_cartItems.containsKey(item)) {
      _cartItems.remove(item);
    } else {
      _cartItems[item] = 1;
    }
    notifyListeners();
  }

  void removeFromCart(dynamic item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void updateQuantity(dynamic item, int quantity) {
    if (quantity <= 0) {
      _cartItems.remove(item);
    } else {
      _cartItems[item] = quantity;
    }
    notifyListeners();
  }

  double _getItemPrice(dynamic item) {
    if (item is Service) return (item.price ?? 0).toDouble();
    if (item is Deal) return (item.totalPrice ?? 0).toDouble();
    return 0.0;
  }
}
```

---

## 🖥️ Screen Refactoring Examples

### Before: StatefulWidget with API Calls

```dart
// ❌ OLD WAY - Don't do this
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Type1>? type1;
  List<CategorySection>? type2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    HomeScreenAPI homeScreenAPI = HomeScreenAPI();
    try {
      HomePageResponse response = await homeScreenAPI.fetchHomePageData();
      setState(() {
        type1 = response.response.data.type1;
        type2 = response.response.data.type2;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    }

    return ListView(
      children: [
        // UI code
      ],
    );
  }
}
```

### After: StatelessWidget with ViewModel

```dart
// ✅ NEW WAY - Do this
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
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (viewModel.isError) {
            return _buildErrorState(context, viewModel);
          }

          // Success state
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshData(),
            child: ListView(
              children: [
                if (viewModel.categories != null)
                  CategoriesDashboard(categories: viewModel.categories!),
                if (viewModel.topSalons != null)
                  SalonDashboard(salons: viewModel.topSalons!),
                // ... more widgets
              ],
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
          Text(viewModel.errorMessage ?? 'Something went wrong'),
          ElevatedButton(
            onPressed: () => viewModel.loadHomeData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

### With Pagination (List Screen)

```dart
class MyBookings extends StatelessWidget {
  const MyBookings({super.key});

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

class _MyBookingsContentState extends State<_MyBookingsContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<MyBookingsViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: Consumer<MyBookingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.allBookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.isError && viewModel.allBookings.isEmpty) {
            return Center(child: Text(viewModel.errorMessage ?? 'Error'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadBookings(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: viewModel.allBookings.length +
                         (viewModel.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.allBookings.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final booking = viewModel.allBookings[index];
                return BookingCard(booking: booking);
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🔄 Common Patterns

### Pattern 1: Simple Data Loading

```dart
// In ViewModel
Future<void> loadData() async {
  await runAsync(
    () async {
      final response = await _repository.fetchData();
      _data = response.data;
    },
    errorMessage: 'Failed to load data',
  );
}

// In View
Consumer<YourViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) return LoadingWidget();
    if (viewModel.isError) return ErrorWidget(viewModel.errorMessage);
    return ContentWidget(data: viewModel.data);
  },
)
```

### Pattern 2: Form Submission

```dart
// In ViewModel
Future<bool> submitForm(Map<String, dynamic> formData) async {
  try {
    setLoading();
    await _repository.submitData(formData);
    setSuccess();
    return true;
  } catch (e) {
    setError('Failed to submit: $e');
    return false;
  }
}

// In View
ElevatedButton(
  onPressed: () async {
    final success = await context.read<YourViewModel>().submitForm(data);
    if (success) {
      // Navigate away or show success
    }
  },
  child: const Text('Submit'),
)
```

### Pattern 3: Search with Debounce

```dart
// In ViewModel
import 'dart:async';

Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 500), () {
    searchData(query);
  });
}

Future<void> searchData(String query) async {
  await runAsync(
    () async {
      final response = await _repository.search(query);
      _searchResults = response.results;
    },
    errorMessage: 'Search failed',
  );
}

// In View
TextField(
  onChanged: (value) {
    context.read<SearchViewModel>().onSearchChanged(value);
  },
)
```

### Pattern 4: Toggle Favourite

```dart
// In ViewModel
Future<void> toggleFavourite(int salonId) async {
  final isCurrentlyFavourite = _favourites.contains(salonId);

  try {
    setLoading();

    if (isCurrentlyFavourite) {
      await _repository.removeFavourite(salonId);
      _favourites.remove(salonId);
    } else {
      await _repository.addFavourite(salonId);
      _favourites.add(salonId);
    }

    setSuccess();
  } catch (e) {
    setError('Failed to update favourite');
  }
}

// In View
IconButton(
  icon: Icon(
    viewModel.isFavourite(salon.id)
      ? Icons.favorite
      : Icons.favorite_border,
  ),
  onPressed: () {
    context.read<FavouritesViewModel>().toggleFavourite(salon.id);
  },
)
```

### Pattern 5: Using Selector for Optimization

```dart
// Instead of Consumer (rebuilds entire widget)
Selector<CartViewModel, int>(
  selector: (context, cart) => cart.totalItems,
  builder: (context, totalItems, child) {
    return Badge(
      label: Text('$totalItems'),
      child: const Icon(Icons.shopping_cart),
    );
  },
)

// This only rebuilds when totalItems changes
// Not when other cart properties change
```

---

## 🧪 Testing Examples

### Unit Test for ViewModel

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:app/data/repositories/home_repository.dart';
import 'package:app/models/HomePageResponse.dart';

// Generate mocks
@GenerateMocks([HomeRepository])
import 'home_viewmodel_test.mocks.dart';

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
      expect(viewModel.sliders, null);
    });

    test('loadHomeData should update state on success', () async {
      // Arrange
      final mockResponse = HomePageResponse(
        statusCode: 200,
        response: HomeData(
          data: HomeContentData(
            type1: [/* mock data */],
            type2: [],
            type3: [],
            type4: [],
            type5: [],
          ),
        ),
      );

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
      expect(viewModel.hasData, false);
    });

    test('refreshData should clear and reload', () async {
      // Arrange - first load with data
      final mockResponse = HomePageResponse(/* ... */);
      when(mockRepository.fetchHomeData())
          .thenAnswer((_) async => mockResponse);
      await viewModel.loadHomeData();

      // Act - refresh
      await viewModel.refreshData();

      // Assert
      verify(mockRepository.fetchHomeData()).called(2); // Initial + refresh
      expect(viewModel.isSuccess, true);
    });
  });

  tearDown(() {
    viewModel.dispose();
  });
}
```

### Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('HomeScreen shows error message on error',
    (WidgetTester tester) async {
    // Arrange
    final viewModel = HomeViewModel();
    viewModel.setError('Test error message');

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: const _HomeScreenContent(),
        ),
      ),
    );
    await tester.pump();

    // Assert
    expect(find.text('Test error message'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
```

---

## 🎓 Best Practices Checklist

### ViewModel

- [ ] Extends BaseViewModel
- [ ] Uses repository for data
- [ ] No BuildContext reference
- [ ] State variables are private
- [ ] Exposes data through getters
- [ ] Uses runAsync for API calls
- [ ] Proper error handling
- [ ] Calls notifyListeners() when needed

### View

- [ ] Stateless when possible
- [ ] Uses Consumer/Selector
- [ ] No business logic
- [ ] Handles all states (loading, success, error)
- [ ] Proper dispose of controllers
- [ ] No direct API calls
- [ ] Clean and readable

### Repository

- [ ] Extends BaseRepository
- [ ] Uses handleApiCall wrapper
- [ ] Returns proper models
- [ ] Clear method names
- [ ] Proper error messages

### Testing

- [ ] Mock repositories
- [ ] Test all states
- [ ] Test error cases
- [ ] Test success cases
- [ ] Clean tearDown

---

## 🔗 Related Documentation

- [MVVM_MIGRATION_GUIDE.md](./MVVM_MIGRATION_GUIDE.md) - Complete migration guide
- [ARCHITECTURE_ANALYSIS.md](./ARCHITECTURE_ANALYSIS.md) - Current architecture analysis
- [MVVM_MIGRATION_CHECKLIST.md](./MVVM_MIGRATION_CHECKLIST.md) - Step-by-step checklist

---

**End of Quick Reference**

_Keep this document handy while coding!_
