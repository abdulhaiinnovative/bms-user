import 'SalonMain.dart';

class ServiceMain {
  final int id;
  final int salonId;
  final String name;
  final String shortDescription;
  final String duration;
  final String description;
  final double price;
  final double? percentageDiscount;
  final double? discountAmount;
  final String? discountType;
  final double? priceDiscount;
  final double oldPrice;
  final int categoryId;
  final int subcategoryId;
  final int isFeature;
  final int status;
  final int extraTime;
  final String gender;
  final String? createdAt;
  final String? updatedAt;
  final SalonMain? salon;

  ServiceMain({
    required this.id,
    required this.salonId,
    required this.name,
    required this.shortDescription,
    required this.duration,
    required this.description,
    required this.price,
    this.percentageDiscount,
    this.discountAmount,
    this.discountType,
    this.priceDiscount,
    required this.oldPrice,
    required this.categoryId,
    required this.subcategoryId,
    required this.isFeature,
    required this.status,
    required this.extraTime,
    required this.gender,
    this.createdAt,
    this.updatedAt,
    this.salon,
  });

  factory ServiceMain.fromJson(Map<String, dynamic> json) {
    return ServiceMain(
      id: json['id'],
      salonId: json['salon_id'],
      name: json['name'],
      shortDescription: json['short_description'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      percentageDiscount: json['percentage_discount'] != null
          ? double.tryParse(json['percentage_discount'].toString())
          : null,
      discountAmount: json['discount_amount'] != null
          ? double.tryParse(json['discount_amount'].toString())
          : null,
      discountType: json['discount_type'],
      priceDiscount: json['price_discount'] != null
          ? double.tryParse(json['price_discount'].toString())
          : null,
      oldPrice: double.tryParse(json['old_price'].toString()) ?? 0.0,
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      isFeature: json['is_feature'],
      status: json['status'],
      extraTime: json['extra_time'],
      gender: json['gender'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      salon: json['salon'] != null ? SalonMain.fromJson(json['salon']) : null,
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

class SalonImage {
  final int id;
  final int salonId;
  final String image;

  SalonImage({
    required this.id,
    required this.salonId,
    required this.image,
  });

  factory SalonImage.fromJson(Map<String, dynamic> json) {
    return SalonImage(
      id: json['id'],
      salonId: json['salon_id'],
      image: json['image'],
    );
  }
}
