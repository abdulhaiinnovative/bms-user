import 'HomePageResponse.dart';

class SalonDetailApiResponse {
  final int? statusCode;
  final ResponseData response;
  final String message;
  final bool status;
  final List<dynamic> errors;

  SalonDetailApiResponse({
    required this.statusCode,
    required this.response,
    required this.message,
    required this.status,
    required this.errors,
  });

  factory SalonDetailApiResponse.fromJson(Map<String, dynamic> json) {
    return SalonDetailApiResponse(
      statusCode: json['statusCode'],
      response: ResponseData.fromJson(json['response']),
      message: json['message'],
      status: json['status'],
      errors: json['errors'],
    );
  }
}

class ResponseData {
  final SalonData data;

  ResponseData({required this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: SalonData.fromJson(json['data']),
    );
  }
}

class SalonData {
  final String? name;
  final int? id;
  final List<String> images;
  final String? createdAt;
  final String? gender;
  final String? logo;
  final int? star;
  final int? review_count;
  final String? fackebook;
  final String? instagram;
  final String? twitter;
  final String? linkedin;
  final String? about;
  final String? policy;
  final String? type;
  final String? kind;

  // TODO: FAVOURITES MODEL - Backend favourite status
  // This field comes from API response (is_favourite)
  // Used to initialize UI favourite state in salon detail screen
  final bool? isFavourite;
  final List<Section>? sections;
  final Location? location;

  SalonData({
    required this.name,
    required this.id,
    required this.images,
    required this.createdAt,
    required this.gender,
    required this.logo,
    required this.star,
    required this.review_count,
    required this.fackebook,
    required this.instagram,
    required this.twitter,
    required this.linkedin,
    required this.about,
    required this.policy,
    required this.type,
    required this.kind,
    required this.isFavourite,
    required this.sections,
    required this.location,
  });

  factory SalonData.fromJson(Map<String, dynamic> json) {
    return SalonData(
      name: json['name'],
      id: json['id'],
      images: List<String>.from(json['images']),
      createdAt: json['created_at'],
      gender: json['gender'],
      logo: json['logo'],
      star: json['star'],
      review_count: json['review-count'],

      fackebook: json['fackebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],

      about: json['about'],
      policy: json['policy'],
      type: json['type'],
      kind: json['kind'],

      // TODO: FAVOURITES PARSING - Parse is_favourite from API
      isFavourite: json['is_favourite'],
      sections:
          (json['sections'] as List).map((e) => Section.fromJson(e)).toList(),
      location: Location.fromJson(json['location']),
    );
  }
}

class Section {
  final String name;
  final String type;
  final dynamic data;

  Section({required this.name, required this.type, required this.data});

  factory Section.fromJson(Map<String, dynamic> json) {
    dynamic parsedData;
    switch (json['type']) {
      case "2": // Services
        parsedData =
            (json['data'] as List).map((e) => Service.fromJson(e)).toList();
        break;
      case "3": // Reviews
        parsedData =
            (json['data'] as List).map((e) => Review.fromJson(e)).toList();
        break;
      case "4": // Staff
        parsedData =
            (json['data'] as List).map((e) => Staff.fromJson(e)).toList();
        break;
      case "5": // About
        parsedData =
            (json['data'] as List).map((e) => About.fromJson(e)).toList();
        break;
      case "6": // Deals
        parsedData =
            (json['data'] as List).map((e) => Deal.fromJson(e)).toList();
        break;
      default:
        parsedData = json['data'];
    }
    return Section(
      name: json['name'],
      type: json['type'],
      data: parsedData,
    );
  }
}

class Location {
  final String address;
  final String lat;
  final String long;

  Location({required this.address, required this.lat, required this.long});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      lat: json['lat'],
      long: json['long'],
    );
  }
}

// class Service {
//   final int id;
//   final String name;
//   final String shortDescription;
//   final String duration;
//   final String description;
//   final String price;
//   final String? discountType;
//   final String? priceDiscount;
//   final String oldPrice;
//
//   Service({
//     required this.id,
//     required this.name,
//     required this.shortDescription,
//     required this.duration,
//     required this.description,
//     required this.price,
//     this.discountType,
//     this.priceDiscount,
//     required this.oldPrice,
//   });
//
//   factory Service.fromJson(Map<String, dynamic> json) {
//     return Service(
//       id: json['id'],
//       name: json['name'],
//       shortDescription: json['short_description'],
//       duration: json['duration'],
//       description: json['description'],
//       price: json['price'],
//       discountType: json['discount_type'],
//       priceDiscount: json['price_discount'],
//       oldPrice: json['old_price'],
//     );
//   }
// }

class Review {
  final int? id;
  final int? salonId;
  final int? userId;
  final int? bookingId;
  final String? comment;
  final int? rating;
  final int? status;
  final int? isHome;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final User user;

  Review({
    required this.id,
    required this.salonId,
    required this.userId,
    required this.bookingId,
    required this.comment,
    required this.rating,
    required this.status,
    required this.isHome,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.user,
  });

  /// **Factory constructor to parse JSON into a Review object**
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      salonId: json['salon_id'],
      userId: json['user_id'],
      bookingId: json['booking_id'],
      comment: json['comment'],
      rating: json['rating'],
      status: json['status'],
      isHome: json['is_home'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      user: User.fromJson(json['user']),
    );
  }

  /// **Convert a Review object into JSON format**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'user_id': userId,
      'booking_id': bookingId,
      'comment': comment,
      'rating': rating,
      'status': status,
      'is_home': isHome,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'user': user.toJson(),
    };
  }
}

class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? email;
  final String? googleUniqueId;
  final String? facebookUniqueId;
  final String? deviceId;
  final String? emailVerifiedAt;
  final int? loyalty;
  final String? provider;
  final String? providerId;
  final String? image;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? country;
  final String? state;
  final String? latitude;
  final String? longitude;
  final String? city;
  final String? address;
  final int? appointment;
  final int? emailMarketing;
  final int? marketingNotification;
  final int? status;
  final String? deletedAt;
  final String? emailVerificationCode;
  final String? passwordResetCode;
  final String? createdAt;
  final String? updatedAt;
  final int? completeStatus;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    this.googleUniqueId,
    this.facebookUniqueId,
    this.deviceId,
    this.emailVerifiedAt,
    required this.loyalty,
    this.provider,
    this.providerId,
    required this.image,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.country,
    required this.state,
    this.latitude,
    this.longitude,
    required this.city,
    required this.address,
    required this.appointment,
    required this.emailMarketing,
    required this.marketingNotification,
    required this.status,
    this.deletedAt,
    this.emailVerificationCode,
    this.passwordResetCode,
    required this.createdAt,
    required this.updatedAt,
    required this.completeStatus,
  });

  /// **Factory constructor to create a `User` object from JSON**
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      email: json['email'],
      googleUniqueId: json['google_unique_id'],
      facebookUniqueId: json['facebook_unique_id'],
      deviceId: json['device_id'],
      emailVerifiedAt: json['email_verified_at'],
      loyalty: json['loyalty'],
      provider: json['provider'],
      providerId: json['provider_id'],
      image: json['image'],
      phone: json['phone'],
      dob: json['dob'],
      gender: json['gender'],
      country: json['country'],
      state: json['state'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      address: json['address'],
      appointment: json['appointment'],
      emailMarketing: json['email_marketing'],
      marketingNotification: json['marketing_notification'],
      status: json['status'],
      deletedAt: json['deleted_at'],
      emailVerificationCode: json['email_verification_code'],
      passwordResetCode: json['password_reset_code'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      completeStatus: json['complete_status'],
    );
  }

  /// **Method to convert a `User` object into a JSON map**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'email': email,
      'google_unique_id': googleUniqueId,
      'facebook_unique_id': facebookUniqueId,
      'device_id': deviceId,
      'email_verified_at': emailVerifiedAt,
      'loyalty': loyalty,
      'provider': provider,
      'provider_id': providerId,
      'image': image,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'country': country,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'address': address,
      'appointment': appointment,
      'email_marketing': emailMarketing,
      'marketing_notification': marketingNotification,
      'status': status,
      'deleted_at': deletedAt,
      'email_verification_code': emailVerificationCode,
      'password_reset_code': passwordResetCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'complete_status': completeStatus,
    };
  }
}

class Staff {
  final int? id;
  final int? salonId;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final String? experience;
  final int? bookingAccept;
  final int? monday;
  final int? tuesday;
  final int? wednesday;
  final int? thursday;
  final int? friday;
  final int? saturday;
  final int? sunday;
  final String? startDate;
  final String? endDate;
  final int? status;
  final String? note;

  Staff({
    required this.id,
    required this.salonId,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.experience,
    required this.bookingAccept,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.note,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      salonId: json['salon_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      experience: json['experience'],
      bookingAccept: json['booking_accept'],
      monday: json['monday'],
      tuesday: json['tuesday'],
      wednesday: json['wednesday'],
      thursday: json['thursday'],
      friday: json['friday'],
      saturday: json['saturday'],
      sunday: json['sunday'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      note: json['note'],
    );
  }
}

class About {
  final String? desc;
  final List<OpeningTiming> openingTimings;
  final String? address;
  final String? latLong;

  About({
    required this.desc,
    required this.openingTimings,
    required this.address,
    required this.latLong,
  });

  /// **Factory constructor to parse JSON into an About object**
  factory About.fromJson(Map<String, dynamic> json) {
    return About(
      desc: json['desc'],
      openingTimings: (json['opening_timings'] as List)
          .map((e) => OpeningTiming.fromJson(e))
          .toList(),
      address: json['address'],
      latLong: json['lat_long'],
    );
  }

  /// **Convert an About object into JSON format**
  Map<String, dynamic> toJson() {
    return {
      'desc': desc,
      'opening_timings': openingTimings.map((e) => e.toJson()).toList(),
      'address': address,
      'lat_long': latLong,
    };
  }
}

class OpeningTiming {
  final int? id;
  final int? salonId;
  final String? day;
  final String? openingTime;
  final String? closingTime;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  OpeningTiming({
    required this.id,
    required this.salonId,
    required this.day,
    required this.openingTime,
    required this.closingTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// **Factory constructor to parse JSON into an OpeningTiming object**
  factory OpeningTiming.fromJson(Map<String, dynamic> json) {
    return OpeningTiming(
      id: json['id'],
      salonId: json['salon_id'],
      day: json['day'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  /// **Convert an OpeningTiming object into JSON format**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'day': day,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}

//
// class Deal {
//   final int id;
//   final String name;
//   final double price;
//   final double totalPrice;
//
//   Deal({required this.id, required this.name, required this.price, required this.totalPrice});
//
//   factory Deal.fromJson(Map<String, dynamic> json) {
//     return Deal(
//       id: json['id'],
//       name: json['name'],
//       price: json['price'].toDouble(),
//       totalPrice: json['total_price'].toDouble(),
//     );
//   }
// }
