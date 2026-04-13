class Type4 {
  final String heading;
  final List<Type4Data> data;

  Type4({required this.heading, required this.data});

  factory Type4.fromJson(Map<String, dynamic> json) {
    return Type4(
      heading: json['heading'],
      data: (json['data'] as List? ?? [])
          .map((item) => Type4Data.fromJson(item))
          .toList(),
    );
  }
}

class Type4Data {
  final int id;
  final int salonId;
  final String name;
  final String image;
  final double price;
  final String discountType;
  final double discountValue;
  final double totalPrice;
  final String startDate;
  final String endDate;
  final int status;
  final String createdAt;
  final String updatedAt;
  final Salon salon;
  final List<Service> services;

  Type4Data({
    required this.id,
    required this.salonId,
    required this.name,
    required this.image,
    required this.price,
    required this.discountType,
    required this.discountValue,
    required this.totalPrice,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.salon,
    required this.services,
  });

  factory Type4Data.fromJson(Map<String, dynamic> json) {
    return Type4Data(
      id: json['id'],
      salonId: json['salon_id'],
      name: json['name'],
      image: json['image'],
      price: json['price'].toDouble(),
      discountType: json['discount_type'],
      discountValue: json['discount_value'].toDouble(),
      totalPrice: json['total_price'].toDouble(),
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      salon: Salon.fromJson(json['salon']),
      services: (json['services'] as List? ?? [])
          .map((item) => Service.fromJson(item))
          .toList(),
    );
  }
}

class Salon {
  final int id;
  final int vendorId;
  final String name;
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
  final String facebook;
  final String instagram;
  final String linkedin;
  final String twitter;
  final String salonFor;
  final String mapLocation;
  final String salonPolicy;
  final String additionalInformation;
  final String about;
  final int status;
  final String createdAt;
  final String updatedAt;
  final double averageRating;
  final int reviewCount;
  final bool isFavourite;

  Salon({
    required this.id,
    required this.vendorId,
    required this.name,
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
    required this.facebook,
    required this.instagram,
    required this.linkedin,
    required this.twitter,
    required this.salonFor,
    required this.mapLocation,
    required this.salonPolicy,
    required this.additionalInformation,
    required this.about,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.averageRating,
    required this.reviewCount,
    required this.isFavourite,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'],
      vendorId: json['vendor_id'],
      name: json['name'],
      image: json['image'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      area: json['area'],
      address: json['address'],
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      minBookingTime: json['min_booking_time'] ?? '',
      maxBookingTime: json['max_booking_time'] ?? '',
      minCancellationTime: json['min_cancellation_time'] ?? '',
      type: json['type'],
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'] ?? '',
      salonFor: json['salon_for'],
      mapLocation: json['map_location'] ?? '',
      salonPolicy: json['salon_policy'],
      additionalInformation: json['additional_information'] ?? '',
      about: json['about'],
      status: json['status'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      averageRating: json['average_rating'].toDouble(),
      reviewCount: json['review_count'],
      isFavourite: json['is_favourite'],
    );
  }
}

class Service {
  final int id;
  final int salonId;
  final String name;
  final String shortDescription;
  final String duration;
  final String description;
  final String price;
  final int categoryId;
  final int subcategoryId;
  final int isFeature;
  final int status;
  final int extraTime;
  final String gender;
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.salonId,
    required this.name,
    required this.shortDescription,
    required this.duration,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.subcategoryId,
    required this.isFeature,
    required this.status,
    required this.extraTime,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      salonId: json['salon_id'],
      name: json['name'],
      shortDescription: json['short_description'],
      duration: json['duration'],
      description: json['description'],
      price: json['price'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      isFeature: json['is_feature'],
      status: json['status'],
      extraTime: json['extra_time'],
      gender: json['gender'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
