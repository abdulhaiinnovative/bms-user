class TopSalonsResponse {
  final int statusCode;
  final TopSalonsData response;

  TopSalonsResponse({
    required this.statusCode,
    required this.response,
  });

  factory TopSalonsResponse.fromJson(Map<String, dynamic> json) {
    return TopSalonsResponse(
      statusCode: json['statusCode'] ?? 0,
      response: TopSalonsData.fromJson(json['response'] ?? {}),
    );
  }
}

class TopSalonsData {
  final bool success;
  final String message;
  final TopSalonsPaginatedData data;

  TopSalonsData({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TopSalonsData.fromJson(Map<String, dynamic> json) {
    return TopSalonsData(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TopSalonsPaginatedData.fromJson(json['data'] ?? {}),
    );
  }
}

class TopSalonsPaginatedData {
  final int currentPage;
  final List<TopSalonItem> data;
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

  TopSalonsPaginatedData({
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

  factory TopSalonsPaginatedData.fromJson(Map<String, dynamic> json) {
    return TopSalonsPaginatedData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => TopSalonItem.fromJson(item))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List<dynamic>?)
              ?.map((item) => PageLink.fromJson(item))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class TopSalonItem {
  final int? id;
  final int? vendorId;
  final String? name;
  final String? image;
  final String? logo;
  final String? country;
  final String? state;
  final String? city;
  final String? area;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? minBookingTime;
  final String? maxBookingTime;
  final String? minCancellationTime;
  final String? type;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String? salonFor;
  final String? mapLocation;
  final String? salonPolicy;
  final String? additionalInformation;
  final String? about;
  final int? status;
  final int? suspended;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final int? averageRating;
  final int? reviewCount;
  final bool? isFavourite;

  TopSalonItem({
    this.id,
    this.vendorId,
    this.name,
    this.image,
    this.logo,
    this.country,
    this.state,
    this.city,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.minBookingTime,
    this.maxBookingTime,
    this.minCancellationTime,
    this.type,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    this.salonFor,
    this.mapLocation,
    this.salonPolicy,
    this.additionalInformation,
    this.about,
    this.status,
    this.suspended,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.reviewCount,
    this.isFavourite,
  });

  factory TopSalonItem.fromJson(Map<String, dynamic> json) {
    return TopSalonItem(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt(),
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : (json['vendor_id'] as num?)?.toInt(),
      name: json['name'],
      image: json['image'],
      logo: json['logo'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      area: json['area'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      minBookingTime: json['min_booking_time'],
      maxBookingTime: json['max_booking_time'],
      minCancellationTime: json['min_cancellation_time'],
      type: json['type'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      salonFor: json['salon_for'],
      mapLocation: json['map_location'],
      salonPolicy: json['salon_policy'],
      additionalInformation: json['additional_information'],
      about: json['about'],
      status: json['status'] is int
          ? json['status']
          : (json['status'] as num?)?.toInt(),
      suspended: json['suspended'] is int
          ? json['suspended']
          : (json['suspended'] as num?)?.toInt(),
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      averageRating: json['average_rating'] is int
          ? json['average_rating']
          : (json['average_rating'] as num?)?.toInt(),
      reviewCount: json['review_count'] is int
          ? json['review_count']
          : (json['review_count'] as num?)?.toInt(),
      isFavourite: json['is_favourite'],
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
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
