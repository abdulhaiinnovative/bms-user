// TODO: FAVOURITES MODEL - Response model for favourites list API
// Endpoint: POST /salons/favourite
// Returns paginated list of favourite salons with complete salon data

class FavouritesListResponse {
  final int statusCode;
  final ResponseData response;
  final String message;
  final bool status;
  final List<dynamic> errors;

  FavouritesListResponse({
    required this.statusCode,
    required this.response,
    required this.message,
    required this.status,
    required this.errors,
  });

  factory FavouritesListResponse.fromJson(Map<String, dynamic> json) {
    return FavouritesListResponse(
      statusCode: json['statusCode'],
      response: ResponseData.fromJson(json['response']),
      message: json['message'],
      status: json['status'],
      errors: json['errors'] ?? [],
    );
  }
}

class ResponseData {
  final PaginatedData data;

  ResponseData({required this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: PaginatedData.fromJson(json['data']),
    );
  }
}

class PaginatedData {
  final int currentPage;
  final List<FavouriteSalon> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  PaginatedData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PaginatedData.fromJson(Map<String, dynamic> json) {
    return PaginatedData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => FavouriteSalon.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List? ?? [])
          .map((e) => PageLink.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class FavouriteSalon {
  final int id;
  final int? vendorId;
  final String name;
  final String logo;
  final String image;
  final String country;
  final String state;
  final String city;
  final String area;
  final String address;
  final String latitude;
  final String longitude;
  final String minBookingTime;
  final String maxBookingTime;
  final String minCancellationTime;
  final String type;
  final String kind;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String salonFor;
  final String? mapLocation;
  final String salonPolicy;
  final String? additionalInformation;
  final String about;
  final int status;
  final int suspended;
  final double averageRating;
  final int reviewCount;
  final bool isFavourite;
  final List<ActiveDay> activeDays;

  FavouriteSalon({
    required this.id,
    this.vendorId,
    required this.name,
    required this.logo,
    required this.image,
    required this.country,
    required this.state,
    required this.city,
    required this.area,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.minBookingTime,
    required this.maxBookingTime,
    required this.minCancellationTime,
    required this.type,
    required this.kind,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    required this.salonFor,
    this.mapLocation,
    required this.salonPolicy,
    this.additionalInformation,
    required this.about,
    required this.status,
    required this.suspended,
    required this.averageRating,
    required this.reviewCount,
    required this.isFavourite,
    required this.activeDays,
  });

  factory FavouriteSalon.fromJson(Map<String, dynamic> json) {
    return FavouriteSalon(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      vendorId: json['vendor_id'] is int ? json['vendor_id'] : int.tryParse(json['vendor_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? json['image']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      minBookingTime: json['min_booking_time']?.toString() ?? '',
      maxBookingTime: json['max_booking_time']?.toString() ?? '',
      minCancellationTime: json['min_cancellation_time']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      facebook: json['facebook']?.toString(),
      instagram: json['instagram']?.toString(),
      linkedin: json['linkedin']?.toString(),
      twitter: json['twitter']?.toString(),
      salonFor: json['salon_for']?.toString() ?? '',
      mapLocation: json['map_location']?.toString(),
      salonPolicy: json['salon_policy']?.toString() ?? '',
      additionalInformation: json['additional_information']?.toString(),
      about: json['about']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      suspended: json['suspended'] is int ? json['suspended'] : int.tryParse(json['suspended']?.toString() ?? '0') ?? 0,
      averageRating: json['average_rating'] is num ? (json['average_rating'] as num).toDouble() : double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: json['review_count'] is int ? json['review_count'] : int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      isFavourite: json['is_favourite'] == true || json['is_favourite'] == 1 || json['is_favourite'] == '1',
      activeDays: (json['active_days'] as List? ?? [])
          .map((e) => ActiveDay.fromJson(e))
          .toList(),
    );
  }
}

class ActiveDay {
  final int id;
  final int salonId;
  final String day;
  final String openingTime;
  final String closingTime;
  final int status;

  ActiveDay({
    required this.id,
    required this.salonId,
    required this.day,
    required this.openingTime,
    required this.closingTime,
    required this.status,
  });

  factory ActiveDay.fromJson(Map<String, dynamic> json) {
    return ActiveDay(
      id: json['id'],
      salonId: json['salon_id'],
      day: json['day'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      status: json['status'],
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
