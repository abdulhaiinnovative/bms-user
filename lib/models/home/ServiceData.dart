
import 'SalonData.dart';
import 'Professional.dart';

class ServiceData {
  final int? id;
  final int? salon_id;
  final String? name;
  final String? short_description;
  final String? duration;
  final String? description;
  final String? price;
  final String? percentage_discount;
  final String? discount_amount;
  final String? discount_type;
  final String? price_discount;
  final String? old_price;
  final int? category_id;
  final int? subcategory_id;
  final int? is_feature;
  final int? status;
  final int? extra_time;
  final String? gender;
  final SalonData? salon;
  final List<Professional>? professionals;

  ServiceData({
    this.id,
    this.salon_id,
    this.name,
    this.short_description,
    this.duration,
    this.description,
    this.price,
    this.percentage_discount,
    this.discount_amount,
    this.discount_type,
    this.price_discount,
    this.old_price,
    this.category_id,
    this.subcategory_id,
    this.is_feature,
    this.status,
    this.extra_time,
    this.gender,
    this.salon,
    this.professionals,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'] as int?,
      salon_id: json['salon_id'] as int?,
      name: json['name'] as String?,
      short_description: json['short_description'] as String?,
      duration: json['duration'] as String?,
      description: json['description'] as String?,
      price: json['price'] as String?,
      percentage_discount: json['percentage_discount'] as String?,
      discount_amount: json['discount_amount'] as String?,
      discount_type: json['discount_type'] as String?,
      price_discount: json['price_discount'] as String?,
      old_price: json['old_price'] as String?,
      category_id: json['category_id'] as int?,
      subcategory_id: json['subcategory_id'] as int?,
      is_feature: json['is_feature'] as int?,
      status: json['status'] as int?,
      extra_time: json['extra_time'] as int?,
      gender: json['gender'] as String?,
      salon: json['salon'] != null ? SalonData.fromJson(json['salon'] as Map<String, dynamic>) : null,
      professionals: (json['professionals'] as List<dynamic>?)?.map((e) => Professional.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salon_id,
      'name': name,
      'short_description': short_description,
      'duration': duration,
      'description': description,
      'price': price,
      'percentage_discount': percentage_discount,
      'discount_amount': discount_amount,
      'discount_type': discount_type,
      'price_discount': price_discount,
      'old_price': old_price,
      'category_id': category_id,
      'subcategory_id': subcategory_id,
      'is_feature': is_feature,
      'status': status,
      'extra_time': extra_time,
      'gender': gender,
      'salon': salon?.toJson(),
      'professionals': professionals?.map((e) => e.toJson()).toList(),
    };
  }
}