import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/favourites_repository.dart';
import 'package:app/models/FavouritesListResponse.dart';

/// ViewModel for Favourites Screen
/// Manages state for favourites list with pagination
class FavouritesViewModel extends BaseViewModel {
  final FavouritesRepository _repository;

  FavouritesViewModel({FavouritesRepository? repository})
      : _repository = repository ?? FavouritesRepository();

  // State
  List<FavouriteSalon> _favouriteSalons = [];
  bool _isRefreshing = false;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalFavourites = 0;

  // Getters
  List<FavouriteSalon> get favouriteSalons => _favouriteSalons;
  bool get isRefreshing => _isRefreshing;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalFavourites => _totalFavourites;
  bool get hasMorePages => _currentPage < _lastPage;
  bool get isEmpty => _favouriteSalons.isEmpty && !isLoading;

  /// Load favourites list
  Future<void> loadFavourites({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
      _currentPage = 1;
      notifyListeners();
    }

    await executeAsync(
      operation: () async {
        log('FavouritesViewModel: Loading page $_currentPage');

        final result = await _repository.getFavouritesList(page: _currentPage);

        if (result['success'] == true) {
          final response = FavouritesListResponse.fromJson(result['data']);
          final paginatedData = response.response.data;

          log('FavouritesViewModel: Loaded ${paginatedData.data.length} favourites');
          log('Pagination: Page $_currentPage of ${paginatedData.lastPage}, Total: ${paginatedData.total}');

          if (refresh) {
            _favouriteSalons = paginatedData.data;
          } else {
            _favouriteSalons.addAll(paginatedData.data);
          }

          _currentPage = paginatedData.currentPage;
          _lastPage = paginatedData.lastPage;
          _totalFavourites = paginatedData.total;
          _isRefreshing = false;

          return response;
        } else {
          throw Exception(result['message'] ?? 'Failed to load favourites');
        }
      },
      setLoadingState: !refresh, // Don't show loading spinner when refreshing
      onError: (error) {
        _isRefreshing = false;
        log('FavouritesViewModel: Error loading favourites - $error');
      },
    );
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!hasMorePages || isLoading) return;

    _currentPage++;
    await loadFavourites();
  }

  /// Refresh favourites list
  Future<void> refresh() async {
    await loadFavourites(refresh: true);
  }

  /// Toggle favourite status
  Future<bool> toggleFavourite({
    required String salonId,
    required int index,
  }) async {
    final result = await executeAsyncSilent(
      operation: () async {
        log('FavouritesViewModel: Toggling favourite for salon $salonId');

        final result = await _repository.toggleFavourite(
          shareId: salonId,
          shareType: 'salon',
        );

        if (result['success'] == true) {
          // Remove from list if unfavourited
          if (result['isFavourite'] == false) {
            _favouriteSalons.removeAt(index);
            _totalFavourites--;
            notifyListeners();
            log('FavouritesViewModel: Removed salon from favourites');
          }
          return result['isFavourite'];
        } else {
          throw Exception(result['message'] ?? 'Failed to toggle favourite');
        }
      },
      onError: (error) {
        log('FavouritesViewModel: Error toggling favourite - $error');
      },
    );

    return result ?? false;
  }
}
