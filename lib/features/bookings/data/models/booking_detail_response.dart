/// Model for the booking detail API response
/// API: GET /api/booking-detail/{id}

class BookingDetailResponse {
  final int statusCode;
  final BookingDetailData response;
  final String message;
  final bool status;
  final List<dynamic> errors;

  BookingDetailResponse({
    required this.statusCode,
    required this.response,
    required this.message,
    required this.status,
    required this.errors,
  });

  factory BookingDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookingDetailResponse(
      statusCode: json['statusCode'] ?? 200,
      response: BookingDetailData.fromJson(json['response'] ?? {}),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      errors: json['errors'] ?? [],
    );
  }
}

class BookingDetailData {
  final BookingDetail data;

  BookingDetailData({required this.data});

  factory BookingDetailData.fromJson(Map<String, dynamic> json) {
    return BookingDetailData(
      data: BookingDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class BookingDetail {
  final int id;
  final int salonId;
  final int userId;
  final int? teamId;
  final String? date;
  final String? time;
  final String? paymentMethod;
  final double? payment;
  final double? tip;
  final int? additionalDiscount;
  final String? feedback;
  final String? cancelMessage;
  final double? commission;
  final int? bookingFrom;
  final String? paymentStatus;
  final String? bookingType;
  final String? status;
  final int? usedLoyaltyPoints;
  final String? kind;
  final String? cnic;
  final String? address;
  final String? createdAt;
  final int? utilizedSessions;
  final String? membershipStatus;
  final List<BookingReview> review;
  final BookingSalon? salon;
  final List<BookingService> services;
  final List<dynamic> deal;
  final List<dynamic> membership;

  BookingDetail({
    required this.id,
    required this.salonId,
    required this.userId,
    this.teamId,
    this.date,
    this.time,
    this.paymentMethod,
    this.payment,
    this.tip,
    this.additionalDiscount,
    this.feedback,
    this.cancelMessage,
    this.commission,
    this.bookingFrom,
    this.paymentStatus,
    this.bookingType,
    this.status,
    this.usedLoyaltyPoints,
    this.kind,
    this.cnic,
    this.address,
    this.createdAt,
    this.utilizedSessions,
    this.membershipStatus,
    required this.review,
    this.salon,
    required this.services,
    required this.deal,
    required this.membership,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      teamId: json['team_id'],
      date: json['date'],
      time: json['time'],
      paymentMethod: json['payment_method'],
      payment: _parseDouble(json['payment']),
      tip: _parseDouble(json['tip']),
      additionalDiscount: _parseInt(json['additional_discount']),
      feedback: json['feedback'],
      cancelMessage: json['cancel_message'],
      commission: _parseDouble(json['commission']),
      bookingFrom: json['booking_from'],
      paymentStatus: json['payment_status'],
      bookingType: json['booking_type'],
      status: json['status'],
      usedLoyaltyPoints: json['used_loyalty_points'],
      kind: json['kind'],
      cnic: json['CNIC'],
      address: json['address'],
      createdAt: json['created_at'],
      utilizedSessions: json['utilized_sessions'],
      membershipStatus: json['membership_status'],
      review: (json['review'] as List<dynamic>?)
              ?.map((e) => BookingReview.fromJson(e))
              .toList() ??
          [],
      salon:
          json['salon'] != null ? BookingSalon.fromJson(json['salon']) : null,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => BookingService.fromJson(e))
              .toList() ??
          [],
      deal: json['deal'] ?? [],
      membership: json['membership'] ?? [],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class BookingReview {
  final int id;
  final int salonId;
  final int userId;
  final int bookingId;
  final String? comment;
  final int? rating;
  final int? status;
  final int? isHome;
  final ReviewUser? user;

  BookingReview({
    required this.id,
    required this.salonId,
    required this.userId,
    required this.bookingId,
    this.comment,
    this.rating,
    this.status,
    this.isHome,
    this.user,
  });

  factory BookingReview.fromJson(Map<String, dynamic> json) {
    return BookingReview(
      id: json['id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      comment: json['comment'],
      rating: json['rating'],
      status: json['status'],
      isHome: json['is_home'],
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
    );
  }
}

class ReviewUser {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? email;
  final String? image;
  final String? phone;

  ReviewUser({
    required this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.image,
    this.phone,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      phone: json['phone'],
    );
  }
}

class BookingSalon {
  final int id;
  final int? vendorId;
  final String? name;
  final String? logo;
  final String? image;
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
  final String? kind;
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
  final double? averageRating;
  final int? reviewCount;
  final bool? isFavourite;
  final List<SalonActiveDay> activeDays;
  final List<String> images;

  BookingSalon({
    required this.id,
    this.vendorId,
    this.name,
    this.logo,
    this.image,
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
    this.kind,
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
    this.averageRating,
    this.reviewCount,
    this.isFavourite,
    required this.activeDays,
    required this.images,
  });

  factory BookingSalon.fromJson(Map<String, dynamic> json) {
    return BookingSalon(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'],
      name: json['name'],
      logo: json['logo'],
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
      kind: json['kind'],
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
      suspended: json['suspended'],
      averageRating: BookingDetail._parseDouble(json['average_rating']),
      reviewCount: json['review_count'],
      isFavourite: json['is_favourite'],
      activeDays: (json['active_days'] as List<dynamic>?)
              ?.map((e) => SalonActiveDay.fromJson(e))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class SalonActiveDay {
  final int id;
  final int salonId;
  final String? day;
  final String? openingTime;
  final String? closingTime;
  final int? status;

  SalonActiveDay({
    required this.id,
    required this.salonId,
    this.day,
    this.openingTime,
    this.closingTime,
    this.status,
  });

  factory SalonActiveDay.fromJson(Map<String, dynamic> json) {
    return SalonActiveDay(
      id: json['id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      day: json['day'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      status: json['status'],
    );
  }
}

class BookingService {
  final int id;
  final int salonId;
  final String? name;
  final String? shortDescription;
  final String? duration;
  final String? description;
  final double? price;
  final double? percentageDiscount;
  final double? discountAmount;
  final String? discountType;
  final double? priceDiscount;
  final double? oldPrice;
  final int? categoryId;
  final int? subcategoryId;
  final int? isFeature;
  final int? status;
  final int? extraTime;
  final String? gender;
  final ServiceProfessional? selectedProfessional;

  BookingService({
    required this.id,
    required this.salonId,
    this.name,
    this.shortDescription,
    this.duration,
    this.description,
    this.price,
    this.percentageDiscount,
    this.discountAmount,
    this.discountType,
    this.priceDiscount,
    this.oldPrice,
    this.categoryId,
    this.subcategoryId,
    this.isFeature,
    this.status,
    this.extraTime,
    this.gender,
    this.selectedProfessional,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['id'] ?? 0,
      salonId: json['salon_id'] ?? 0,
      name: json['name'],
      shortDescription: json['short_description'],
      duration: json['duration'],
      description: json['description'],
      price: BookingDetail._parseDouble(json['price']),
      percentageDiscount: BookingDetail._parseDouble(json['percentage_discount']),
      discountAmount: BookingDetail._parseDouble(json['discount_amount']),
      discountType: json['discount_type'],
      priceDiscount: BookingDetail._parseDouble(json['price_discount']),
      oldPrice: BookingDetail._parseDouble(json['old_price']),
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      isFeature: json['is_feature'],
      status: json['status'],
      extraTime: json['extra_time'],
      gender: json['gender'],
      selectedProfessional: json['staff'] != null
          ? ServiceProfessional.fromJson(json['staff'])
          : (json['selected_professional'] != null
              ? ServiceProfessional.fromJson(json['selected_professional'])
              : null),
    );
  }
}

class ServiceProfessional {
  final int id;
  final int? salonId;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final String? experience;

  ServiceProfessional({
    required this.id,
    this.salonId,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.phone,
    this.image,
    this.experience,
  });

  factory ServiceProfessional.fromJson(Map<String, dynamic> json) {
    return ServiceProfessional(
      id: json['id'] ?? 0,
      salonId: json['salon_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      experience: json['experience'],
    );
  }

  String get displayName {
    final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (fullName.isNotEmpty) return fullName;
    if (name != null && name!.isNotEmpty) return name!;
    return 'Professional';
  }
}
