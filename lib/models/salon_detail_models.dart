// Generated minimal models for salon detail APIs (based on SALON_DETAIL_API.md)
import 'package:app/models/home/Professional.dart';

class SalonData {
  int? id;
  String? name;
  List<String>? images;
  String? logo;
  double? star;
  int? reviewCount;
  bool? isFavourite;
  String? about;
  String? policy;
  List<ActiveDay>? activeDays;
  Location? location;
  List<Category>? categories;
  List<Deal>? deals;
  List<Staff>? staff;
  List<Review>? reviews;
  List<Section>? sections;
  String? gender;

  // Additional fields used by existing screens
  String? minBookingTime;
  String? maxBookingTime;
  // Compatibility fields for older code that used different names
  String? minCancellationTime;
  String? salonPolicy;

  SalonData({
    this.id,
    this.name,
    this.images,
    this.logo,
    this.star,
    this.reviewCount,
    this.isFavourite,
    this.about,
    this.policy,
    this.activeDays,
    this.location,
    this.categories,
    this.deals,
    this.staff,
    this.reviews,
    this.sections,
    this.gender,
    this.minBookingTime,
    this.maxBookingTime,
    this.minCancellationTime,
    this.salonPolicy,
  });

  // Convenience getters for legacy code
  String? get address => location?.address;
  int? get review_count => reviewCount;
  bool? get is_favourite => isFavourite;

  factory SalonData.fromJson(Map<String, dynamic> json) {
    return SalonData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      logo: json['logo'] as String?,
      star: (json['star'] is num) ? (json['star'] as num).toDouble() : null,
      reviewCount: json['review_count'] is int
          ? json['review_count'] as int?
          : (json['reviewCount'] as int?),
      isFavourite: json['is_favourite'] as bool? ?? json['isFavourite'] as bool?,
      about: json['about'] as String?,
      policy: json['policy'] as String?,
      activeDays: (json['active_days'] as List?)
          ?.map((e) => ActiveDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      location: json['location'] != null
          ? Location.fromJson(Map<String, dynamic>.from(json['location']))
          : null,
      categories: (json['categories'] as List?)
          ?.map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      // deals/staff/reviews may be nested under other endpoints; keep null-safe
      deals: (json['deals'] as List?)
          ?.map((e) => Deal.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      staff: (json['staff'] as List?)
          ?.map((e) => Staff.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      reviews: (json['reviews'] as List?)
          ?.map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      sections: (json['sections'] as List?)
          ?.map((e) => Section.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      gender: json['gender'] as String?,
      // optional booking window strings
      minBookingTime: json['minBookingTime'] as String?,
      maxBookingTime: json['maxBookingTime'] as String?,
      minCancellationTime: json['minCancellationTime'] as String? ??
          json['min_cancellation_time'] as String?,
      salonPolicy: json['salonPolicy'] as String? ??
          json['salon_policy'] as String? ?? json['policy'] as String?,
    );
  }
}

class ActiveDay {
  int? id;
  int? salonId;
  String? day;
  String? openingTime;
  String? closingTime;
  int? status;

  ActiveDay(
      {this.id,
      this.salonId,
      this.day,
      this.openingTime,
      this.closingTime,
      this.status});

  factory ActiveDay.fromJson(Map<String, dynamic> json) => ActiveDay(
        id: json['id'] as int?,
        salonId: json['salon_id'] as int?,
        day: json['day'] as String?,
        openingTime:
            (json['open_time'] ?? json['opening_time']) as String?,
        closingTime:
            (json['close_time'] ?? json['closing_time']) as String?,
        status: json['status'] as int?,
      );
}

class Location {
  String? address;
  String? lat;
  String? long;

  Location({this.address, this.lat, this.long});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        address: json['address'] as String?,
        lat: json['lat']?.toString(),
        long: json['long']?.toString(),
      );
}

class Category {
  int? id;
  String? name;
  List<Service>? services;

  Category({this.id, this.name, this.services});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int?,
        name: json['name'] as String?,
        services: (json['services'] as List?)
            ?.map((e) => Service.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class Service {
  int? id;
  int? salonId;
  String? name;
  String? shortDescription;
  String? duration;
  String? description;
  double? price;
  List<Professional>? professionals;
  // compatibility / legacy fields
  double? oldPrice;
  String? extraTime;
  String? gender;
  int? categoryId;
  int? subcategoryId;
  String? discountType;
  double? percentageDiscount;
  double? discountAmount;
  double? priceDiscount;
  bool? isFeature;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Service({
    this.id,
    this.salonId,
    this.name,
    this.shortDescription,
    this.duration,
    this.description,
    this.price,
    this.professionals,
    // legacy fields
    this.oldPrice,
    this.extraTime,
    this.gender,
    this.categoryId,
    this.subcategoryId,
    this.discountType,
    this.percentageDiscount,
    this.discountAmount,
    this.priceDiscount,
    this.isFeature,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] as int?,
        salonId: json['salon_id'] as int?,
        name: json['name'] as String?,
        shortDescription: json['short_description'] as String?,
        duration: json['duration'] as String?,
        description: json['description'] as String?,
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
        professionals: (json['professionals'] as List?)
            ?.map((e) => Professional.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        // legacy/compat fields
        oldPrice: (json['old_price'] is num)
            ? (json['old_price'] as num).toDouble()
            : (json['oldPrice'] is num
                ? (json['oldPrice'] as num).toDouble()
                : null),
        extraTime: json['extra_time'] as String? ?? json['extraTime'] as String?,
        gender: json['gender'] as String?,
        categoryId:
            json['category_id'] as int? ?? json['categoryId'] as int?,
        subcategoryId:
            json['subcategory_id'] as int? ?? json['subcategoryId'] as int?,
        discountType: json['discount_type'] as String? ??
            json['discountType'] as String?,
        percentageDiscount: (json['percentage_discount'] is num)
            ? (json['percentage_discount'] as num).toDouble()
            : (json['percentageDiscount'] is num
                ? (json['percentageDiscount'] as num).toDouble()
                : null),
        discountAmount: (json['discount_amount'] is num)
            ? (json['discount_amount'] as num).toDouble()
            : (json['discountAmount'] is num
                ? (json['discountAmount'] as num).toDouble()
                : null),
        priceDiscount: (json['price_discount'] is num)
            ? (json['price_discount'] as num).toDouble()
            : (json['priceDiscount'] is num
                ? (json['priceDiscount'] as num).toDouble()
                : null),
        isFeature: json['is_feature'] as bool? ?? json['isFeature'] as bool?,
        status: json['status'] as int?,
        createdAt:
            json['created_at'] as String? ?? json['createdAt'] as String?,
        updatedAt:
            json['updated_at'] as String? ?? json['updatedAt'] as String?,
        deletedAt:
            json['deleted_at'] as String? ?? json['deletedAt'] as String?,
      );
}

class Deal {
  int? id;
  int? salonId;
  String? name;
  String? image;
  double? price;
  double? totalPrice;
  List<Service>? services;
  // compatibility / legacy fields
  String? discountType;
  double? discountValue;
  String? startDate;
  String? endDate;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Deal({
    this.id,
    this.salonId,
    this.name,
    this.image,
    this.price,
    this.totalPrice,
    this.services,
    // legacy fields
    this.discountType,
    this.discountValue,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
        id: json['id'] as int?,
        salonId: json['salon_id'] as int?,
        name: json['name'] as String?,
        image: json['image'] as String?,
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
        totalPrice: (json['total_price'] is num)
            ? (json['total_price'] as num).toDouble()
            : null,
        services: (json['services'] as List?)
            ?.map((e) => Service.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        discountType: json['discount_type'] as String? ??
            json['discountType'] as String?,
        discountValue: (json['discount_value'] is num)
            ? (json['discount_value'] as num).toDouble()
            : (json['discountValue'] is num
                ? (json['discountValue'] as num).toDouble()
                : null),
        startDate: json['start_date'] as String? ?? json['startDate'] as String?,
        endDate: json['end_date'] as String? ?? json['endDate'] as String?,
        status: json['status'] as int?,
        createdAt:
            json['created_at'] as String? ?? json['createdAt'] as String?,
        updatedAt:
            json['updated_at'] as String? ?? json['updatedAt'] as String?,
        deletedAt:
            json['deleted_at'] as String? ?? json['deletedAt'] as String?,
      );
}

class Staff {
  int? id;
  int? salonId;
  String? firstName;
  String? lastName;
  String? name;
  String? image;

  Staff({this.id, this.salonId, this.firstName, this.lastName, this.name, this.image});

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] as int?,
        salonId: json['salon_id'] as int?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        name: json['name'] as String?,
        image: json['image'] as String?,
      );
}

class Review {
  int? id;
  int? userId;
  int? salonId;
  int? rating;
  String? comment;

  Review({this.id, this.userId, this.salonId, this.rating, this.comment});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int?,
        userId: json['user_id'] as int?,
        salonId: json['salon_id'] as int?,
        rating: json['rating'] as int?,
        comment: json['comment'] as String?,
      );
}

class Section {
  String? type;
  List<Review>? data;

  Section({this.type, this.data});

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        type: json['type']?.toString(),
        data: (json['data'] as List?)
            ?.map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

// Legacy class for backward compatibility with code expecting "Salon" type
class Salon extends SalonData {
  Salon({
    super.id,
    super.name,
    super.images,
    super.logo,
    super.star,
    super.reviewCount,
    super.isFavourite,
    super.about,
    super.policy,
    super.activeDays,
    super.location,
    super.categories,
    super.deals,
    super.staff,
    super.reviews,
    super.sections,
    super.gender,
    super.minBookingTime,
    super.maxBookingTime,
    super.minCancellationTime,
    super.salonPolicy,
  });

  // Compatibility getters for old code
  String? get image => logo ?? (images != null && images!.isNotEmpty ? images!.first : null);

  factory Salon.fromJson(Map<String, dynamic> json) {
    final salonData = SalonData.fromJson(json);
    return Salon(
      id: salonData.id,
      name: salonData.name,
      images: salonData.images,
      logo: salonData.logo,
      star: salonData.star,
      reviewCount: salonData.reviewCount,
      isFavourite: salonData.isFavourite,
      about: salonData.about,
      policy: salonData.policy,
      activeDays: salonData.activeDays,
      location: salonData.location,
      categories: salonData.categories,
      deals: salonData.deals,
      staff: salonData.staff,
      reviews: salonData.reviews,
      sections: salonData.sections,
      gender: salonData.gender,
      minBookingTime: salonData.minBookingTime,
      maxBookingTime: salonData.maxBookingTime,
      minCancellationTime: salonData.minCancellationTime,
      salonPolicy: salonData.salonPolicy,
    );
  }
}

// Alias for legacy references to SalonActiveDay
typedef SalonActiveDay = ActiveDay;
