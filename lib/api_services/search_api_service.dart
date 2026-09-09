// import 'dart:convert'; // Unused import removed
import 'package:dio/dio.dart';
import 'base_api_service.dart';
import '../models/HomePageResponse.dart';

/// Search API Service based on SEARCH_API_DOCUMENTATION.md
/// Provides unified search across salons, services, and deals
class SearchApiService extends BaseApiService {
  /// Search across salons, services, and deals
  ///
  /// Returns SearchResponse containing results for requested types
  ///
  /// Example:
  /// ```dart
  /// final response = await SearchApiService.search(
  ///   keyword: 'massage',
  ///   filterType: ['service'],
  ///   minPrice: 50,
  ///   maxPrice: 200,
  /// );
  /// ```
  static Future<SearchResponse> search({
    // Search Parameters
    String? keyword,
    String? location,
    String? area,
    String? type,

    // Filter Parameters
    List<String>? filterType, // ["salon", "service", "deal"]
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    String? timeSlot, // morning, afternoon, evening, night
    List<String>? gender, // male, female, unisex

    // Sorting & Pagination
    String sortBy =
        'relevance', // relevance, rating, price_low, price_high, newest
    int perPage = 12,
    int page = 1, int? serviceCategoryId, // Page number for pagination
  }) async {
    try {
      // Build request body according to documentation
      final Map<String, dynamic> body = {};

      // Add parameters only if they are provided
      if (keyword != null && keyword.isNotEmpty) body['keyword'] = keyword;
      if (location != null && location.isNotEmpty) body['location'] = location;
      if (area != null && area.isNotEmpty) body['area'] = area;
      if (type != null && type.isNotEmpty) body['type'] = type;

      if (filterType != null && filterType.isNotEmpty) {
        body['filter_type'] = filterType;
      }

      if (categories != null && categories.isNotEmpty) {
        body['categories'] = categories;
      }
      // Inside search() method, body map ke andar
      if (serviceCategoryId != null) {
        body['service_category_id'] = serviceCategoryId;
      }

      if (minPrice != null) body['min_price'] = minPrice;
      if (maxPrice != null) body['max_price'] = maxPrice;
      if (timeSlot != null) body['time_slot'] = timeSlot;

      if (gender != null && gender.isNotEmpty) {
        body['gender'] = gender;
      }

      body['sort_by'] = sortBy;
      body['per_page'] = perPage;
      body['page'] = page; // Add page parameter for pagination

      // Make API call
      final response = await BaseApiService.post(
        '/search',
        data: body,
        requiresAuth: false,
        logTag: 'SEARCH',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return SearchResponse.fromJson(data);
      } else {
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(BaseApiService.extractErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred while searching: $e');
    }
  }

  /// Search only salons
  static Future<SearchResponse> searchSalons({
    String? keyword,
    String? location,
    String? area,
    String? type,
    List<String>? gender,
    String? timeSlot,
    String sortBy = 'relevance',
    int perPage = 12,
    int page = 1,
  }) {
    return search(
      keyword: keyword,
      location: location,
      area: area,
      type: type,
      filterType: ['salon'],
      gender: gender,
      timeSlot: timeSlot,
      sortBy: sortBy,
      perPage: perPage,
      page: page,
    );
  }

  /// Search only services
  static Future<SearchResponse> searchServices({
    String? keyword,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
    int page = 1,
  }) {
    return search(
      keyword: keyword,
      filterType: ['service'],
      categories: categories,
      minPrice: minPrice,
      maxPrice: maxPrice,
      gender: gender,
      sortBy: sortBy,
      perPage: perPage,
      page: page,
    );
  }

  /// Search only deals
  /// Search only deals
  static Future<SearchResponse> searchDeals({
    String? keyword,
    int? serviceCategoryId,     // ← NEW: Ye important hai (Services ki category filter)
    int? categoryId,            // Deal ki apni category (agar future mein zarurat pade)
    double? minPrice,
    double? maxPrice,
    String sortBy = 'relevance',
    int perPage = 12,
    int page = 1,
  }) {
    return search(
      keyword: keyword,
      filterType: ['deal'],
      serviceCategoryId: serviceCategoryId,   // ← Pass kar rahe hain
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
      perPage: perPage,
      page: page,
    );
  }

  /// Search all types (salons, services, deals) at once
  /// This is the unified search that updates all three tabs simultaneously
  static Future<SearchResponse> searchAll({
    String? keyword,
    String? location,
    String? area,
    String? type,
    List<int>? categories,
    double? minPrice,
    double? maxPrice,
    List<String>? gender,
    String sortBy = 'relevance',
    int perPage = 12,
  }) {
    return search(
      keyword: keyword,
      location: location,
      area: area,
      type: type,
      filterType: ['salon', 'service', 'deal'], // Search all types
      categories: categories,
      minPrice: minPrice,
      maxPrice: maxPrice,
      gender: gender,
      sortBy: sortBy,
      perPage: perPage,
      page: 1, // Always start at page 1 for unified search
    );
  }

  /// Get Top Rated Salons
  static Future<SalonPagination> getTopRatedSalons({int page = 1}) async {
    try {
      final response = await BaseApiService.get(
        '/get-top-rated-salon?page=$page',
        requiresAuth: false,
        logTag: 'TOP_RATED_SALONS',
      );
      if (response.statusCode == 200) {
        return SalonPagination.fromJson(response.data['response']['data']);
      } else {
        throw Exception('Failed to fetch top rated salons');
      }
    } on DioException catch (e) {
      throw Exception(BaseApiService.extractErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Popular Salons
  static Future<SalonPagination> getPopularSalons({int page = 1}) async {
    try {
      final response = await BaseApiService.get(
        '/get-popular-salons?page=$page',
        requiresAuth: false,
        logTag: 'POPULAR_SALONS',
      );
      if (response.statusCode == 200) {
        return SalonPagination.fromJson(response.data['response']['data']);
      } else {
        throw Exception('Failed to fetch popular salons');
      }
    } on DioException catch (e) {
      throw Exception(BaseApiService.extractErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}

/// Search Response Model
class SearchResponse {
  final int statusCode;
  final SearchData data;
  final String message;
  final bool status;
  final List<dynamic> errors;

  SearchResponse({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.status,
    required this.errors,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      statusCode: json['statusCode'] ?? 200,
      data: SearchData.fromJson(json['response']['data']),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      errors: json['errors'] ?? [],
    );
  }
}

/// Search Data Model
class SearchData {
  final int totalResults;
  final FiltersApplied filtersApplied;

  // Results can be either paginated or arrays
  final dynamic salons; // SalonPagination or List<Salon>
  final int salonsCount;

  final dynamic services; // ServicePagination or List<Service>
  final int servicesCount;

  final dynamic deals; // DealPagination or List<Deal>
  final int dealsCount;

  SearchData({
    required this.totalResults,
    required this.filtersApplied,
    required this.salons,
    required this.salonsCount,
    required this.services,
    required this.servicesCount,
    required this.deals,
    required this.dealsCount,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    // Check if results are paginated or arrays
    final salonsData = json['salons'];
    final servicesData = json['services'];
    final dealsData = json['deals'];

    dynamic parsedSalons;
    if (salonsData is Map && salonsData.containsKey('current_page')) {
      // Paginated results - cast to correct type
      parsedSalons =
          SalonPagination.fromJson(Map<String, dynamic>.from(salonsData));
    } else if (salonsData is List) {
      // Array results
      parsedSalons = salonsData.map((e) => Salon.fromJson(e)).toList();
    } else {
      parsedSalons = <Salon>[];
    }

    dynamic parsedServices;
    if (servicesData is Map && servicesData.containsKey('current_page')) {
      parsedServices =
          ServicePagination.fromJson(Map<String, dynamic>.from(servicesData));
    } else if (servicesData is List) {
      parsedServices = servicesData.map((e) => Service.fromJson(e)).toList();
    } else {
      parsedServices = <Service>[];
    }

    dynamic parsedDeals;
    if (dealsData is Map && dealsData.containsKey('current_page')) {
      parsedDeals =
          DealPagination.fromJson(Map<String, dynamic>.from(dealsData));
    } else if (dealsData is List) {
      parsedDeals = dealsData.map((e) => Deal.fromJson(e)).toList();
    } else {
      parsedDeals = <Deal>[];
    }

    return SearchData(
      totalResults: json['total_results'] ?? 0,
      filtersApplied: FiltersApplied.fromJson(json['filters_applied'] ?? {}),
      salons: parsedSalons,
      salonsCount: json['salons_count'] ?? 0,
      services: parsedServices,
      servicesCount: json['services_count'] ?? 0,
      deals: parsedDeals,
      dealsCount: json['deals_count'] ?? 0,
    );
  }

  /// Get salons as list regardless of pagination
  List<Salon> getSalonsList() {
    if (salons is SalonPagination) {
      return (salons as SalonPagination).data;
    } else if (salons is List<Salon>) {
      return salons as List<Salon>;
    }
    return [];
  }

  /// Get services as list regardless of pagination
  List<Service> getServicesList() {
    if (services is ServicePagination) {
      return (services as ServicePagination).data;
    } else if (services is List<Service>) {
      return services as List<Service>;
    }
    return [];
  }

  /// Get deals as list regardless of pagination
  List<Deal> getDealsList() {
    if (deals is DealPagination) {
      return (deals as DealPagination).data;
    } else if (deals is List<Deal>) {
      return deals as List<Deal>;
    }
    return [];
  }
}

/// Filters Applied Model
class FiltersApplied {
  final String? keyword;
  final String? location;
  final String? area;
  final String? type;
  final List<String> filterType;
  final List<int> categories;
  final double? minPrice;
  final double? maxPrice;
  final String? timeSlot;
  final List<String> gender;
  final String sortBy;

  FiltersApplied({
    this.keyword,
    this.location,
    this.area,
    this.type,
    required this.filterType,
    required this.categories,
    this.minPrice,
    this.maxPrice,
    this.timeSlot,
    required this.gender,
    required this.sortBy,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      keyword: json['keyword'],
      location: json['location'],
      area: json['area'],
      type: json['type'],
      filterType: (json['filter_type'] as List?)?.cast<String>() ?? [],
      categories: (json['categories'] as List?)?.cast<int>() ?? [],
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      timeSlot: json['time_slot'],
      gender: (json['gender'] as List?)?.cast<String>() ?? [],
      sortBy: json['sort_by'] ?? 'relevance',
    );
  }
}

/// Pagination Models
class SalonPagination {
  final int currentPage;
  final List<Salon> data;
  final int total;
  final int perPage;
  final int lastPage;

  SalonPagination({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory SalonPagination.fromJson(Map<String, dynamic> json) {
    return SalonPagination(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List?)?.map((e) => Salon.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 12,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class ServicePagination {
  final int currentPage;
  final List<Service> data;
  final int total;
  final int perPage;
  final int lastPage;

  ServicePagination({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory ServicePagination.fromJson(Map<String, dynamic> json) {
    return ServicePagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List?)?.map((e) => Service.fromJson(e)).toList() ??
          [],
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 12,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class DealPagination {
  final int currentPage;
  final List<Deal> data;
  final int total;
  final int perPage;
  final int lastPage;

  DealPagination({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory DealPagination.fromJson(Map<String, dynamic> json) {
    return DealPagination(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List?)?.map((e) => Deal.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 12,
      lastPage: json['last_page'] ?? 1,
    );
  }
}
