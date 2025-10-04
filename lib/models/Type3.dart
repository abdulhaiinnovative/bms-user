class Type3 {
  final String heading;
  final List<Type3Data> data;

  Type3({required this.heading, required this.data});

  factory Type3.fromJson(Map<String, dynamic> json) {
    return Type3(
      heading: json['heading'],
      data: (json['data'] as List)
          .map((item) => Type3Data.fromJson(item))
          .toList(),
    );
  }
}

class Type3Data {
  final int id;
  final int vendorId;
  final String name;
  final String image;
  final String country;
  final String state;
  final String city;
  final String area;
  final String address;
  final String? latitude;
  final String? longitude;
  final String? minBookingTime;
  final String? maxBookingTime;
  final String? minCancellationTime;
  final String type;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String salonFor;
  final String mapLocation;
  final String salonPolicy;
  final String additionalInformation;
  final String about;
  final int status;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final double averageRating;
  final int reviewCount;
  final bool isFavourite;
  final List<ImageData> images;

  Type3Data({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.image,
    required this.country,
    required this.state,
    required this.city,
    required this.area,
    required this.address,
    this.latitude,
    this.longitude,
    this.minBookingTime,
    this.maxBookingTime,
    this.minCancellationTime,
    required this.type,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    required this.salonFor,
    required this.mapLocation,
    required this.salonPolicy,
    required this.additionalInformation,
    required this.about,
    required this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    required this.averageRating,
    required this.reviewCount,
    required this.isFavourite,
    required this.images,
  });

  factory Type3Data.fromJson(Map<String, dynamic> json) {
    return Type3Data(
      id: json['id'],
      vendorId: json['vendor_id'],
      name: json['name'],
      image: json['image'],
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
      status: json['status'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      averageRating: json['average_rating'],
      reviewCount: json['review_count'],
      isFavourite: json['is_favourite'],
      images: (json['images'] as List)
          .map((item) => ImageData.fromJson(item))
          .toList(),
    );
  }
}

class ImageData {
  final int id;
  final int salonId;
  final String image;
  final String? createdAt;
  final String? updatedAt;

  ImageData({
    required this.id,
    required this.salonId,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      salonId: json['salon_id'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

