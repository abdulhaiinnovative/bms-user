import '../../../../api_services/search_api_service.dart';

/// Service for caching search results to improve performance
/// and reduce unnecessary API calls.
class SearchCacheService {
  // In-memory cache for search responses
  static final Map<String, _CachedSearchResponse> _cache = {};

  // Cache expiration duration (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Maximum cache entries to prevent memory issues
  static const int _maxCacheEntries = 20;

  /// Generate a unique cache key from search parameters
  static String _generateCacheKey({
    String? keyword,
    String? location,
    String? area,
    String? type,
    List<String>? filterType,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    String? timeSlot,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
    int page = 1,
  }) {
    final keyParts = <String>[];

    if (keyword != null) keyParts.add('k:$keyword');
    if (location != null) keyParts.add('loc:$location');
    if (area != null) keyParts.add('a:$area');
    if (type != null) keyParts.add('t:$type');
    if (filterType != null && filterType.isNotEmpty) {
      keyParts.add('ft:${filterType.join(',')}');
    }
    if (categories != null && categories.isNotEmpty) {
      keyParts.add('cat:${categories.join(',')}');
    }
    if (minPrice != null) keyParts.add('minP:$minPrice');
    if (maxPrice != null) keyParts.add('maxP:$maxPrice');
    if (timeSlot != null) keyParts.add('ts:$timeSlot');
    if (gender != null && gender.isNotEmpty) {
      keyParts.add('g:${gender.join(',')}');
    }
    keyParts.add('sb:$sortBy');
    keyParts.add('pp:$perPage');
    keyParts.add('pg:$page');

    return keyParts.join('|');
  }

  /// Get cached search response if available and not expired
  static SearchResponse? getCached({
    String? keyword,
    String? location,
    String? area,
    String? type,
    List<String>? filterType,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    String? timeSlot,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
    int page = 1,
  }) {
    final key = _generateCacheKey(
      keyword: keyword,
      location: location,
      area: area,
      type: type,
      filterType: filterType,
      categories: categories,
      minPrice: minPrice,
      maxPrice: maxPrice,
      timeSlot: timeSlot,
      gender: gender,
      sortBy: sortBy,
      perPage: perPage,
      page: page,
    );

    final cached = _cache[key];
    if (cached != null) {
      if (DateTime.now().difference(cached.timestamp) < _cacheExpiration) {
        return cached.response;
      } else {
        // Cache expired, remove it
        _cache.remove(key);
      }
    }
    return null;
  }

  /// Store search response in cache
  static void setCache({
    required SearchResponse response,
    String? keyword,
    String? location,
    String? area,
    String? type,
    List<String>? filterType,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    String? timeSlot,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
    int page = 1,
  }) {
    // Enforce max cache entries
    if (_cache.length >= _maxCacheEntries) {
      _removeOldestEntry();
    }

    final key = _generateCacheKey(
      keyword: keyword,
      location: location,
      area: area,
      type: type,
      filterType: filterType,
      categories: categories,
      minPrice: minPrice,
      maxPrice: maxPrice,
      timeSlot: timeSlot,
      gender: gender,
      sortBy: sortBy,
      perPage: perPage,
      page: page,
    );

    _cache[key] = _CachedSearchResponse(
      response: response,
      timestamp: DateTime.now(),
    );
  }

  /// Remove the oldest cache entry
  static void _removeOldestEntry() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTimestamp;

    for (final entry in _cache.entries) {
      if (oldestTimestamp == null ||
          entry.value.timestamp.isBefore(oldestTimestamp)) {
        oldestTimestamp = entry.value.timestamp;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Clear all cached search results
  static void clearCache() {
    _cache.clear();
  }

  /// Clear expired cache entries
  static void clearExpired() {
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (DateTime.now().difference(entry.value.timestamp) >=
          _cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'entries': _cache.length,
      'maxEntries': _maxCacheEntries,
      'expirationMinutes': _cacheExpiration.inMinutes,
    };
  }
}

/// Internal class to store cached response with timestamp
class _CachedSearchResponse {
  final SearchResponse response;
  final DateTime timestamp;

  _CachedSearchResponse({
    required this.response,
    required this.timestamp,
  });
}
