
import 'ServiceData.dart';


class DealData {
  final int? id;
  final int? salon_id;
  final String? name;
  final String? image;
  final double? price;
  final String? discount_type;
  final double? discount_value;
  final double? total_price;
  final String? start_date;
  final String? end_date;
  final int? status;
  final List<ServiceData>? services;

  DealData({
    this.id,
    this.salon_id,
    this.name,
    this.image,
    this.price,
    this.discount_type,
    this.discount_value,
    this.total_price,
    this.start_date,
    this.end_date,
    this.status,
    this.services,
  });

  factory DealData.fromJson(Map<String, dynamic> json) {
    return DealData(
      id: json['id'] as int?,
      salon_id: json['salon_id'] as int?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      discount_type: json['discount_type'] as String?,
      discount_value: (json['discount_value'] as num?)?.toDouble(),
      total_price: (json['total_price'] as num?)?.toDouble(),
      start_date: json['start_date'] as String?,
      end_date: json['end_date'] as String?,
      status: json['status'] as int?,
      services: (json['services'] as List<dynamic>?)?.map((e) => ServiceData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salon_id,
      'name': name,
      'image': image,
      'price': price,
      'discount_type': discount_type,
      'discount_value': discount_value,
      'total_price': total_price,
      'start_date': start_date,
      'end_date': end_date,
      'status': status,
      'services': services?.map((e) => e.toJson()).toList(),
    };
  }
}